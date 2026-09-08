#requires -Version 5.1
<#
.SYNOPSIS
    Keeps an older Steam Skyrim Special Edition or Anniversary Edition
    installation from being replaced by the current public release.

.DESCRIPTION
    Finds Skyrim's Steam app manifest, reads its installed depots, records the
    current public Steam build and manifest IDs, and makes the manifest
    read-only. The Skyrim game files are not changed.

    By default, the script asks whether to retrieve current release data from
    api.steamcmd.net. It also includes a known release for offline use and
    accepts custom values.

.PARAMETER SteamApps
    Optional path to the Steam library's steamapps folder. The script finds
    Steam libraries automatically when this is omitted.

.PARAMETER ReleaseSource
    Prompt asks which source to use. Online uses api.steamcmd.net, BuiltIn uses
    the release saved in this script, and Custom uses supplied or prompted IDs.

.PARAMETER CustomBuildId
    Public Steam build ID to use with the Custom source.

.PARAMETER CustomManifests
    Dictionary of installed depot IDs and public manifest GIDs to use with the
    Custom source.

.PARAMETER Force
    Answers yes to the two confirmations that fire when release data looks older
    than expected: online data that predates the built-in release, and a
    selected build lower than the one already recorded. Intended for unattended
    runs. It does not skip any other check.

.NOTES
    Exit Steam completely before running this script.

    Never use Verify Integrity of Game Files while preserving an older Skyrim
    version. It can replace the older files regardless of this manifest lock.

    Valve does not document or guarantee the read-only manifest method. Keep a
    separate copy of the working game folder.
#>
[CmdletBinding()]
param(
    [ValidateScript({
        if ([string]::IsNullOrWhiteSpace($_)) {
            throw 'SteamApps cannot be empty or whitespace.'
        }
        return $true
    })]
    [string] $SteamApps,

    [ValidateSet('Prompt', 'Online', 'BuiltIn', 'Custom')]
    [string] $ReleaseSource = 'Prompt',

    [string] $CustomBuildId,

    [System.Collections.IDictionary] $CustomManifests,

    [switch] $Force
)

$ErrorActionPreference = 'Stop'

$customParametersSupplied =
    $PSBoundParameters.ContainsKey('CustomBuildId') -or
    $PSBoundParameters.ContainsKey('CustomManifests')

if ($customParametersSupplied -and $ReleaseSource -in @('Online', 'BuiltIn')) {
    throw "Custom parameters cannot be combined with ReleaseSource $ReleaseSource."
}
if ($customParametersSupplied -and $ReleaseSource -eq 'Prompt') {
    $ReleaseSource = 'Custom'
}

$AppId = '489830'
$ApiUri = "https://api.steamcmd.net/v1/info/$AppId"
$BaseDepotIds = @('489831', '489832', '489833')
$KnownSharedDepotIds = @('228986', '228990')

# The newest public release known when this script was updated. Online lookup
# can use a newer release without requiring a script update.
$BuiltInRelease = [ordered]@{
    Version     = '1.7.104'
    BuildId     = '24914197'
    TimeUpdated = '1787839209'
    Manifests   = [ordered]@{
        '489831' = '4940892828028256588'
        '489832' = '5728778377666085157'
        '489833' = '4886117324142477814'
        '489834' = '3443400614252193371'
        '489835' = '8608174573130432573'
        '489836' = '2757270758137158257'
        '489837' = '1257737911412624232'
        '489838' = '6810738189465173322'
        '489839' = '2751807503705497425'
        '544860' = '5386271571563273695'
        '544861' = '4913356797939551438'
    }
}

function Test-DecimalId {
    param([AllowNull()][object] $Value)

    return ([string]$Value -match '\A[0-9]+\z')
}

# Join-Path resolves the drive through the PowerShell provider, so it throws on a
# library whose drive is not attached. Plain string joining lets Test-Path decide.
# Returns $null when the pieces cannot form a path, which callers treat as "skip".
function Join-PathSegments {
    param(
        [Parameter(Mandatory)][string] $Base,
        [Parameter(Mandatory)][string[]] $Segments
    )

    try {
        $combined = $Base
        foreach ($segment in $Segments) {
            $combined = [System.IO.Path]::Combine($combined, $segment)
        }
        return $combined
    } catch {
        return $null
    }
}

