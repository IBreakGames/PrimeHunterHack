# PrimeHunterHack
Inspired by [PrimeHack](https://forums.dolphin-emu.org/Thread-fork-primehack-fps-controls-and-more-for-metroid-prime), PrimeHunterHack aims to add native keyboard and mouse support to Metroid Prime Hunters in order to make the game play more like a traditional PC FPS shooter.

This relies on two custom lua libraries, `mouseControl.dll` and `windowProperties.dll`. They're very simple, but I've included the source code to ease any concerns about malware.

# Main Features
- Mouselock (only active when the emulator is in focus and not in a menu/cutscene)
- Customizable controls (currently in different places)

# Setup
## Requirements
- [DeSmuME 0.9.13](https://github.com/TASEmulators/desmume/releases/tag/release_0_9_13)
- U.S. version of Metroid Prime Hunters

## Getting Started
1. Download the [latest release](https://github.com/IBreakGames/PrimeHunterHack/releases) and extract the contents to the root directory of DeSmuME
2. Open DeSmuME, open the ROM, navigate to the in-game `Options` > `Controls` and set the control type to `Dual Mode Right` (In-game sensitivity does not affect the mouse cursor sensitivity)
3. In the top settings bar, navigate to `Tools` > `Lua Scripting` > `New Lua Script Window...`
4. In the new script window, click `Browse...` and select the `mph_mem.lua` file you extracted in the first step

## Load Order After Initial Setup
1. Open the ROM
2. Load the `mph_mem.lua` script

## Controls
In DeSmuME I have the following `Control Config` set:
- `UP` is bound to `W`
- `LEFT` is bound to `A`
- `DOWN` is bound to `S`
- `RIGHT` is bound to `D`
- `B` is bound to `Up` (Up arrow key)
- `A` is bound to `Left` (Left arrow key)
- `Y` is bound to `Right` (Right arrow key)
- `X` is bound to `Down` (Down arrow key)
- `START` is bound to `Enter`
- `R` is bound to `Space`

This gives standard `WASD` movement and the arrow keys control the rotation of the map in the pause menu.

In the `Hotkey Config` under the `Savestate Slots` section, I recommend rebinding `Select Save Slot 1` through `Select Save Slot 3` to something else other than the `1`, `2`, and `3` keys.

For the rest of the controls, they're located towards the top of the of the `mph_mem.lua` file as part of the `keyConfig` table: 
```
keyConfig = {
    fire = 'leftclick',
    zoom = 'rightclick',
    morphBall = 'C',
    powerBeam = '1',
    missiles = '2',
    specialWeapon = '3',
    specialWeaponSelector = 'shift',
    scanVisor = 'F'
}
```
These can certainly be customized, but finding the names of the inputs can be a bit challenging.

Mouse sensitivity can be changed by adjusting the number of the `sensitivity` variable in the `mph_mem.lua` file.

# Known Bugs
- Menu detection isn't perfect when first loading the script
    - There are times where the script is loaded in that mouselock will be turned on and make it impossible to navigate menus
    - Current workaround is to `Alt` + `Tab` out of DeSmuME, stop the script in the script window, get back into gameplay, then restart the script. Once it starts working correctly I have yet to see it stop working correctly.
- Mouse stays locked during most in-game rendered cutscenes
    - Currently I have no intention of fixing this bug as it's pretty hilarious to watch Samus spin around frantically during these scenes

# Potential Future Features?
- Controller support
- Control remapping within the game's native options menu