# Keep an Older Skyrim Special Edition Build from Updating

Steam wants every game on the newest version. If you run SKSE or version-dependent mods, a Skyrim update breaks them. This script tells Steam your Skyrim is already up to date and then locks that answer in, so the update never arrives. **Run it again after each new Skyrim release to record the new numbers.**

It is for Skyrim Special Edition and Anniversary Edition on Steam for Windows. It does not work with the original or Legendary Edition, Skyrim VR, GOG, or the Microsoft Store version. It runs on Windows PowerShell 5.1 and PowerShell 7 or newer.

Your game files are never touched. The script only edits Steam's bookkeeping file for Skyrim.

## Features

- Blocks Skyrim Special Edition and Anniversary Edition updates on Steam.
- Prevents update downloads, saving bandwidth.
- Holds through future releases with a read-only app manifest.
- Finds your Skyrim automatically, on any drive or Steam library.
- Takes release IDs online (recommended to make sure the latest version info is used), from a copy saved in the script, or from you.
- Backs up the app manifest and shows every line it changed.
- Refuses to run while Steam is open, and asks before anything risky.
- Runs unattended for scheduled use.

## Before you start

1. **Get Skyrim onto the version you want first.** This script does not downgrade anything. If Steam has already updated you, follow the [downgrade guide](../../../docs/steam/downgrade-steam-skyrim.md) first, then come back here.
2. **Do not run this if a Skyrim update was interrupted.** If Steam began replacing game files and did not finish, marking that half-updated folder complete would lock the damage in, and Steam could no longer detect it. The script checks for this and warns you. Rebuild a clean installation with the [downgrade guide](../../../docs/steam/downgrade-steam-skyrim.md) first.
3. **Exit Steam completely.** Select **Steam > Exit** from the menu, or right-click the tray icon and choose **Exit**. Closing the window is not enough, and the script refuses to run while Steam is open.

## Run the script

You do not need to edit the script. It finds your Skyrim automatically, even if your Steam library is on a different drive than Steam itself, and reads your exact installed depots from `appmanifest_489830.acf`.

Open Command Prompt or PowerShell in the repository root, then use the matching commands below.

### From Command Prompt

Either edition works; use the second if you have PowerShell 7 or newer installed.

```bat
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1"
```

```bat
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1"
```

`-ExecutionPolicy Bypass` applies only to that one PowerShell process. It does not change any setting on your computer.

### From PowerShell

