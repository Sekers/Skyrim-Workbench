# Downgrade Steam Skyrim Special Edition

This guide explains how to restore an earlier Steam version of Skyrim Special Edition after an unwanted update.

The worked example restores **Steam build 13189953**, which corresponds directly to **Skyrim Special Edition version 1.6.1170** (released on January 17, 2024). To restore a different version, use the build and depot manifest IDs for that release instead of the example values.

Use it if Steam has updated Skyrim and the new version is incompatible with your SKSE setup or version-dependent mods. These instructions apply only to the Steam release on Windows. They do not apply to GOG.

After the downgrade, use [Set-SteamSkyrimAcfBuildAndLock.ps1](../../scripts/steam/set-skyrim-acf-build-and-lock/README.md) to stop Steam from queuing, downloading, staging, or installing the unwanted update again.

## Choose the version to restore

Before downloading anything, identify and record:

- The Skyrim product version you want, such as `1.6.1170.0`.
- The Steam build ID corresponding to that release.
- The manifest ID for each required depot in that build.

Skyrim Special Edition uses Steam app ID `489830`. Its primary Windows depots are:

| Depot | Contents |
| --- | --- |
| `489831` | Main game data |
| `489832` | Core files |
| `489833` | `SkyrimSE.exe` |

Use the [Skyrim Special Edition depot history on SteamDB](https://steamdb.info/app/489830/depots/) or a documented manifest list to find IDs for the release you want. A Steam build ID identifies the complete release, but each depot has its own manifest ID. Do not put the build ID where a depot manifest ID is required.

## Worked example using version 1.6.1170

For the example target, Steam build `13189953` combines these depot manifests:

| Depot | Contents | Manifest for version 1.6.1170 |
| --- | --- | --- |
| `489831` | Main game data | `8442952117333549665` |
| `489832` | Core files | `8042843504692938467` |
| `489833` | `SkyrimSE.exe` | `1914580699073641964` |

All three example manifests must be used together to restore version `1.6.1170`. When targeting another release, use a matching set of manifests from that release. Mixing files from different releases can leave Skyrim unable to start or cause difficult compatibility problems.

## Before you begin

1. Close Skyrim, SKSE, Mod Organizer 2, Vortex, and any other program using the game folder.
2. Make a complete backup of `steamapps\common\Skyrim Special Edition`.
3. Back up your saves and settings from `Documents\My Games\Skyrim Special Edition`.
4. Back up your mod manager profiles if they are not already stored separately.
5. Make sure the Steam account currently signed in owns Skyrim Special Edition.
6. Allow enough free space for the three downloaded depots and a separate copy of the existing game folder.

Do not use **Verify Integrity of Game Files** during or after this process. It installs the version Steam currently offers and reverses the downgrade.

## If you already have a complete backup

A complete backup of the version you want is the simplest option.

1. Exit Steam completely, including the tray application.
2. Rename or move the current `Skyrim Special Edition` folder. Keep it until the restored installation is confirmed working.
3. Restore the complete backup to `steamapps\common\Skyrim Special Edition`.
4. Continue at [Verify the restored version](#verify-the-restored-version).

If you do not have a complete backup, use the Steam depot instructions below.

## Download the target version from Steam

### 1. Open the Steam Console

Steam must be running and signed in for the downloads.

1. Press **Win+R**.
2. Enter `steam://nav/console`.
3. Press **Enter**.
4. Select the new **Console** tab in Steam if it does not open automatically.

### 2. Download the required depots

The command format is:

```text
download_depot 489830 <depot ID> <manifest ID>
```

For the version `1.6.1170` example, enter the following commands one at a time. Wait for Steam to report **Depot download complete** before entering the next command.

```text
download_depot 489830 489831 8442952117333549665
download_depot 489830 489832 8042843504692938467
download_depot 489830 489833 1914580699073641964
```

The first two downloads are several gigabytes and may take a while. Steam does not always display useful progress while a depot is downloading.

For another target version, replace the three manifest IDs with the matching values you recorded for that release. Do not continue if any command reports a failed or incomplete download.

### 3. Locate the downloaded files

Steam prints the destination after each download finishes. The default location is usually:

```text
C:\Program Files (x86)\Steam\steamapps\content\app_489830
```

The folder should contain:

```text
depot_489831
depot_489832
depot_489833
```

The downloads may be stored under a different Steam folder even when Skyrim itself is installed in another library. Use the exact paths printed in the Steam Console.

### 4. Build a clean downgraded game folder

Using a clean folder prevents files that exist only in the newer release from remaining in the downgraded installation.

1. Exit Steam completely, including the tray application.
2. Open the Steam library folder containing Skyrim.
3. Rename the existing `steamapps\common\Skyrim Special Edition` folder to something such as `Skyrim Special Edition - Before Downgrade`.
4. Create a new empty folder named `Skyrim Special Edition` in `steamapps\common`.
5. Copy the contents of `depot_489831` into the new game folder.
6. Copy the contents of `depot_489832` into the same game folder.
7. Copy the contents of `depot_489833` into the same game folder.

Copy the contents of each depot folder, not the `depot_489831`, `depot_489832`, and `depot_489833` folders themselves.

If you use a non-English version, also download and install the matching historical language depot. The [Steam Manifest List on Nexus Mods](https://www.nexusmods.com/skyrimspecialedition/articles/6536) includes the language depot commands and configuration instructions.

## Verify the restored version

1. Open the restored `Skyrim Special Edition` folder.
2. Right-click `SkyrimSE.exe` and select **Properties**.
3. Open the **Details** tab.
4. Confirm that **Product version** matches the version you intended to restore. For the worked example, it should be `1.6.1170.0`.

If a different version is shown, stop and check that all three depot commands completed and that their contents were copied into the correct folder.

## Restore version-dependent components

Install the SKSE build and SKSE plugins made for the restored Skyrim version before loading a modded game. The [official SKSE Nexus page](https://www.nexusmods.com/skyrimspecialedition/mods/30379) identifies each package by its supported game version. For the `1.6.1170` example, SKSE `2.2.8` is the maintained build.

Root-level additions such as the SKSE loader, Engine Fixes files, ENB files, and other manually installed components must also be restored in versions compatible with the target game version.

The three base game depots do not restore every separately downloaded Creation Club file. If your setup uses Anniversary Upgrade or Creation Club content, restore compatible copies from your backup or follow the instructions supplied with your mod list.

Do not load an important save until the complete SKSE and mod setup is confirmed compatible. A save written by a newer game or mod configuration may not be safe to use with the restored setup.

## Lock the restored installation against updates

Do this before starting Skyrim again:

1. Open the [lockdown script instructions](../../scripts/steam/set-skyrim-acf-build-and-lock/README.md#before-you-start).
2. Exit Steam completely.
3. Run the [PowerShell script](../../scripts/steam/set-skyrim-acf-build-and-lock/Set-SteamSkyrimAcfBuildAndLock.ps1). It can retrieve the current public build and depot manifest IDs automatically.
4. Review the displayed changes and confirm that the manifest is read-only.
5. Start Skyrim through Mod Organizer 2 and SKSE instead of Steam's **Play** button.

The files on disk remain at the version you restored, but Steam's app manifest reports the current public build so Steam does not consider an update pending.

## Troubleshooting

### A depot download fails

Confirm that Steam is online, signed in to an account that owns Skyrim Special Edition, and that the previous depot download finished before retrying. Do not build the game folder from incomplete downloads.

### Skyrim crashes before the main menu after downgrading

A catalog created by the newer game may be incompatible with the restored version.

1. Open `%LOCALAPPDATA%\Skyrim Special Edition`.
2. Back up `ContentCatalog.txt` if it exists.
3. Rename it to `ContentCatalog.txt.newer-version.bak`.
4. Try starting the game again through SKSE.

Renaming instead of deleting the file makes this step reversible.

### SKSE reports an unsupported runtime

Check `SkyrimSE.exe` again and confirm that its product version matches your intended target. Then confirm that the installed SKSE package and every native SKSE plugin support that exact runtime.

### Steam wants to update Skyrim again

Do not allow the update to start. Exit Steam completely, run the lockdown script again, and confirm that `appmanifest_489830.acf` is read-only. Valve does not document or guarantee this method, so keep a separate backup of the working game folder.

## References

- [Steam Manifest List for Skyrim](https://www.nexusmods.com/skyrimspecialedition/articles/6536)
- [Skyrim Special Edition depots on SteamDB](https://steamdb.info/app/489830/depots/)
- [Official Skyrim Script Extender site](https://skse.silverlock.org/)
- [Official Skyrim Script Extender Nexus page](https://www.nexusmods.com/skyrimspecialedition/mods/30379)