function Compare-DecimalId {
    param(
        [Parameter(Mandatory)][string] $Left,
        [Parameter(Mandatory)][string] $Right
    )

    $normalizedLeft = $Left.TrimStart('0')
    $normalizedRight = $Right.TrimStart('0')
    if ($normalizedLeft.Length -eq 0) { $normalizedLeft = '0' }
    if ($normalizedRight.Length -eq 0) { $normalizedRight = '0' }

    if ($normalizedLeft.Length -lt $normalizedRight.Length) { return -1 }
    if ($normalizedLeft.Length -gt $normalizedRight.Length) { return 1 }
    return [string]::CompareOrdinal($normalizedLeft, $normalizedRight)
}

function Read-YesNo {
    param(
        [Parameter(Mandatory)][string] $Question,
        [Parameter(Mandatory)][bool] $Default
    )

    $suffix = if ($Default) { '[Y/n]' } else { '[y/N]' }

    while ($true) {
        $answer = (Read-Host "$Question $suffix").Trim()
        if ($answer.Length -eq 0) { return $Default }
        if ($answer -match '^(?i:y|yes)$') { return $true }
        if ($answer -match '^(?i:n|no)$') { return $false }
        Write-Host 'Enter Y or N.'
    }
}

function Find-SkyrimManifest {
    param([AllowNull()][string] $SteamAppsOverride)

    $manifestName = "appmanifest_$AppId.acf"

    if (-not [string]::IsNullOrWhiteSpace($SteamAppsOverride)) {
        $folder = $SteamAppsOverride.Trim().Trim('"')
        $candidate = Join-PathSegments $folder @($manifestName)
        if ($null -eq $candidate -or
            -not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            $candidate = Join-PathSegments $folder @('steamapps', $manifestName)
        }
        if ($null -eq $candidate -or
            -not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            throw "No $manifestName was found under '$SteamAppsOverride'."
        }
        return Convert-Path -LiteralPath $candidate
    }

    $roots = @()
    $registryLocations = @(
        @{ Path = 'HKCU:\Software\Valve\Steam'; Property = 'SteamPath' },
        @{ Path = 'HKLM:\Software\Valve\Steam'; Property = 'InstallPath' },
        @{ Path = 'HKLM:\Software\WOW6432Node\Valve\Steam'; Property = 'InstallPath' }
    )

    foreach ($location in $registryLocations) {
        $item = Get-ItemProperty -LiteralPath $location.Path -ErrorAction SilentlyContinue
        if ($null -ne $item) {
            $value = $item.($location.Property)
            if (-not [string]::IsNullOrWhiteSpace([string]$value)) {
                $roots += [string]$value
            }
        }
    }

    foreach ($root in @($roots)) {
        $libraryFile = Join-PathSegments $root @('steamapps', 'libraryfolders.vdf')
        if ($null -eq $libraryFile) { continue }
        if (Test-Path -LiteralPath $libraryFile -PathType Leaf) {
            $libraryText = [System.IO.File]::ReadAllText($libraryFile)
            foreach ($match in [regex]::Matches($libraryText, '"path"\s+"([^"]+)"')) {
                $roots += $match.Groups[1].Value.Replace('\\', '\')
            }
        }
    }

    $candidates = @(
        @(
            foreach ($root in $roots | Sort-Object -Unique) {
                $candidate = Join-PathSegments $root @('steamapps', $manifestName)
                if ($null -eq $candidate) { continue }
                if (-not (Test-Path -LiteralPath $root)) {
                    Write-Warning "Steam library '$root' is not available; skipping it. If Skyrim is installed there, reconnect that drive and run the script again."
                    continue
                }
                if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                    Convert-Path -LiteralPath $candidate
                }
            }
        ) | Sort-Object -Unique
    )

    if ($candidates.Count -eq 1) {
        return $candidates[0]
    }

    if ($candidates.Count -gt 1) {
        Write-Host 'More than one Skyrim app manifest was found:'
        for ($index = 0; $index -lt $candidates.Count; $index++) {
            Write-Host ('  {0}. {1}' -f ($index + 1), $candidates[$index])
        }
        while ($true) {
            $number = 0
            $answer = Read-Host "Select 1 through $($candidates.Count), or press Enter to cancel"
            if ([string]::IsNullOrWhiteSpace($answer)) { return $null }
            if ([int]::TryParse($answer, [ref]$number) -and
                $number -ge 1 -and $number -le $candidates.Count) {
                return $candidates[$number - 1]
            }
            Write-Host 'Enter one of the displayed numbers.'
        }
    }

    while ($true) {
        $folder = (Read-Host 'Skyrim was not found. Enter its steamapps folder, or press Enter to cancel').Trim().Trim('"')
        if ([string]::IsNullOrWhiteSpace($folder)) { return $null }
        $candidate = Join-PathSegments $folder @($manifestName)
        if ($null -ne $candidate -and
            (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return Convert-Path -LiteralPath $candidate
        }
        Write-Warning "No $manifestName was found in '$folder'."
    }
}

function Get-InstalledDepotIds {
    param([Parameter(Mandatory)][string] $AcfText)

    $lines = [regex]::Split($AcfText, '\r?\n')
    $start = -1
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -match '^\s*"InstalledDepots"') {
            $start = $index
            break
        }
    }
    if ($start -lt 0) {
        throw 'InstalledDepots was not found in the app manifest.'
    }

    $opened = $false
    $depth = 0
    $depots = @()

    for ($index = $start; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]

        if (-not $opened) {
            if ($line -match '\{') {
                $opened = $true
                $depth = 1
            }
            continue
        }

        if ($depth -eq 1 -and $line -match '^\s*"(?<Depot>\d+)"\s*(?:\{)?\s*$') {
            $depot = $Matches.Depot
            if ($depots -contains $depot) {
                throw "InstalledDepots contains depot $depot more than once."
            }
            $depots += $depot
        }

        $depth += ([regex]::Matches($line, '\{')).Count
        $depth -= ([regex]::Matches($line, '\}')).Count
        if ($depth -eq 0) { break }
        if ($depth -lt 0) {
            throw 'InstalledDepots has unbalanced braces.'
        }
    }

    if (-not $opened -or $depth -ne 0) {
        throw 'InstalledDepots is malformed or incomplete.'
    }
    if ($depots.Count -eq 0) {
        throw 'InstalledDepots does not contain any depot IDs.'
    }
    return $depots
}

