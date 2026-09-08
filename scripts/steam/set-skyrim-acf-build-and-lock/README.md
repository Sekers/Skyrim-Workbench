# Keep an Older Steam Skyrim Version from Updating

`Set-SteamSkyrimAcfBuildAndLock.ps1` is for players who stay on an older Skyrim Special Edition version because a Steam update would break their SKSE setup or version-dependent mods.

Run it after restoring or downgrading Skyrim. It makes Steam treat the installed game as current and locks Steam's update record for Skyrim. While that record remains locked, Steam cannot queue, download, stage, or install the unwanted update.

This tool is only for the Steam version of Skyrim Special Edition on Windows.

## What it does

- Stops Steam from queuing, downloading, staging, or installing an unwanted Skyrim update while the update record remains locked.
- Makes Steam believe the installed game matches the current public release while leaving the older game files untouched.
- Sets Steam's update preference to update only when the game is launched.
- Clears stale values that can make Steam show an update as pending.
- Locks Steam's Skyrim update record as read-only when it finishes.
- Backs up that record only when something actually needs to change.
- Shows the old and new values so you can review exactly what changed.

## What it does not do

- It does not download or install an older Skyrim version.
- It does not back up the game itself.
- It does not make mismatched SKSE versions or SKSE plugins compatible.
- It does not protect the game if you use Steam's **Verify Integrity of Game Files** option.
- It does not work with the GOG version of Skyrim.

Complete the downgrade or restore first. Run this script afterward, before starting Steam again.

## Requirements

- PowerShell 5.1 or later
- The Steam version of Skyrim Special Edition
- The Steam depot manifests for the Skyrim version you want to use
- An SKSE version and SKSE plugins compatible with that Skyrim version

## Downgrade or restore Skyrim first

This script cannot put an older version of Skyrim on your computer. Complete that step before using it.

The [Steam Skyrim downgrade guide](../../../docs/steam/downgrade-steam-skyrim.md) explains how to restore a chosen version from a backup or with Steam's own depot downloads.

After the game files are restored, return here to configure and run the lockdown script before starting Steam again.

## Configuring the script

Open `Set-SteamSkyrimAcfBuildAndLock.ps1` and edit the `CONFIG` section:

- `$SteamApps` is the Steam library's `steamapps` folder that contains Skyrim.
- `$BuildId` is the build ID Steam is currently offering on the public branch.
- `$Manifests` contains the current public manifest ID for each depot listed under `InstalledDepots` in your local `appmanifest_489830.acf`.

The build and manifest IDs entered in the script must describe the current build Steam is offering, not the older build you restored. The script reports the current IDs to Steam while leaving the older game files untouched.

### Find the current public build ID

You can get the current build ID directly from Steam:

1. Press **Win+R**.
2. Enter `steam://open/console` and press **Enter**.
3. In Steam's **Console** tab, run:

```text
app_info_update 1
app_info_print 489830
```

`app_info_update 1` tells Steam to refresh its cached application information from Steam's servers. The `1` requests an update for all application information; it is not a game or app ID. This refresh helps prevent the next command from showing an older cached build ID or manifest IDs after Steam publishes a new Skyrim release.

This command refreshes Steam's metadata only. It does not download or install Skyrim game files. `app_info_print 489830` then displays the refreshed information for Skyrim Special Edition, whose Steam app ID is `489830`.

4. In the output, find `depots > branches > public > buildid`.

