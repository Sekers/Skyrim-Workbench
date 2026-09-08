#requires -Version 5.1
<#
.SYNOPSIS
    Tells Steam your Skyrim install is current, so Steam stops trying to update
    it.

.DESCRIPTION
    You are deliberately running an older Skyrim SE than Steam is offering,
    because the newer build breaks SKSE and your mods.

    Steam decides whether Skyrim needs updating by looking only at the build and
    manifest ID numbers recorded in appmanifest_489830.acf. It never looks at the
    game files themselves unless you run Verify Integrity. Writing the current ID
    numbers into that file makes Steam believe the install is up to date, so it
    stops queuing a download and stops throwing errors. Your older game files are
    not touched.

    Close Steam completely before running this script (tray icon, Exit). Start
    Steam again once the script has finished.

.NOTES
    What keeps your game files safe is the read-only flag on the .acf. Steam does
    not apply an update without recording it in that file, and a read-only file
    cannot be written to, so the update never lands. That is how Steam happens to
    behave, not a promise Valve makes.

    Do not use Verify Integrity while preserving an older build because it can
    replace the older game files with the current public files. Valve does not
    document or guarantee the read-only manifest method. Keep your own copy of
    the game folder. That is the real safety net.

    This script leaves the .acf read-only every time it finishes.

    When there are changes to make, the script turns read-only off, edits the
    file, and turns read-only back on. If turning it back on fails, the script
    stops with an error rather than leave the file unprotected.

    When the file already contains the right numbers, there is nothing to edit,
    so read-only is never turned off at all. The script still checks whether
    read-only is on, and turns it on if it is not.

    Run this script again after each Bethesda patch, with that patch's numbers
    filled in below.

    Never use Verify Integrity of Game Files on Skyrim. It is the one thing that
    inspects your actual game files, notices they are older, and re-downloads the
    new build over them.

    Start the game from MO2 / SKSE rather than Steam's Play button. Steam writes
    to the .acf whenever a game launches, so a read-only .acf leaves Steam
    logging "Failed to write app state file" over and over. Harmless, but no
    reason to invite it.

    The backup this makes (appmanifest_489830.acf.bak) holds the manifest as it
    was immediately before the most recent edit, and is written only on a run
    that actually changes something. The next such run overwrites the backup, so
    only the single most recent one ever exists. It is not a backup of your game.

    SKSE has to match the Skyrim version you are really running, not the build
    number written into the manifest.

    If you locked the .acf with an icacls Deny rule, remove that rule before
    running this script and re-apply it afterwards. A Deny rule blocks changes to
    the read-only setting as well as changes to the file.
#>

# =============================================================================
# CONFIG (this is the part you edit for each new patch)
# =============================================================================

# The steamapps folder that Skyrim is installed under. If you keep Steam
# libraries on more than one drive, use the steamapps folder on the drive holding
# Skyrim, which is not necessarily the drive Steam itself is installed on.
$SteamApps = 'C:\Steam\steamapps'

# 489830 is Skyrim Special Edition. Leave this alone.
$AppId = 489830

# The build number of the version Steam is currently offering.
#
# To find it, straight from Steam:
#   Win+R, run:  steam://open/console
#   In the Console tab that appears, type:
#       app_info_update 1
#       app_info_print 489830
#   Then look for: depots > branches > public > buildid
#
# Or read the build number from https://steamdb.info/app/489830/depots/, in the
# Branches table, on the "public" row.
$BuildId = '24914197'   # 1.7.104, released 27 Aug 2026

# The manifest number for each part of the game, for that same current build.
#
# One number goes by several names. SteamDB calls it the manifest ID, Steam's
# console calls it the gid, a download_depot command takes it as the third
# number, and your own .acf stores it next to the word "manifest". Same number
# in all four places.
#
# Get them from either:
#   https://steamdb.info/app/489830/depots/?branch=public
# or the Steam console again:
#   app_info_update 1
#   app_info_print 489830
#   then look for: depots > <depot number> > manifests > public > gid
#
# When moving to a new build, copy the current public gid for every installed
# depot. Steam can reuse an unchanged depot manifest in a new build, so an
# individual gid may remain the same even when the build number changes.
#
# The parts of the game:
#   489831  world data (BSAs, ESMs)
#   489832  core files
#   489833  SkyrimSE.exe
#   489834 French, 489835 Italian, 489836 German, 489837 Spanish,
#   489838 Russian, 489839 Polish, 544860 Trad. Chinese, 544861 Japanese
#
# List only the parts that actually appear under InstalledDepots in your .acf.
# Open the .acf and look rather than guessing. Listing a part that the .acf does
# not contain will stop the script with an error.
$Manifests = [ordered]@{
    '489831' = '4940892828028256588'
    '489832' = '5728778377666085157'
    '489833' = '4886117324142477814'
}