function Get-ApiGid {
    param(
        [Parameter(Mandatory)][object] $AppInfo,
        [Parameter(Mandatory)][string] $DepotId
    )

    $depotProperty = $AppInfo.depots.PSObject.Properties[$DepotId]
    if ($null -eq $depotProperty) { return $null }

    $publicManifest = $depotProperty.Value.manifests.public
    if ($publicManifest -is [string]) { return $publicManifest }
    if ($null -eq $publicManifest) { return $null }
    return [string]$publicManifest.gid
}

function Test-ApiSharedDepot {
    param(
        [Parameter(Mandatory)][object] $AppInfo,
        [Parameter(Mandatory)][string] $DepotId
    )

    $depotProperty = $AppInfo.depots.PSObject.Properties[$DepotId]
    if ($null -eq $depotProperty) { return $false }

    $depotInfo = $depotProperty.Value
    return ([string]$depotInfo.sharedinstall -eq '1' -or
            (Test-DecimalId $depotInfo.depotfromapp))
}

function Get-OnlineRelease {
    param([Parameter(Mandatory)][string[]] $InstalledDepots)

    $previousProtocol = $null
    try {
        if ($PSVersionTable.PSEdition -eq 'Desktop') {
            $previousProtocol = [Net.ServicePointManager]::SecurityProtocol
            [Net.ServicePointManager]::SecurityProtocol =
                $previousProtocol -bor [Net.SecurityProtocolType]::Tls12
        }
        $response = Invoke-RestMethod -Uri $ApiUri -Method Get -TimeoutSec 15
    }
    finally {
        if ($null -ne $previousProtocol) {
            [Net.ServicePointManager]::SecurityProtocol = $previousProtocol
        }
    }

    $appProperty = $response.data.PSObject.Properties[$AppId]
    if ($response.status -ine 'success' -or $null -eq $appProperty) {
        throw 'The SteamCMD API did not return Skyrim app information.'
    }

    $appInfo = $appProperty.Value
    if ([string]$appInfo.appid -ne $AppId) {
        throw "The SteamCMD API response did not identify app $AppId correctly."
    }

    $buildId = [string]$appInfo.depots.branches.public.buildid
    $timeUpdated = [string]$appInfo.depots.branches.public.timeupdated
    if (-not (Test-DecimalId $buildId)) {
        throw 'The SteamCMD API public build ID is missing or invalid.'
    }

    $onlineUpdateTime = 0L
    if ([long]::TryParse($timeUpdated, [ref]$onlineUpdateTime)) {
        if ($onlineUpdateTime -lt [long]$BuiltInRelease.TimeUpdated) {
            Write-Warning "The online data predates the built-in $($BuiltInRelease.Version) release. This can indicate a Valve rollback or stale API data."
            if ($Force) {
                Write-Warning 'Using the older online release because -Force was supplied.'
            } elseif (-not (Read-YesNo 'Use the older online release anyway?' $false)) {
                Write-Host 'Older online release declined.'
                return $null
            }
        } elseif ($onlineUpdateTime -eq [long]$BuiltInRelease.TimeUpdated -and
                  $buildId -ne $BuiltInRelease.BuildId) {
            throw 'The SteamCMD API returned a different build for the same update time as the built-in release.'
        }
    } else {
        Write-Warning 'The SteamCMD API did not return a valid public update time; continuing because this value is not written to the app manifest.'
    }

    $manifests = [ordered]@{}
    foreach ($depot in $InstalledDepots) {
        $gid = Get-ApiGid $appInfo $depot
        if ($null -eq $gid -and (Test-ApiSharedDepot $appInfo $depot)) {
            Write-Warning "Installed depot $depot is shared from another app and has no Skyrim public GID; leaving its app-manifest entry unchanged."
            continue
        }
        if (-not (Test-DecimalId $gid)) {
            throw "The SteamCMD API did not return a valid public GID for installed depot $depot."
        }
        $manifests[$depot] = $gid
    }

    if ($buildId -eq $BuiltInRelease.BuildId) {
        foreach ($depot in $manifests.Keys) {
            if ($BuiltInRelease.Manifests.Contains($depot) -and
                $manifests[$depot] -ne $BuiltInRelease.Manifests[$depot]) {
                throw "The SteamCMD API GID for installed depot $depot does not match the built-in release."
            }
        }
    }

    $version = $null
    if ($buildId -eq $BuiltInRelease.BuildId) {
        $version = $BuiltInRelease.Version
    }

    return [pscustomobject]@{
        Source    = 'Online, api.steamcmd.net'
        Version   = $version
        BuildId   = $buildId
        Manifests = $manifests
    }
}

