# Godot Platform Multiplayer with Nakama

![screenshot of current status](godot_multiplayer.gif)

## Required Software
* Godot 3.X (https://godotengine.org/download/3.x)
* Docker with docker compose plugin (https://www.docker.com/)

## How to run it locally
1. `$ cd nakama` and `$ docker compose up` to start local nakama server
2. Open project with Godot 3.X
3. Run local web server and open two instances of http://localhost:8060/tmp_js_export.html

## How to export to web
Change `singletons/connection_manager.gd` to reflect final nakama server address and port
Check https://docs.godotengine.org/pt-br/3.x/tutorials/export/exporting_for_web.html
