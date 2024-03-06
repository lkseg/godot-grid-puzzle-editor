- [Project](#Project)

<!--- ![](/misc/generator_example.png =512x512) -->
|Editor | Ingame |
|---|----|
|<img src="./misc/in_editor.png" alt="editor" width="518"/> | <img src="./misc/in_game.png" alt="game" width="518"/>|

<img src="./misc/clock_puzzle.png" alt="clock puzzle" width="300"/>

# Project

This project implements a in editor puzzle/grid editor which can be seen in *./addons/puzzle_editor*. Placable _scenes_ with their editor icon can be set in *settings.h*. 

New game objects must derive from Puzzle_Object.

Levels in scenes/levels are being automatically loaded and they must derive from Puzzle_Editor.