function Get-BuiltInRelease {
    param([Parameter(Mandatory)][string[]] $InstalledDepots)

    $manifests = [ordered]@{}
    foreach ($depot in $InstalledDepots) {
        if (-not $BuiltInRelease.Manifests.Contains($depot)) {
            if ($KnownSharedDepotIds -contains $depot) {
                Write-Warning "Installed depot $depot is a shared Steamworks depot; leaving its app-manifest entry unchanged."
                continue
            }
            throw "Installed depot $depot is not in the built-in release. Use Online or Custom."
        }
        $manifests[$depot] = $BuiltInRelease.Manifests[$depot]
    }

    return [pscustomobject]@{
        Source    = 'Built-in fallback'
        Version   = $BuiltInRelease.Version
        BuildId   = $BuiltInRelease.BuildId
        Manifests = $manifests
    }
}

function Get-CustomRelease {
    param([Parameter(Mandatory)][string[]] $InstalledDepots)

    $buildId = $CustomBuildId
    if ([string]::IsNullOrWhiteSpace($buildId)) {
        $buildId = Read-Host 'Enter the current public Steam build ID'
    }
    if (-not (Test-DecimalId $buildId)) {
        throw "Custom build ID is not a decimal string: '$buildId'."
    }

    $provided = [ordered]@{}
    if ($null -ne $CustomManifests) {
        foreach ($key in $CustomManifests.Keys) {
            $provided[[string]$key] = [string]$CustomManifests[$key]
        }
    }

    foreach ($depot in $provided.Keys) {
        if ($InstalledDepots -notcontains $depot) {
            throw "CustomManifests contains depot $depot, which is not installed."
        }
        if ($KnownSharedDepotIds -contains $depot) {
            throw "CustomManifests contains shared depot $depot, which does not have a Skyrim public GID."
        }
        if (-not (Test-DecimalId $provided[$depot])) {
            throw "The custom GID for depot $depot is not a decimal string."
        }
    }

    $manifests = [ordered]@{}
    foreach ($depot in $InstalledDepots) {
        if ($KnownSharedDepotIds -contains $depot) {
            Write-Warning "Installed depot $depot is a shared Steamworks depot; leaving its app-manifest entry unchanged."
            continue
        }
        if ($provided.Contains($depot)) {
            $manifests[$depot] = $provided[$depot]
        } else {
            # Pressing Enter skips a depot that has no Skyrim public GID, such
            # as a shared depot this script does not already know about. A base
            # depot always has one, so skipping it would record a new build
            # alongside a stale manifest.
            $canSkip = $BaseDepotIds -notcontains $depot
            $prompt = if ($canSkip) {
                "Enter the public manifest GID for depot $depot, or press Enter to skip it"
            } else {
                "Enter the public manifest GID for required depot $depot"
            }

            $gid = (Read-Host $prompt).Trim()
            if ([string]::IsNullOrWhiteSpace($gid)) {
                if (-not $canSkip) {
                    throw "Depot $depot is a required Skyrim depot and cannot be skipped."
                }
                Write-Warning "Skipped depot $depot; leaving its app-manifest entry unchanged."
                continue
            }
            if (-not (Test-DecimalId $gid)) {
                throw "The custom GID for depot $depot is not a decimal string."
            }
            $manifests[$depot] = $gid
        }
    }

    return [pscustomobject]@{
        Source    = 'Custom values'
        Version   = $null
        BuildId   = $buildId
        Manifests = $manifests
    }
}