The same commands work in Windows PowerShell and PowerShell 7 or newer.

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1
```

`-Scope Process` applies only to that PowerShell window. It does not change any setting on your computer.

### What it will ask you

A normal run asks one question, then shows you what it changed. The rest of these only appear if something is unusual.

| Question | When it appears | What to answer |
| --- | --- | --- |
| `Select 1 through N, or press Enter to cancel` | Steam's record file for Skyrim turned up in more than one library folder. Usually an old copy left behind by an interrupted **Move Install Folder**, or by a library folder you copied or restored yourself | Type the number for the Skyrim you actually play. The script lists the full folder path for each one, so match it against where your modded game lives, such as the folder Mod Organizer 2 launches. If you are not sure, press **Enter** to cancel, check the folder in Steam under **Properties > Installed Files**, then run the script again. |
| `Skyrim was not found. Enter its steamapps folder, or press Enter to cancel` | No Skyrim record file turned up in any Steam library the script could find | Paste the full path to the `steamapps` folder holding your Skyrim, such as `D:\SteamLibrary\steamapps`. Steam shows it under **Properties > Installed Files**. It asks again if that folder has no Skyrim record in it. **Enter** cancels the run. |
| `Look up the current public release from api.steamcmd.net? Only Skyrim's app ID 489830 is sent. [Y/n]` | Every run, unless the command line sets a release source | **Enter** for yes, which is the normal choice. It fetches the build numbers Steam is handing out today. Answer **n** to stay offline. |
| `Use the older online release anyway? [y/N]` | The online data looks older than the release saved in the script | **Enter** for no. Say yes only if you know Valve rolled the game back; otherwise the service is probably returning stale data. |
| `Use this embedded release? [Y/n]`, or `[y/N]` when the lookup failed | You answered `n` to the lookup, declined stale online data, or the lookup failed | **Enter** to accept the release saved in the script, but check the date it prints first: that release was the newest one when the script was last updated, and Bethesda may have shipped a patch since. Answer **n** to supply your own numbers instead. |
| `Enter custom build and manifest IDs instead? [y/N]` | You declined both of the above, or you accepted the saved release but it has no entry for one of your installed depots | **y** if you already have the numbers, from [Advanced](#advanced-find-and-supply-custom-release-ids) below. **Enter** cancels the run without changing anything. |
| `Record the game as fully installed anyway? [y/N]` | Steam's record shows an update that did not finish, so your game files may be part old and part new | **Enter** for no. Say yes only if you know the game folder is intact. Otherwise rebuild a clean installation with the [downgrade guide](../../../docs/steam/downgrade-steam-skyrim.md), then run this again. |
| `Record the lower build anyway? [y/N]` | The build about to be written is lower than the one already recorded | **Enter** for no. A lower build can make Steam decide an update is needed, so say yes only if you know why it is lower. |

### When it finishes

If it changed anything, it prints where the backup went and a table of the exact lines it changed. Review that, then start Steam again.

Otherwise it just confirms the manifest already matches and makes sure read-only is on.

**Do not use Verify Integrity of Game Files.** See [Important limitations](#important-limitations).

## What it does

- Writes the current public build and manifest ID numbers into Skyrim's Steam app manifest, and clears the update state Steam had already recorded: its saved update result, download and staging counters, and scheduled update time. Steam decides whether a game needs updating from those numbers, not from your actual game files, so it now treats your game installation as already up to date. Your older game files are never replaced.
- While those numbers match the current release, Steam sees nothing to update, so it never queues, downloads, or stages anything.
- Keeps the app manifest read-only. Steam records an update in that file before applying it, so when the next Skyrim release arrives, Steam cannot write the new state and the update does not go through. This is what protects the installation once the ID numbers above are out of date. Steam shows a disk write error instead.
- Sets Steam's update preference to update only when the game is launched.
- Backs up the app manifest before applying changes.
- Shows the exact lines changed.

## What it changes in the manifest

Everything below is in `steamapps\appmanifest_489830.acf`. Fields marked optional are only touched if Steam put them there.

| Field | Set to | Why |
| --- | --- | --- |
| `buildid` | Current public build ID | The number Steam compares against the public release to decide an update is needed. |
| `TargetBuildID` | Same build ID | The build Steam is working toward. Optional. |
| `manifest`, per installed depot | Current public GID for that depot | Steam checks each depot as well, so one stale GID is enough to trigger an update. |
| `StateFlags` | `4` | Marks the game fully installed, clearing any update required or update queued state. Read first: the script warns if the existing value shows an update that did not finish. |
| `AutoUpdateBehavior` | `1` | Only update this game when I launch it, so Steam will not start one on its own. |
| `UpdateResult` | `0` | Clears a recorded failure from an earlier update attempt. Optional. |
| `BytesToDownload`, `BytesDownloaded` | `0` | Resets Steam's download counters. Files already downloaded stay. Optional. |
| `StagingSize`, `BytesToStage`, `BytesStaged` | `0` | Resets Steam's staging counters. Staged files stay. Optional. |
| `ScheduledAutoUpdate` | `0` | Removes a scheduled update time. Optional. |

The file is then set read-only.

## Backups and repeated runs

The backup, `appmanifest_489830.acf.bak`, holds the app manifest exactly as it was immediately before the most recent edit. Each later edit replaces that single backup. It is not a backup of Skyrim itself.

If the app manifest already holds the right values, the script changes nothing and writes no backup. It still confirms that read-only protection is on.

## Important limitations

- Never use **Verify Integrity of Game Files** while preserving an older build. It is the one thing that inspects your actual game files, notices they are old, and re-downloads the new build over them. The read-only manifest does not stop it.
- Valve does not document or guarantee this method. Keep a separate copy of your working Skyrim folder. That is the real safety net.
- The script does not download, install, or select an older Skyrim version.
- SKSE and its plugins must match the Skyrim version you actually have installed, not the build number written into the app manifest.
- Start Skyrim through MO2 and SKSE rather than Steam's **Play** button. Steam writes app state to the manifest when it launches a game or has an update pending, so a read-only manifest produces harmless `Failed to write app state file` entries in Steam's log.
- If you have protected the manifest with an `icacls` Deny rule, remove it before running the script and restore it afterward.

## Where the release data comes from

The script needs two things: the build ID Steam currently advertises for Skyrim, and the manifest GID for each of your installed depots. It can get them three ways.

**Online.** A lookup through the [SteamCMD API](https://www.steamcmd.net/), a free, open-source third-party service with no affiliation to Valve or Steam. The request sends only Skyrim's public app ID, `489830`. It does not send your Steam account, your paths, your installed version, your language, or anything about your mods. The script validates the response before using any of it.

**Built in.** A release recorded inside the script, for working offline. It is whichever Skyrim release was the newest public one when the script was last updated, so it goes out of date as soon as Bethesda ships another patch. At the moment that is Skyrim `1.7.104`, Steam build `24914197`, released 27 August 2026. The script always shows you that date and warns you it may have been superseded, which is why the online lookup is offered first.

**Custom.** Numbers you supply yourself, from Steam's own console or SteamDB. See [Advanced](#advanced-find-and-supply-custom-release-ids).

Three safety checks default to No. The first applies only to the online lookup; the other two apply whichever source you use:

- If the online data is older than the release saved in the script, that suggests either a Valve rollback or a stale service, so the script asks before using it. `-AllowOlderOnlineRelease` answers Yes.
- If the build about to be written is lower than the one already in the manifest, the script asks before recording it, because a lower build can make Steam decide an update is needed. `-AllowLowerBuild` answers Yes.
- If `StateFlags` shows an update Steam did not finish, the script asks before recording the game as fully installed, because that can make a half-updated game folder permanent. `-AllowInterruptedUpdate` answers Yes.

## Command-line options

| Parameter | Purpose |
| --- | --- |
| `-SteamApps <path>` | Use a specific `steamapps` folder instead of searching for one. |
| `-ReleaseSource Prompt` | Ask the normal questions. This is the default. |
| `-ReleaseSource Online` | Use the online lookup without asking first. Stops if the lookup fails, or if you decline online data that looks older than the release saved in the script. |
| `-ReleaseSource BuiltIn` | Use the release saved in the script. Makes no network request. |
| `-ReleaseSource Custom` | Use values you supply, prompting for any you leave out. |
| `-CustomBuildId <id>` | Supply the public Steam build ID. |
| `-CustomManifests <hashtable>` | Supply public GIDs by installed depot ID. |
| `-NonInteractive` | Never ask. Questions take their default answer, and anything that cannot be decided safely stops with an error. For scheduled runs. |
| `-AllowOlderOnlineRelease` | Answer Yes to the first safety confirmation above. Skips no other check. |
| `-AllowLowerBuild` | Answer Yes to the second safety confirmation above. Skips no other check. |
| `-AllowInterruptedUpdate` | Answer Yes to the third safety confirmation above. Skips no other check. |

These examples run in PowerShell. If scripts are disabled, first run the `Set-ExecutionPolicy` line from [From PowerShell](#from-powershell).

```powershell
# Get current data without being asked about the source.
.\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1 -ReleaseSource Online

# Work entirely offline, using the release saved in the script.
.\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1 -ReleaseSource BuiltIn

# Point at a specific Steam library.
.\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1 -SteamApps 'D:\SteamLibrary\steamapps'
```

Supplying `-CustomBuildId` or `-CustomManifests` selects the custom source automatically when `-ReleaseSource` is omitted or set to `Prompt`. They cannot be combined with `-ReleaseSource Online` or `-ReleaseSource BuiltIn`. The script prompts only for the custom values you did not supply.

## Saving a log of the run

The script prints to the console, so `> log.txt` on its own saves an empty file. Use a transcript for an interactive run, or merge the output streams for an unattended one.

```powershell
# Interactive run.
Start-Transcript -Path skyrim-lock.log
.\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1
Stop-Transcript

# Unattended run.
.\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1 -NonInteractive *> skyrim-lock.log
```

## Advanced: find and supply custom release IDs

<details>
<summary>Show the steps</summary>

Use custom IDs when you would rather not use the online service and Steam has released a build newer than the one saved in the script.

Open Steam's console:

1. Press **Win+R**.
2. Enter `steam://open/console`.
3. Run:

```text
app_info_update 1
app_info_print 489830
```

`app_info_update 1` refreshes Steam's cached application metadata. The `1` tells Steam to update app information for all apps; it is not Skyrim's app ID. This command does not download or install Skyrim files.

`app_info_print 489830` prints Skyrim's refreshed app information. The output resembles JSON, but it uses Valve KeyValues format, also called VDF. It has nested quoted names and values without JSON colons or commas.

Find the public build ID at:

```text
depots > branches > public > buildid
```

Next, open your local `appmanifest_489830.acf` and find `InstalledDepots`. Use only the depot IDs inside that block. Do not add `SharedDepots` such as `228986` or `228990`.

For each installed depot, find its public GID in the console output at:

```text
depots > DEPOT_ID > manifests > public > gid
```

Common Skyrim depots are:

| Depot | Contents |
| --- | --- |
| `489831` | World data, including BSA and ESM files |
| `489832` | Core files |
| `489833` | `SkyrimSE.exe` |
| `489834` | French |
| `489835` | Italian |
| `489836` | German |
| `489837` | Spanish |
| `489838` | Russian |
| `489839` | Polish |
| `544860` | Traditional Chinese |
| `544861` | Japanese |

English installations normally contain only the three main depots. Other languages normally add one language depot.

An English custom command looks like this:

```powershell
$custom = @{
    ReleaseSource   = 'Custom'
    CustomBuildId   = 'PASTE_BUILD_ID'
    CustomManifests = @{
        '489831' = 'PASTE_GID' # Example: 4940892828028256588
        '489832' = 'PASTE_GID' # Example: 5728778377666085157
        '489833' = 'PASTE_GID' # Example: 4886117324142477814
    }
}
.\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1 @custom
```

For another language, include its installed language depot. You may also provide only some custom GIDs and let the script prompt for the missing ones. At a prompt, press Enter to skip a depot and leave its app-manifest entry unchanged, which is the answer for a depot that has no Skyrim public GID. The three main depots are required and cannot be skipped. `-NonInteractive` cannot ask, so it needs a GID for every installed depot. Extra depot IDs are rejected.

You can use the [SteamDB public depot page](https://steamdb.info/app/489830/depots/?branch=public) as an alternative reference. SteamDB calls the same value a manifest ID rather than a GID.

</details>
