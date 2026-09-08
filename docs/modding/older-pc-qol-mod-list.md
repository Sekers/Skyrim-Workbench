# Quality of Life Skyrim Mod List for Older PCs

This is a practical Skyrim Special Edition mod setup for players who want a much better interface, more useful information, safer saving, and small gameplay conveniences without turning Skyrim into a demanding graphics showcase.

It stays fairly close to vanilla where the major parts of the game are concerned. The original quests, world, combat, progression, NPCs, and encounters remain largely unchanged. The most noticeable differences are the redesigned interface, convenience features, and performance-conscious visual refresh.

## Contents

- [Quality of Life Skyrim Mod List for Older PCs](#quality-of-life-skyrim-mod-list-for-older-pcs)
  - [Contents](#contents)
  - [Hardware used for this profile](#hardware-used-for-this-profile)
  - [Design goals](#design-goals)
  - [How close it stays to vanilla](#how-close-it-stays-to-vanilla)
  - [Installation and load order](#installation-and-load-order)
    - [Before installing](#before-installing)
    - [When order matters](#when-order-matters)
      - [Suggested left-pane order](#suggested-left-pane-order)
      - [Important left-pane relationships](#important-left-pane-relationships)
      - [Suggested plugin order](#suggested-plugin-order)
      - [Important right-pane relationships](#important-right-pane-relationships)
  - [Core fixes and game management](#core-fixes-and-game-management)
  - [Supporting frameworks](#supporting-frameworks)
  - [Interface, inventory, and HUD](#interface-inventory-and-hud)
  - [Gameplay and everyday convenience](#gameplay-and-everyday-convenience)
  - [Restrained graphics and performance improvements](#restrained-graphics-and-performance-improvements)
    - [Visual overwrite order used by the profile](#visual-overwrite-order-used-by-the-profile)
  - [What to remove first for more performance](#what-to-remove-first-for-more-performance)
  - [Compatibility reminders](#compatibility-reminders)

## Hardware used for this profile

The original profile ran at 1920 by 1080 on this older system:

| Component | Hardware |
| --- | --- |
| CPU | [Intel Core i7-3820](https://www.intel.com/content/www/us/en/products/sku/63698/intel-core-i73820-processor-10m-cache-up-to-3-80-ghz/specifications.html), 4 cores and 8 threads at 3.60 GHz with a 3.80 GHz maximum turbo frequency. Released in Q1 2012. |
| GPU | EVGA Superclocked NVIDIA GeForce GTX 660 Ti with 3 GB VRAM and a 980 MHz core clock. [Went on sale August 16, 2012](https://nvidianews.nvidia.com/news/nvidia-unveils-new-weapon-of-choice-for-gamers-the-nvidia-geforce-gtx-660-ti-gpu). |
| Memory | 16 GB DDR3-1600 |
| Storage | 256 GB [ADATA Premier Pro SP900](https://webapi3.adata.com/storage/downloadfile/1204011-datasheet-Premier%20Pro%20%20SP900-EN.pdf) 2.5-inch SATA III 6 Gb/s SSD. [North American availability was announced May 8, 2012](https://www.engadget.com/2012-05-09-adata-ships-premier-and-premier-pro-ssds-to-us.html). |
| Display | 1920 by 1080 |

This hardware is a useful reference point, not a formal minimum requirement or performance guarantee. Exact results depend on settings, resolution, background applications, and the rest of the mod setup.

## Design goals

- Improve inventory, crafting, looting, dialogue, navigation, and the HUD.
- Fix engine problems and improve frame pacing before adding visual mods.
- Use 1K or performance texture options where available.
- Improve broad parts of the game with a small number of visual packages.
- Preserve Skyrim's original quests, world layout, combat, character progression, NPCs, and encounter design.
- Avoid ENB, 4K texture packs, dense grass mods, heavy tree overhauls, large city expansions, and population increases.
- Keep the setup appropriate for a 3 GB graphics card at 1080p.

## How close it stays to vanilla

This is a vanilla-plus setup in terms of content and overall game design. It does not add new lands, quest lines, cities, factions, followers, enemy populations, combat systems, perk trees, magic systems, or major survival mechanics. A playthrough still follows the original Skyrim world, stories, progression, and encounters.

The largest changes are to presentation and convenience:

- [Unofficial Skyrim Special Edition Patch](https://www.nexusmods.com/skyrimspecialedition/mods/266) fixes a very large number of bugs, but it also changes some quests, dialogue, NPCs, items, mechanics, and world details. Some of its decisions are controversial among players who prefer a stricter interpretation of vanilla behavior. Review the [project's official changelog](https://www.afkmods.com/Unofficial%20Skyrim%20Special%20Edition%20Patch%20Version%20History.html) before deciding whether it fits the experience you want.
- SkyUI, QuickLoot IE, Aura's Inventory Tweaks, TrueHUD, Compass Navigation Overhaul, and the related interface mods make menus and on-screen information noticeably different from vanilla.
- Skyland, SMIM, Enhanced Rocks and Mountains, and the snow and water packages refresh much of the scenery, but they retain Skyrim's original locations and art direction. The profile uses restrained texture options rather than expensive lighting or environment overhauls.
- Weightless NG changes carry-weight balance by making selected item categories weightless. Disable categories in its configuration or omit the mod if preserving vanilla inventory balance is important.
- Anniversary Edition Content Picker changes which owned Creation Club additions are present, but it does not rewrite the base game.

Most of the remaining mods fix bugs, expose information the game already tracks, reduce repetitive menu actions, or support another listed mod. Players who want the strictest vanilla behavior should review USSEP's changes and disable or omit the Weightless NG categories that affect the balance they want to preserve. Check the requirements of other mods before omitting USSEP.

## Installation and load order

### Before installing

- Use Mod Organizer 2 so each mod remains isolated and reversible.
- Install the SKSE release that matches your installed Skyrim runtime.
- Read the Requirements section on every linked mod page.
- Download files that explicitly support your installed Skyrim runtime.
- Start with the suggested left-pane and plugin orders below. If the instructions for a current mod release differ, follow the current instructions and recheck its requirements and conflicts.

### When order matters

The order below is the suggested starting point when recreating the setup. It also makes the intended file winners and plugin relationships easier to reproduce.

Mod Organizer 2 has two different kinds of order:

- The **left pane** controls file priority. With the normal ascending Priority view, a mod lower in the pane has a higher priority and its files win conflicts.
- The **right pane** controls ESM, ESP, and ESL plugin load order. A plugin loaded later can override records from one loaded earlier.

[LOOT](https://loot.github.io/) sorts the right-pane plugins. It does not decide which loose meshes, textures, DLLs, interface files, or configuration files win in the left pane. LOOT can be run through MO2's built-in **Sort** function or as a standalone application. For most mod lists, both produce similar plugin sorting results, though the standalone application may include newer features, diagnostics, and bug fixes. For more information, see the [official LOOT documentation](https://loot.github.io/docs/) and the [Mod Organizer 2 plugin management doc](https://deepwiki.com/ModOrganizer2/modorganizer/4-plugin-management#loot-integration).

#### Suggested left-pane order

Place the enabled mods in this order from top to bottom in MO2's left pane. The list runs from lower priority to higher priority, so a later entry wins when two mods provide the same file. MO2 normally keeps the official game and Creation Club entries above these mods.

| Priority | Mod |
| ---: | --- |
| 1 | Anniversary Edition Content Picker |
| 2 | Unofficial Skyrim Special Edition Patch |
| 3 | Unofficial Skyrim Creation Club Content Patches |
| 4 | Address Library for SKSE Plugins |
| 5 | SSE Engine Fixes (skse64 plugin) |
| 6 | Media Keys Fix SKSE |
| 7 | powerofthree's Tweaks |
| 8 | SSE Display Tweaks |
| 9 | PapyrusUtil SE - Modders Scripting Utility Functions |
| 10 | Base Object Swapper |
| 11 | Lightened Skyrim - Base Object Swapper edition |
| 12 | SkyUI |
| 13 | SkyUI 5.2 SE Plugin with Master Added |
| 14 | Quest Journal Fixes |
| 15 | Fix Note Icon for SkyUI (**disable** when using Aura's Inventory Tweaks)
| 16 | SkyUI - Ghost Item Bug Fix |
| 17 | Remember Lockpick Angle - Updated |
| 18 | Static Mesh Improvement Mod |
| 19 | SMIM SE 'Farming Creation Club' Patch |
| 20 | Skyland AIO - 1k |
| 21 | Skyland Bits and Bobs - A Clutter Overhaul - Performance |
| 22 | ERM - Enhanced Rocks and Mountains |
| 23 | Security Overhaul SKSE - Lock Variations |
| 24 | Vanilla Plus Writing Purity Patch |
| 25 | Water Mod - SoS |
| 26 | Simplicity of the Sea 1k textures |
| 27 | Simplicity of Snow |
| 28 | Infinity UI |
| 29 | Compass Navigation Overhaul |
| 30 | Dialogue Interface ReShaped |
| 31 | OxygenMeter2 |
| 32 | QuickLoot IE - A QuickLoot EE Fork |
| 33 | Inventory Interface Information Injector (I4) |
| 34 | MCM Helper |
| 35 | moreHUD Inventory Edition - BSA Version |
| 36 | TrueHUD - HUD Additions |
| 37 | TrueHUD Curated Bosses |
| 38 | TrueHud playerWidget improvement |
| 39 | STB Widgets |
| 40 | Keyword Item Distributor (KID) |
| 41 | B.O.O.B.I.E.S (aka Immersive Icons) - Aura's Inventory Tweaks install |
| 42 | FormList Manipulator - FLM |
| 43 | Spell Perk Item Distributor |
| 44 | Object Categorization Framework (OCF) |
| 45 | moreHUD SE - ESL |
| 46 | Constructible Object Custom Keyword System (C.O.C.K.S) |
| 47 | The Handy Icon Collection Collective |
| 48 | Aura's Inventory Tweaks |
| 49 | Favorite Misc Items |
| 50 | Essential Favorites |
| 51 | Double Check Before Selling |
| 52 | Double Check Before Selling AE |
| 53 | JContainers SE |
| 54 | NL_MCM - A Modular MCM Framework |
| 55 | Regional Save Names |
| 56 | Skyrim Save System Overhaul 3 (SSSO 3) |
| 57 | Unread Books Glow SSE with MCM |
| 58 | Weightless NG |
| 59 | I'm Walkin' Here NG with Pets |
| 60 | Skyland LODs |

#### Important left-pane relationships

The suggested order above establishes these intentional file winners. If you customize the order, keep each item in the right column later and at a higher priority than the related item in the left column.

| Earlier | Later, higher-priority winner | Reason |
| --- | --- | --- |
| SkyUI | SkyUI 5.2 SE Plugin with Master Added | The replacement `SkyUI_SE.esp` must overwrite the original SkyUI plugin. |
| SkyUI and any journal interface files | Quest Journal Fixes | Its corrected `quest_journal.swf` must remain active. |
| Inventory Interface Information Injector | The Handy Icon Collection Collective | The profile uses THICC's shared `icons.swf` instead of the copy supplied by I4. |
| TrueHUD | TrueHUD Player Widget Improvement | The improvement intentionally replaces TrueHUD widget files. |
| Double Check Before Selling | Double Check Before Selling AE | The AE package replaces the original DLL with its newer-runtime equivalent. |
| Water Mod | Simplicity of the Sea 1K Textures | The 1K water textures are the intended final files for the older GPU profile. |
| Static Mesh Improvement Mod | SMIM Farming Creation Club Patch | The compatibility patch must overwrite the files it corrects. |
| Skyland AIO | Skyland LODs | The supplied distant textures and generated files must match and complete the Skyland setup. |

Aura's Inventory Tweaks should have higher left-pane priority than its supporting interface packages, including I4, KID, OCF, THICC, C.O.C.K.S, and the AIT installation of B.O.O.B.I.E.S. This lets the selected AIT integration files win where they overlap.

The complete visual priority sequence from the source profile is listed under [Visual overwrite order used by the profile](#visual-overwrite-order-used-by-the-profile).

#### Suggested plugin order

After Skyrim's official masters and the enabled Creation Club files, use this order for the profile's 18 nonofficial plugins. The first plugin shown loads earliest and the last loads latest.

| Load position | Plugin |
| ---: | --- |
| 1 | `unofficial skyrim special edition patch.esp` |
| 2 | `unofficial skyrim creation club content patch.esl` |
| 3 | `AHZmoreHUDInventory.esl` |
| 4 | `TrueHUD.esl` |
| 5 | `OCF.esp` |
| 6 | `AHZmoreHUD.esl` |
| 7 | `SkyUI_SE.esp` |
| 8 | `SMIM-SE-Merged-All.esp` |
| 9 | `VanillaPlusWritingPurityPatch.esp` |
| 10 | `water mod.esp` |
| 11 | `Simplicity of Snow.esp` |
| 12 | `QuickLootIE.esp` |
| 13 | `I4IconAddon.esp` |
| 14 | `MCMHelper.esp` |
| 15 | `AIT.esp` |
| 16 | `Safe Save System Overhaul 3.esp` |
| 17 | `UnreadBooksGlow.esp` |
| 18 | `Occlusion.esp` |

This is a known-working order for the listed profile, not a universal order for every combination of mods. Adding, removing, or updating a plugin can introduce new masters or compatibility rules.

#### Important right-pane relationships

- `unofficial skyrim creation club content patch.esl` loads after `unofficial skyrim special edition patch.esp`.
- `AIT.esp` loads after `OCF.esp`, `I4IconAddon.esp`, and `MCMHelper.esp` in the source profile.
- `Occlusion.esp` from Skyland LODs loads last among the profile's non-official plugins.
- Compatibility patches should load after the plugins they are designed to patch.

The suggested plugin order already reflects the source profile's working LOOT result and deliberate adjustments. Run LOOT after adding, removing, or updating plugins, then review its warnings and compare the result with this list. Preserve the relationships above unless a current mod version publishes different requirements.

## Core fixes and game management

These provide the stability and update control that the rest of the setup depends on.

| Mod | What it provides |
| --- | --- |
| [Anniversary Edition Content Picker](https://www.nexusmods.com/skyrimspecialedition/mods/58890) | Lets you choose which owned Creation Club items are included instead of loading all of them. Skip it if you do not use Anniversary Upgrade content. |
| [Unofficial Skyrim Special Edition Patch](https://www.nexusmods.com/skyrimspecialedition/mods/266) | Fixes a large collection of quests, objects, scripts, and other base game problems. Use a file compatible with your installed Skyrim release and Creation Club content. |
| [Unofficial Skyrim Creation Club Content Patches](https://www.nexusmods.com/skyrimspecialedition/mods/18975) | Fixes Creation Club content used by the profile. Install only the patches that match content you own and enable. |
| [SSE Engine Fixes](https://www.nexusmods.com/skyrimspecialedition/mods/17230) | Corrects engine bugs and improves stability. It also allows Steam achievements while mods are active. Install all required parts exactly as its instructions specify. |
| [powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073) | Adds configurable engine fixes and quality improvements without a large plugin footprint. |
| [SSE Display Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/34705) | Improves frame pacing, borderless display behavior, and high frame rate physics. Its optional display can show FPS, frame time, and VRAM use in game. |
| [Media Keys Fix SKSE](https://www.nexusmods.com/skyrimspecialedition/mods/92948) | Keeps keyboard media controls working while Skyrim is active. |

## Supporting frameworks

These mostly work behind the scenes. Install the ones required by the user-facing mods you select.

| Mod | Why it is present |
| --- | --- |
| [Address Library for SKSE Plugins](https://www.nexusmods.com/skyrimspecialedition/mods/32444) | Lets compatible SKSE plugins find the correct game functions for your installed Skyrim runtime. |
| [Base Object Swapper](https://www.nexusmods.com/skyrimspecialedition/mods/60805) | Lets mods replace selected world objects without editing cells directly. |
| [FormList Manipulator](https://www.nexusmods.com/skyrimspecialedition/mods/74037) | Lets mods add or remove form-list entries through configuration files. |
| [Inventory Interface Information Injector](https://www.nexusmods.com/skyrimspecialedition/mods/85702) | Supplies extra item information and icons to compatible inventory interfaces. |
| [Infinity UI](https://www.nexusmods.com/skyrimspecialedition/mods/74483) | Provides shared interface features used by newer UI mods. |
| [JContainers SE](https://www.nexusmods.com/skyrimspecialedition/mods/16495) | Provides structured data storage used by scripted mods. |
| [Keyword Item Distributor](https://www.nexusmods.com/skyrimspecialedition/mods/55728) | Adds item keywords from configuration files without compatibility patches for every item mod. |
| [MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000) | Gives compatible mods better configuration menus and saved settings. |
| [NL_MCM](https://www.nexusmods.com/skyrimspecialedition/mods/49127) | Supplies the modular configuration menu used by Skyrim Save System Overhaul 3. |
| [Object Categorization Framework](https://www.nexusmods.com/skyrimspecialedition/mods/81469) | Gives inventory and crafting mods a shared system for categorizing items. |
| [PapyrusUtil SE](https://www.nexusmods.com/skyrimspecialedition/mods/13048) | Supplies additional scripting and data functions used by other mods. |
| [Spell Perk Item Distributor](https://www.nexusmods.com/skyrimspecialedition/mods/36869) | Lets mods distribute spells, perks, items, and related data without editing every affected record. |

## Interface, inventory, and HUD

This is the heart of the profile. These mods make common actions faster and expose information that the original interface hides.

| Mod | What improves for the player |
| --- | --- |
| [SkyUI](https://www.nexusmods.com/skyrimspecialedition/mods/12604) | Replaces the console-oriented menus with searchable, sortable PC interfaces and provides the Mod Configuration Menu. |
| [SkyUI 5.2 SE Plugin with Master Added](https://www.nexusmods.com/skyrimspecialedition/mods/67166) | Prevents Skyrim or Steam launch behavior from disabling `SkyUI_SE.esp`. Install it over the original SkyUI plugin. |
| [SkyUI Ghost Item Bug Fix](https://www.nexusmods.com/skyrimspecialedition/mods/49106) | Prevents invisible or stale inventory entries created by a SkyUI bug. |
| [Quest Journal Fixes](https://www.nexusmods.com/skyrimspecialedition/mods/108618) | Fixes quest journal behavior, including difficulty settings that fail to remain selected. |
| [Dialogue Interface ReShaped](https://www.nexusmods.com/skyrimspecialedition/mods/46546) | Makes dialogue choices easier to read and select with a mouse. |
| [Compass Navigation Overhaul](https://www.nexusmods.com/skyrimspecialedition/mods/74484) | Adds useful quest and location information to the compass. |
| [QuickLoot IE](https://www.nexusmods.com/skyrimspecialedition/mods/120075) | Lets you inspect and take container contents without opening a full inventory screen. |
| [moreHUD SE](https://www.nexusmods.com/skyrimspecialedition/mods/12688) | Shows extra information about targeted objects without opening another menu. |
| [moreHUD Inventory Edition](https://www.nexusmods.com/skyrimspecialedition/mods/18619) | Adds useful item details to inventory menus, helping with comparison and collection decisions. |
| [TrueHUD](https://www.nexusmods.com/skyrimspecialedition/mods/62775) | Adds configurable actor information, floating health bars, and boss bars. |
| [TrueHUD Curated Bosses](https://www.nexusmods.com/skyrimspecialedition/mods/53406) | Gives appropriate encounters TrueHUD boss bars without treating every strong enemy as a boss. |
| [TrueHUD Player Widget Improvement](https://www.nexusmods.com/skyrimspecialedition/mods/120251) | Refines the appearance and behavior of the TrueHUD player display. |
| [Oxygen Meter 2](https://www.nexusmods.com/skyrimspecialedition/mods/64532) | Shows remaining breath while swimming underwater. |
| [STB Widgets](https://www.nexusmods.com/skyrimspecialedition/mods/136148) | Displays useful combat values such as resistances, movement speed, equipped attacks, and related status information. |
| [Aura's Inventory Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/68557) | Makes SkyUI inventories easier to scan and organize with improved categories, columns, and icons. |
| [B.O.O.B.I.E.S, also known as Immersive Icons](https://www.nexusmods.com/skyrimspecialedition/mods/89241) | Gives many item types distinct icons so large inventories are easier to understand at a glance. Use the Aura's Inventory Tweaks installation option. |
| [The Handy Icon Collection Collective](https://www.nexusmods.com/skyrimspecialedition/mods/90508) | Provides the shared icon assets used by the inventory and crafting interface mods. It does nothing by itself. |
| [Constructible Object Custom Keyword System](https://www.nexusmods.com/skyrimspecialedition/mods/81409) | Replaces crowded crafting lists with useful, extensible categories. |

**Note:** [Fix Note Icon for SkyUI](https://www.nexusmods.com/skyrimspecialedition/mods/32561) is not needed when using Aura's Inventory Tweaks.

## Gameplay and everyday convenience

These reduce recurring annoyances without trying to redesign Skyrim's combat, quests, or balance as a whole.

| Mod | What improves for the player |
| --- | --- |
| [I'm Walkin' Here NG with Pets](https://www.nexusmods.com/skyrimspecialedition/mods/122516) | Stops followers, summons, and pets from blocking doorways or pushing the player during dialogue. |
| [Weightless NG](https://www.nexusmods.com/skyrimspecialedition/mods/93796) | Removes weight from selected item categories through a configurable SKSE plugin, avoiding broad record conflicts. |
| [Unread Books Glow](https://www.nexusmods.com/skyrimspecialedition/mods/20679) | Makes books you have not read easier to identify in the world. |
| [Skyrim Save System Overhaul 3](https://www.nexusmods.com/skyrimspecialedition/mods/122343) | Replaces the basic save process with configurable timed, rotating, and event-based saves. Follow its instructions and do not mix its save management with older SSSO versions. |
| [Regional Save Names](https://www.nexusmods.com/skyrimspecialedition/mods/49698) | Gives outdoor saves meaningful regional names instead of labeling nearly everything as Skyrim. |
| [Double Check Before Selling](https://www.nexusmods.com/skyrimspecialedition/mods/103597) | Warns before accidentally selling equipped or favorited items. Install this base package before the AE support package below. |
| [Double Check Before Selling AE](https://www.nexusmods.com/skyrimspecialedition/mods/103735) | Provides the newer-runtime DLL for Double Check Before Selling. |
| [Essential Favorites](https://www.nexusmods.com/skyrimspecialedition/mods/42997) | Protects favorited items from actions that would unintentionally remove or lose them. |
| [Favorite Misc Items](https://www.nexusmods.com/skyrimspecialedition/mods/42750) | Allows useful miscellaneous items to participate in Skyrim's favorites system. |
| [Remember Lockpick Angle](https://www.nexusmods.com/skyrimspecialedition/mods/26838) | Preserves the last lockpick angle after a pick breaks, reducing repetitive repositioning. |
| [Security Overhaul SKSE, Lock Variations](https://www.nexusmods.com/skyrimspecialedition/mods/58224) | Gives locks visual variety without a large environment overhaul. |
| [Vanilla Plus Writing Purity Patch](https://www.nexusmods.com/skyrimspecialedition/mods/51232) | Corrects and standardizes text while trying to preserve Bethesda's original writing style. |

## Restrained graphics and performance improvements

These improve a large amount of scenery without relying on ENB or high-resolution texture packs. The profile deliberately uses the 1K or performance option when one is available.

| Mod | Performance approach |
| --- | --- |
| [Lightened Skyrim, Base Object Swapper edition](https://www.nexusmods.com/skyrimspecialedition/mods/111475) | Removes selected objects that are hidden or unnecessary, reducing work for the game without editing cells or adding a plugin. |
| [Static Mesh Improvement Mod](https://www.nexusmods.com/skyrimspecialedition/mods/659) | Improves many visibly low-detail object meshes. Use conservative installer choices if performance is more important than maximum detail. |
| [SMIM Farming Creation Club Patch](https://www.nexusmods.com/skyrimspecialedition/mods/659) | Keeps the installed SMIM choices compatible with the Farming Creation Club content used by the source profile. |
| [Skyland AIO](https://www.nexusmods.com/skyrimspecialedition/mods/34179) | Replaces architecture and landscape textures across most of Skyrim while the 1K option limits VRAM demand. |
| [Skyland Bits and Bobs](https://www.nexusmods.com/skyrimspecialedition/mods/95032) | Improves clutter textures using the lighter package intended for lower-spec systems. |
| [Enhanced Rocks and Mountains](https://www.nexusmods.com/skyrimspecialedition/mods/85196) | Improves rock and mountain shapes and blending without adding dense vegetation or new locations. |
| [Water Mod](https://www.nexusmods.com/skyrimspecialedition/mods/56520) | Improves water appearance and shoreline blending with a small, focused plugin and texture set. |
| [Simplicity of the Sea 1K Textures](https://www.nexusmods.com/skyrimspecialedition/mods/98993) | Keeps the selected water appearance while replacing its textures with a lighter 1K set. |
| [Simplicity of Snow](https://www.nexusmods.com/skyrimspecialedition/mods/56235) | Improves snow coverage and reduces the shiny white-paint look without a broad worldspace overhaul. |
| [Skyland LODs](https://www.nexusmods.com/skyrimspecialedition/mods/87412) | Makes distant terrain and architecture match Skyland AIO. This is optional and is one of the first visual additions to remove if storage, VRAM, or distant-view performance is a concern. |

### Visual overwrite order used by the profile

For the visual portion, this is the useful low-to-high priority sequence. Items later in the list should win file conflicts in Mod Organizer 2:

1. Static Mesh Improvement Mod
2. SMIM Farming Creation Club Patch
3. Skyland AIO 1K
4. Skyland Bits and Bobs Performance
5. Enhanced Rocks and Mountains
6. Water Mod
7. Simplicity of the Sea 1K Textures
8. Simplicity of Snow
9. Skyland LODs

Lightened Skyrim uses Base Object Swapper configuration rather than serving as a broad texture overwrite, so it does not need a specific place in that visual conflict sequence.

## What to remove first for more performance

The interface, fixes, and small SKSE quality-of-life plugins are generally the point of this setup. Reduce the visual layer first if the game exceeds the VRAM budget or cannot maintain the desired frame rate.

Try these changes in order:

1. Remove Skyland LODs.
2. Use lighter SMIM installer choices or remove SMIM.
3. Remove Enhanced Rocks and Mountains.
4. Keep Skyland AIO and Bits and Bobs on their 1K or Performance packages.
5. Lower shadow distance and resolution before lowering ordinary texture quality further.
6. Use SSE Display Tweaks to watch FPS, frame time, and VRAM while testing the same demanding location.

Do not evaluate performance from a single indoor room. Test a busy city, a forest, an open mountain view, combat, and rapid camera movement.

## Compatibility reminders

- Confirm every SKSE DLL explicitly supports your installed Skyrim runtime.
- SSE Engine Fixes includes a second, manually installed component outside the normal MO2 mod folder.
- The SkyUI plugin with a master added must overwrite the original `SkyUI_SE.esp`.
- Double Check Before Selling AE must overwrite the original Double Check Before Selling files.
- The B.O.O.B.I.E.S package should use its Aura's Inventory Tweaks installation option.
- Install only Creation Club patches for content that is actually present.
- Re-run LOOT after changing mods, then review its warnings instead of accepting the result blindly.
- Start a new game when a mod author requires one. Do not assume every gameplay or save-system change is safe to add or remove mid-playthrough.