function Get-AcfDecimalValue {
    param(
        [Parameter(Mandatory)][string] $Text,
        [Parameter(Mandatory)][string] $Key
    )

    $pattern = '("{0}"[ \t]+")(?<Value>\d+)(")' -f [regex]::Escape($Key)
    $valueMatches = [regex]::Matches(
        $Text, $pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase)

    if ($valueMatches.Count -ne 1) {
        throw "Pattern for '$Key' matched $($valueMatches.Count) times, expected exactly one. Aborting with the file unchanged."
    }
    return $valueMatches[0].Groups['Value'].Value
}

# Replaces one value in the ACF and requires unique keys for safe editing.
function Set-AcfValue {
    param(
        [Parameter(Mandatory)][string] $Text,
        [Parameter(Mandatory)][string] $Pattern,
        [Parameter(Mandatory)][string] $Replacement,
        [Parameter(Mandatory)][string] $Label,
        [switch] $Optional
    )

    $count = [regex]::Matches(
        $Text, $Pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase).Count

    if ($count -eq 0) {
        if ($Optional) { return $Text }
        throw "Pattern for '$Label' did not match. Aborting with the file unchanged."
    }
    if ($count -gt 1) {
        throw "Pattern for '$Label' matched $count times, expected exactly one. Aborting with the file unchanged."
    }
    return $Text -replace $Pattern, $Replacement
}