# =============================================================================
# SCRIPT
# =============================================================================

$ErrorActionPreference = 'Stop'

$acf = Join-Path $SteamApps "appmanifest_$AppId.acf"

# All validation runs before the backup or the read-only flag is touched, so a
# bad config leaves the file exactly as it was found.
if (Get-Process -Name 'steam' -ErrorAction SilentlyContinue) {
    throw 'Steam is still running. Exit it fully from the tray icon, then re-run.'
}
if (-not (Test-Path -LiteralPath $acf)) {
    throw "Not found: $acf"
}

# .NET file APIs resolve relative paths against the process working directory,
# which PowerShell's own location does not track. A full path avoids checking
# one file and writing another.
$acf    = Convert-Path -LiteralPath $acf
$backup = "$acf.bak"

if ($Manifests.Values -contains 'PASTE_GID') {
    throw 'Fill in the manifest GIDs in the $Manifests block first.'
}

# IDs go into the .acf verbatim, so a stray space or a truncated paste would
# corrupt it.
if ($BuildId -notmatch '^\d+$') {
    throw "BuildId is not a decimal string: '$BuildId'"
}
foreach ($depot in $Manifests.Keys) {
    if ($depot -notmatch '^\d+$') {
        throw "Depot ID is not a decimal string: '$depot'"
    }
    if ($Manifests[$depot] -notmatch '^\d+$') {
        throw "Manifest ID for depot $depot is not a decimal string: '$($Manifests[$depot])'"
    }
}

# Replaces one key's value in the .acf text, and reports whether it moved.
function Set-AcfValue {
    param(
        [Parameter(Mandatory)][string] $Text,
        [Parameter(Mandatory)][string] $Pattern,
        [Parameter(Mandatory)][string] $Replacement,
        [Parameter(Mandatory)][string] $Label,
        [switch] $Optional
    )
    # Counted rather than just tested for a match: -replace rewrites every
    # match, and these keys are unique, so anything but one match means a
    # malformed .acf. Case-insensitive because Steam's casing is not worth
    # relying on; the leading quote in each pattern is what keeps "buildid" from
    # matching inside "TargetBuildID".
    $count = [regex]::Matches(
        $Text, $Pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase).Count

    if ($count -eq 0) {
        if ($Optional) {
            Write-Host ('  skip    {0} (not present)' -f $Label)
            return $Text
        }
        throw "Pattern for '$Label' did not match. Aborting with the file unchanged."
    }
    if ($count -gt 1) {
        throw "Pattern for '$Label' matched $count times, expected exactly one. Aborting with the file unchanged."
    }

    $result = $Text -replace $Pattern, $Replacement

    if ($result -eq $Text) {
        Write-Host ('  ok      {0}' -f $Label)
    } else {
        Write-Host ('  set     {0}' -f $Label)
    }
    return $result
}

# --- read and compute ---------------------------------------------------------
# Nothing is written in this section, so a pattern mismatch aborts with the .acf
# still read-only and untouched.

# ReadAllText rather than Get-Content: no console codepage round trip.
$text     = [System.IO.File]::ReadAllText($acf)
$original = $text

# [ \t]+ rather than \s+ so a match cannot run across a line break and pick up
# an unrelated key.
$text = Set-AcfValue $text '("buildid"[ \t]+")\d+(")'       "`${1}$BuildId`${2}" 'buildid'
$text = Set-AcfValue $text '("TargetBuildID"[ \t]+")\d+(")' "`${1}$BuildId`${2}" 'TargetBuildID' -Optional
$text = Set-AcfValue $text '("StateFlags"[ \t]+")\d+(")'    '${1}4${2}'          'StateFlags'
$text = Set-AcfValue $text '("AutoUpdateBehavior"[ \t]+")\d+(")' '${1}1${2}'     'AutoUpdateBehavior'

# Byte counters for whatever update Steam last recorded. They persist after that
# update finishes, so they are routinely stale rather than a sign of anything
# pending. Bookkeeping only: zeroing them touches nothing on disk, it stops the
# file contradicting "nothing to update".
foreach ($field in 'UpdateResult', 'BytesToDownload', 'BytesDownloaded',
                   'BytesToStage', 'BytesStaged', 'ScheduledAutoUpdate') {
    $text = Set-AcfValue $text ('("{0}"[ \t]+")\d+(")' -f $field) '${1}0${2}' $field -Optional
}

