# PrimeHunterHack
Inspired by [PrimeHack](https://forums.dolphin-emu.org/Thread-fork-primehack-fps-controls-and-more-for-metroid-prime), PrimeHunterHack aims to add native keyboard and mouse support to Metroid Prime Hunters in order to make the game play more like a traditional PC FPS shooter.

This relies on two custom lua libraries, `mouseControl.dll` and `windowProperties.dll`. They're very simple, but I've included the source code for to ease any concerns about malware.

# Main Features
- Mouselock (only active when the emulator is in focus and not in a menu/cutscene)
- Customizable controls (currently in different places)

# Setup
## Requirements
- [DeSmuME 0.9.13](https://github.com/TASEmulators/desmume/releases/tag/release_0_9_13)

## Getting Started
1. Download the latest release and extract the contents to the root directory of DeSmuME
2. Open DeSmuME, navigate to `Tools` > `Lua Scripting` > `New Lua Script Window...`
3. In the new script window, click `Browse...` and select the `mph_mem.lua` file you downloaded in the first step
4. Load up the game, navigate to the in-game `Options` > `Controls` and set the control type to `Dual Mode Right` (In-game sensitivity does not affect the mouse cursor sensitivity)

## Controls
In DeSmuME I have the following controls set:
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

# Potential Future Features?
- 64 bit support for latest version of DeSmuME
- Controller support
- Control remapping within the game's native options menu