# All discovery and validation happens before the backup or read-only flag is
# touched.
if (Get-Process -Name 'steam' -ErrorAction SilentlyContinue) {
    throw 'Steam is still running. Exit it fully from the tray icon, then run the script again.'
}

$acf = Find-SkyrimManifest $SteamApps
if ([string]::IsNullOrWhiteSpace($acf)) {
    Write-Host 'Canceled. No files were changed.'
    return
}
$backup = "$acf.bak"
$text = [System.IO.File]::ReadAllText($acf)
$original = $text
$installedDepots = @(Get-InstalledDepotIds $text)

foreach ($depot in $BaseDepotIds) {
    if ($installedDepots -notcontains $depot) {
        throw "Required Skyrim depot $depot is missing from InstalledDepots."
    }
}

Write-Host "Skyrim manifest: $acf"
Write-Host "Installed depots: $($installedDepots -join ', ')"

$release = $null
switch ($ReleaseSource) {
    'Online' {
        try {
            $release = Get-OnlineRelease $installedDepots
        } catch {
            throw "Online lookup failed. No files were changed. $($_.Exception.Message)"
        }
    }
    'BuiltIn' {
        $release = Get-BuiltInRelease $installedDepots
    }
    'Custom' {
        $release = Get-CustomRelease $installedDepots
    }
    'Prompt' {
        $onlineFailed = $false
        if (Read-YesNo "Look up the current public release from api.steamcmd.net? Only Skyrim's app ID $AppId is sent." $true) {
            try {
                $release = Get-OnlineRelease $installedDepots
            } catch {
                $onlineFailed = $true
                Write-Warning "Online lookup failed: $($_.Exception.Message)"
            }
        }

        if ($null -eq $release) {
            Write-Host "Built-in fallback: Skyrim $($BuiltInRelease.Version), Steam build $($BuiltInRelease.BuildId)."
            $savedReleaseDate = [DateTimeOffset]::FromUnixTimeSeconds(
                [long]$BuiltInRelease.TimeUpdated).UtcDateTime.ToString('yyyy-MM-dd')
            Write-Warning "This saved release is from $savedReleaseDate and may be outdated."
            if (Read-YesNo 'Use this embedded release?' (-not $onlineFailed)) {
                try {
                    $release = Get-BuiltInRelease $installedDepots
                } catch {
                    Write-Warning $_.Exception.Message
                }
            }
        }

        if ($null -eq $release -and
            (Read-YesNo 'Enter custom build and manifest IDs instead?' $false)) {
            $release = Get-CustomRelease $installedDepots
        }
    }
}

if ($null -eq $release) {
    Write-Host 'Canceled. No files were changed.'
    return
}

Write-Host "Release source: $($release.Source)"
if (-not [string]::IsNullOrWhiteSpace([string]$release.Version)) {
    Write-Host "Skyrim version: $($release.Version)"
}
Write-Host "Public Steam build: $($release.BuildId)"
Write-Host 'Selected manifests:'
foreach ($depot in $release.Manifests.Keys) {
    Write-Host ('  {0}: {1}' -f $depot, $release.Manifests[$depot])
}

$buildId = $release.BuildId
$manifests = $release.Manifests
$recordedBuildId = Get-AcfDecimalValue $text 'buildid'

if ((Compare-DecimalId $buildId $recordedBuildId) -lt 0) {
    Write-Warning "Selected public build $buildId is lower than the ACF's recorded build $recordedBuildId. Recording the lower build can make Steam consider an update necessary."
    if ($Force) {
        Write-Warning 'Recording the lower build because -Force was supplied.'
    } elseif (-not (Read-YesNo 'Record the lower build anyway?' $false)) {
        Write-Host 'Canceled. No files were changed.'
        return
    }
}

