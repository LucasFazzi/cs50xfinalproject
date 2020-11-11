# This source code is provided as reference/companion material for the Godot Multiplayer Setup tutorial
# that can be freely found at http://kehomsforge.com and should not be commercialized
# in any form. It should remain free!

# By Yuri Sarudiansky

extends CanvasLayer

func _ready():
	mainmenu_connect()

func mainmenu_connect():
	get_node("please_change_port_text").visible = false
	network.connect("server_created", self, "_on_ready_to_play")
	network.connect("join_success", self, "_on_ready_to_play")
	network.connect("join_fail", self, "_on_join_fail")

func set_player_info():
	if (!get_node("panelplayer/playername").text.empty()):
		gamestate.player_info.name = get_node("panelplayer/playername").text
	gamestate.player_info.char_color = get_node("panelplayer/color").color

func _on_create_pressed():
	# Properly set the local player information
	set_player_info()

	# Gather values from the GUI and fill the network.server_info dictionary
	if (!get_node("panelhost/servername").text.empty()):
		network.server_info.name = get_node("panelhost/servername").text
	network.server_info.max_players = int(get_node("panelhost/maxplayers").text)
	network.server_info.used_port = int(get_node("panelhost/port").text)

	# And create the server, using the function previously added into the code
	network.create_server()

func _on_join_pressed():
	# Properly set the local player information
	set_player_info()

	var port = int(get_node("paneljoin/joinport").text)
	var ip = get_node("paneljoin/joinip").text
	network.join_server(ip, port)

func _on_ready_to_play():
	get_tree().change_scene("res://scenes/mainworld.tscn")

func _on_join_fail():
	print("Failed to join server")