You can also open the [Skyrim Special Edition depots page on SteamDB](https://steamdb.info/app/489830/depots/) and read the build ID from the `public` row in the Branches table.

### Find the current public manifest IDs

The output resembles JSON, but it is Steam's Valve KeyValues format, commonly called VDF. It uses quoted names and values inside nested braces without JSON's colons or commas.

Do not copy every depot shown by `app_info_print`. The command describes all depots available for Skyrim, including other languages and shared components. Your local `appmanifest_489830.acf` identifies the subset installed on your computer.

First, open `appmanifest_489830.acf` in a text editor and find its `InstalledDepots` block. An abbreviated copy of this English installation contains:

```text
"InstalledDepots"
{
    "489831"
    {
        "manifest" "4940892828028256588"
    }
    "489832"
    {
        "manifest" "5728778377666085157"
    }
    "489833"
    {
        "manifest" "4886117324142477814"
    }
}
"SharedDepots"
{
    "228986" "228980"
    "228990" "228980"
}
"UserConfig"
{
    "language" "english"
}
```

This means `$Manifests` needs exactly the three IDs under `InstalledDepots`. The two IDs under `SharedDepots` are not added. English does not have a separate language depot because its files are included in the main Windows depots.

Next, return to the output from `app_info_print 489830`. Under `depots`, find each installed depot number, then follow `manifests > public > gid`. An abbreviated portion of the supplied English example looks like this:

```text
"depots"
{
    "489831"
    {
        "manifests"
        {
            "public"
            {
                "gid" "4940892828028256588"
            }
        }
    }
    "489832"
    {
        "manifests"
        {
            "public"
            {
                "gid" "5728778377666085157"
            }
        }
    }
    "489833"
    {
        "manifests"
        {
            "public"
            {
                "gid" "4886117324142477814"
            }
        }
    }
}
```

The outer number, such as `489831`, is the depot ID and becomes a key in `$Manifests`. The `gid` inside that depot's `public` block is its current manifest ID and becomes the corresponding value. For the example above, the script configuration is:

```powershell
$Manifests = [ordered]@{
    '489831' = '4940892828028256588'
    '489832' = '5728778377666085157'
    '489833' = '4886117324142477814'
}
```

These example IDs describe the public build at the time the output was captured. Always read fresh values before configuring the script for a later Steam release.

You can instead use the [SteamDB public depot page](https://steamdb.info/app/489830/depots/?branch=public). SteamDB calls the value a manifest ID, while the Steam Console calls it a `gid`. The `download_depot` command uses the same value as its third number, and the local ACF file stores it next to `manifest`.

The main Windows depots are:

| Depot | Contents |
| --- | --- |
| `489831` | World data, including BSA and ESM files |
| `489832` | Core files |
| `489833` | `SkyrimSE.exe` |

Language depots include:

| Depot | Language |
| --- | --- |
| `489834` | French |
| `489835` | Italian |
| `489836` | German |
| `489837` | Spanish |
| `489838` | Russian |
| `489839` | Polish |
| `544860` | Traditional Chinese |
| `544861` | Japanese |

Language depots appear in `app_info_print` with a `config > language` value. Include one only if its depot number also appears under `InstalledDepots` in your local ACF file. Adding a depot that is not present causes the script to stop with an error.

The console output also shows shared depots `228986` and `228990`. On this installation they appear under `SharedDepots`, not `InstalledDepots`, and they do not have their own `manifests > public > gid` values in Skyrim's app information. Do not add them to `$Manifests`.

When Steam releases another build, refresh the app information and copy the current public `gid` for every depot already listed in `$Manifests`. A depot ID stays the same across releases, while its manifest ID may change. Steam can reuse an unchanged depot manifest in a new build, so it is possible for an individual `gid` to remain the same.

## Running the script

1. Exit Steam completely.
2. Open PowerShell in the repository root.
3. Run:

```powershell
.\scripts\steam\set-skyrim-acf-build-and-lock\Set-SteamSkyrimAcfBuildAndLock.ps1
```

4. Review the displayed diff before starting Steam again.

If the manifest already contains the configured values, the script does not write a backup or rewrite the file. It still confirms that the manifest is read-only.

## Important limitations

- Never use **Verify Integrity of Game Files** while preserving an older build. Steam can replace the older game files regardless of the manifest's read-only flag.
- Valve does not document or guarantee the read-only manifest method, so it should not be your only protection.
- `appmanifest_489830.acf.bak` is only a backup of the manifest. It is not a backup of Skyrim.
- Start the game through MO2 and SKSE instead of Steam's **Play** button.
- Keep a separate copy of the working Skyrim installation folder.