$text = Set-AcfValue $text '("buildid"[ \t]+")\d+(")' "`${1}$buildId`${2}" 'buildid'
$text = Set-AcfValue $text '("TargetBuildID"[ \t]+")\d+(")' "`${1}$buildId`${2}" 'TargetBuildID' -Optional
$text = Set-AcfValue $text '("StateFlags"[ \t]+")\d+(")' '${1}4${2}' 'StateFlags'
$text = Set-AcfValue $text '("AutoUpdateBehavior"[ \t]+")\d+(")' '${1}1${2}' 'AutoUpdateBehavior'

foreach ($field in 'UpdateResult', 'StagingSize', 'BytesToDownload', 'BytesDownloaded',
                   'BytesToStage', 'BytesStaged', 'ScheduledAutoUpdate') {
    $text = Set-AcfValue $text ('("{0}"[ \t]+")\d+(")' -f $field) '${1}0${2}' $field -Optional
}

foreach ($depot in $manifests.Keys) {
    $pattern = '("{0}"\s*\{{[^}}]*?"manifest"[ \t]+")\d+(")' -f $depot
    $text = Set-AcfValue $text $pattern "`${1}$($manifests[$depot])`${2}" "depot $depot manifest"
}

if ($text -eq $original) {
    Write-Host "`nThe ACF already matches public build $buildId."
    if ((Get-Item -LiteralPath $acf).IsReadOnly) {
        Write-Host 'Read-only protection is already enabled.'
    } else {
        Set-ItemProperty -LiteralPath $acf -Name IsReadOnly -Value $true
        Write-Host 'Read-only protection has been enabled.'
    }
    return
}

# One backup generation, written only when the ACF changes.
Copy-Item -LiteralPath $acf -Destination $backup -Force
Set-ItemProperty -LiteralPath $backup -Name IsReadOnly -Value $false
Write-Host "`nBackup: $backup"

$readOnlyCleared = $false
$readOnlyRestored = $false

try {
    Set-ItemProperty -LiteralPath $acf -Name IsReadOnly -Value $false
    $readOnlyCleared = $true
    $temporaryPath = "$acf.$PID.tmp"
    try {
        [System.IO.File]::WriteAllText(
            $temporaryPath,
            $text,
            (New-Object System.Text.UTF8Encoding -ArgumentList $false))

        [System.IO.File]::Replace($temporaryPath, $acf, [NullString]::Value)
    } catch {
        $writeError = $_
        Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
        throw $writeError
    }
}
finally {
    if ($readOnlyCleared) {
        try {
            Set-ItemProperty -LiteralPath $acf -Name IsReadOnly -Value $true
            $readOnlyRestored = $true
        } catch {
            Write-Warning "COULD NOT RESTORE READ-ONLY ON $acf"
            Write-Warning "Reason: $($_.Exception.Message)"
        }
    } else {
        # Clearing read-only failed, so nothing was written and the flag was
        # never changed. Report the file's real state instead of a false alarm.
        try {
            $readOnlyRestored = (Get-Item -LiteralPath $acf).IsReadOnly
        } catch {
            $readOnlyRestored = $false
        }
    }
}

if (-not $readOnlyRestored) {
    throw "Read-only was not restored on $acf. Set it manually before starting Steam."
}

Write-Host "`nChanges made:"
$old = @(Get-Content -LiteralPath $backup -Encoding UTF8)
$new = @(Get-Content -LiteralPath $acf -Encoding UTF8)

if ($old.Count -eq 0 -or $new.Count -eq 0) {
    Write-Warning 'One of the files is empty. Check the ACF before starting Steam.'
} elseif ($old.Count -ne $new.Count) {
    Write-Warning 'Line count changed, so positions no longer align. Falling back to Compare-Object.'
    Compare-Object -ReferenceObject $old -DifferenceObject $new | Format-Table -AutoSize
} else {
    0..($old.Count - 1) |
        Where-Object { $old[$_] -ne $new[$_] } |
        ForEach-Object {
            [pscustomobject]@{
                Line = $_ + 1
                Old  = $old[$_].Trim()
                New  = $new[$_].Trim()
            }
        } | Format-Table -AutoSize
}

Write-Host 'Read-only protection is enabled.'
Write-Host 'Review the changes, then start Steam. Do not use Verify Integrity of Game Files.'
