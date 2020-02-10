# Nwgame

Simple real-time multi-player game

# Game mechanics

* The game is played in the browser
* The player is assigned a hero which is spawned on a random walkable tile. The hero is assigned a random name. The player can also choose a custom name for their hero
* If a player connects to the game with a name that already exists and is controlled by another player, both players control the same hero.
* Your hero can move freely over all empty/walkable tiles. They can also walk on tiles where enemies are already standing
* Each hero can attack everyone else within the radius of 1 tile around him (in all directions) + the tile they are standing on.
* If there are multiple enemies in range, all of them are attacked at the same time. One hit is enough to kill the enemy.
* If an enemy attacks you, your hero dies. When your hero is dead, it cannot perform any actions
* Every 5 seconds all dead heroes are removed (and randomly re-spawned if the player is still playing the game)
* Inactive players will respawn every 20 seconds until there are active players in the game
* When there are no active players for a minute the game will clean the map and all heroes

# Control keys

Arrows to move, Space to attack, other keys are ignored

In case of any possible errors, please refresh the browser

# Development

You need elixir annd erlang with versions from .tool-versions file installed on you machine

To run tests:

  * `mix test`
  * `mix credo`

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`
  * Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To build release:

  * `mix release`

Note:

Buidpack configuration files are removed, since deployemt `Gigalixir` or `Heroku` is not supported anymore.
Last production deployment of this game was done on Google Cloud Platform for simplicity of use and better performance.
