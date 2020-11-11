# This source code is provided as reference/companion material for the Godot Multiplayer Setup tutorial
# that can be freely found at http://kehomsforge.com and should not be commercialized
# in any form. It should remain free!
#
# By Yuri Sarudiansky

extends Node

var player_info = {
	name = "Player",                   # How this player will be shown within the GUI
	net_id = 1,                        # By default everyone receives "server" ID
	actor_path = "res://scenes/player.tscn",  # The class used to represent the player in the game world
	char_color = Color(1, 1, 1),       # By default don't modulate the icon color
}
