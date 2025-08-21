
# Minecraft-Assembled

This project is a retro-style game developed in Assembly for the Introduction to Computer Systems (ISC) class at the University of Brasília (UnB), Spring 2023.

## About the Game

**Minecraft-Assembled** is a 2D adventure game inspired by Minecraft, implemented entirely in Assembly language. The player must navigate through multiple levels, collect keys, avoid or defeat enemies, and reach the exit door to progress.

## Features

- **Three unique levels** (phases), each with increasing difficulty
- **Playable character** with lives and score
- **Enemies:** Enderman, Creeper, Zumbi (Zombie)
- **Collectibles:** Keys, Enderpearls, Arrows
- **Obstacles:** Doors, Walls, Portals

## Installation & Running


1. **Requirements:**
	- [RARS](https://github.com/TheThirdOne/rars) (RISC-V Assembler and Runtime Simulator)
	- Java (required for RARS)

2. **How to Run:**
	- Download or clone this repository.
	- Open `game.s` in RARS.
	- Make sure all `.data` files are in the same directory as `game.s`.
	- Assemble and run the program in RARS.

## Controls

- Use the keyboard (arrow keys) to move the character.
- Collect keys to open doors and reach the portal to finish each level.
- Avoid or defeat enemies to survive.

## Game Specifications

- **Number of Levels:** 3
- **Player Lives:** 3 (represented by hearts)
- **Enemies:**
	- **Enderman**
	- **Creeper**
	- **Zumbi (Zombie)**
- **Collectibles:**
	- **Keys:** Needed to open doors
	- **Enderpearls, Arrows:** Special items for advanced levels
- **Objective:**
	- Collect the key, avoid or defeat enemies, and reach the door/portal to advance to the next level.

## File Structure

- `game.s` — Main game logic
- `*.data` — Sprite and level data files
- `sound.data` — Sound data for effects
- `frametest.s`, `soundtest.s` — Test files for frames and sound

## Authors & Credits

Developed for the Introduction to Computer Systems (ISC) class, University of Brasília (UnB), Spring 2023, by Artur Botelho and Marina Levay. 

---
Enjoy the game and good luck!