# [^}] cannot cross the depot block's closing brace, so each match stays inside
# the block its own ID opens.
foreach ($depot in $Manifests.Keys) {
    $pattern = '("{0}"\s*\{{[^}}]*?"manifest"[ \t]+")\d+(")' -f $depot
    $text = Set-AcfValue $text $pattern "`${1}$($Manifests[$depot])`${2}" "depot $depot manifest"
}

# --- nothing to do ------------------------------------------------------------
if ($text -eq $original) {
    Write-Host "`nNothing changed. The .acf already matches build $BuildId."
    Write-Host 'No backup written.'

    # Correct contents do not imply the file is protected: restoring a .bak
    # brings it back writable. Never leave without confirming the flag.
    if ((Get-Item -LiteralPath $acf).IsReadOnly) {
        Write-Host 'Read-only already set.'
    } else {
        Set-ItemProperty -LiteralPath $acf -Name IsReadOnly -Value $true
        Write-Host 'The .acf was writable. Read-only set.'
    }
    return
}

# --- back up ------------------------------------------------------------------
# One generation only: overwritten by every run that writes.
Copy-Item -LiteralPath $acf -Destination $backup -Force

# Copy-Item preserves attributes, so the backup would otherwise inherit
# read-only and be awkward to overwrite or delete.
Set-ItemProperty -LiteralPath $backup -Name IsReadOnly -Value $false
Write-Host "Backed up to $backup"

# --- write --------------------------------------------------------------------
$readOnlyRestored = $false
Set-ItemProperty -LiteralPath $acf -Name IsReadOnly -Value $false
Write-Host 'Read-only cleared.'

try {
    # Written to a sibling temp file and swapped in. File.Replace is one
    # filesystem operation, so the manifest is never briefly truncated.
    $tmp = "$acf.$PID.tmp"
    try {
        # UTF8Encoding($false) means UTF-8 with no BOM. Steam will not parse a
        # .acf that has one.
        [System.IO.File]::WriteAllText(
            $tmp, $text, (New-Object System.Text.UTF8Encoding -ArgumentList $false))

        # [NullString]::Value, not $null: PowerShell coerces $null to an empty
        # string when binding to a [string] parameter, and File.Replace rejects
        # that with "The path is empty."
        [System.IO.File]::Replace($tmp, $acf, [NullString]::Value)
    } catch {
        # Cleanup is best-effort and its own errors are discarded, so it cannot
        # mask the write failure being re-thrown.
        $writeError = $_
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        throw $writeError
    }
    Write-Host "`nWrote $acf"
}
finally {
    # In finally so the flag goes back on even if the write threw.
    try {
        Set-ItemProperty -LiteralPath $acf -Name IsReadOnly -Value $true
        $readOnlyRestored = $true
        Write-Host 'Read-only restored.'
    } catch {
        Write-Warning "COULD NOT RESTORE READ-ONLY ON $acf"
        Write-Warning "Reason: $($_.Exception.Message)"
    }
}

# Outside the finally: throwing from inside one discards any exception already
# in flight, which would hide a write failure behind a restore failure.
if (-not $readOnlyRestored) {
    throw "Read-only was NOT restored on $acf. It is writable right now. Set it manually before starting Steam, or Steam will apply the pending update."
}

# --- diff ---------------------------------------------------------------------
# Positional rather than Compare-Object, which is a set comparison and never
# pairs an old line with the line that replaced it. Every edit here is an
# in-place substitution, so line counts match and position n maps to position n.
#
# The depot "manifest" rows carry no depot ID of their own, so use the line
# number to find which block each belongs to.
Write-Host "`nDiff against $backup :"

$old = Get-Content -LiteralPath $backup
$new = Get-Content -LiteralPath $acf

if ($old.Count -eq 0 -or $new.Count -eq 0) {
    Write-Warning 'One of the files is empty. Check the .acf before starting Steam.'
} elseif ($old.Count -ne $new.Count) {
    Write-Warning 'Line count changed, so positions no longer align. Falling back to Compare-Object.'
    Compare-Object -ReferenceObject $old -DifferenceObject $new | Format-Table -AutoSize
} else {
    # The guard above matters: 0..($n-1) with $n = 0 becomes 0..-1, which
    # PowerShell enumerates downward as 0,-1 rather than yielding nothing.
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

Write-Host 'Review the diff, then start Steam. The game should show as up to date.'
Write-Host 'Do not run Verify Integrity of Game Files on this app.'
