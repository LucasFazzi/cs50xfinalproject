extends KinematicBody2D

var speed = 350

onready var who_you_are

var local_player_object
var self_player_id
var enemy_player_id
export var player = []
export var enemy = []
var enemy_invisible
var pass_won
var collider_info_enemy

puppet var move_dir = Vector2()
puppet var pos = Vector2()
puppet var can_shot = false
puppet var info_sended = true
puppet var look_at = true
puppet var looking_for = 0
puppet var collider 
puppet var is_hit = false

func _ready():
	configure_rpc()
	players_info()

func _physics_process(delta):
	get_input_move()
	move_and_slide(move_dir)

func _process(delta):
	add_players()
	anim_pos()
	shoot()
	collider_hit()
	test_shoot()

func players_info():
	network.kinematic_type.append(self)
	local_player_object = self
	self.add_to_group("players")

func configure_rpc():
	rpc_config('who_you_are', 1)
	rpc_config ('is_hit', 1)
	rpc_config('enemy_invisible', 1)
	rpc_config('pass_won', 1)

func add_players():
	if self_player_id == null:
		self_player_id = network.player_id[0]
	else:
		pass
	if network.player_id.size() > 1:
		enemy_player_id = network.player_id[1]
	while network.kinematic_type.size() == 2:
		if self_player_id == 1:
			player = network.kinematic_type[0]
			enemy = network.kinematic_type[1]
			return
		elif self_player_id != 1:
			player = network.kinematic_type[1]
			enemy = network.kinematic_type[0]
			return

func get_input_move():
	move_dir = Vector2()

	if (is_network_master()):
		if Input.is_action_pressed('right'):
			if Input.is_action_pressed("up"):
				move_dir.x += 1
				move_dir.y -= 1

			if Input.is_action_pressed("down"):
				move_dir.x += 1
				move_dir.y += 1
			else:
				move_dir.x += 1

		elif Input.is_action_pressed('left'):
			if Input.is_action_pressed("up"):
				move_dir.x -= 1
				move_dir.y -= 1
				pass
			if Input.is_action_pressed("down"):
				move_dir.x -= 1
				move_dir.y += 1
			else:
				move_dir.x -= 1
		elif Input.is_action_pressed('down'):
			move_dir.y += 1

		elif Input.is_action_pressed('up'):
			move_dir.y -= 1

		move_dir = move_dir.normalized() * speed
		rset("pos", position)

	else:
		position = pos

func shoot():
	if (is_network_master()):
		if Input.is_action_pressed("shoot"):
			if can_shot == true:
				get_node("shot").play()
				can_shot = false

		if Input.is_action_just_released("shoot"):
			can_shot = true

func anim_pos():
	if (is_network_master()):
		if look_at == true:
			rset("looking_for", rotation_degrees)

			look_at(get_global_mouse_position())
			while Input.is_action_pressed("shoot"):
				get_node("player_sprite").play("shoot")
				return
			if Input.is_action_just_released("shoot"):
				get_node("player_sprite").play("idle")
			while move_dir.x != 0 or move_dir.y != 0 and not Input.is_action_pressed("shoot"):
				get_node("player_sprite").play("walk")
				return
			if move_dir.x == 0 and move_dir.y == 0 and not Input.is_action_pressed("shoot"):
				get_node("player_sprite").play("idle")

	else:
		rotation_degrees = looking_for

func collider_hit():
	if (is_network_master()):
		if can_shot == true:
			if get_node("weapons/weapon_1").is_colliding():
				collider = get_node("weapons/weapon_1").get_collider()
				test_shoot()
				can_shot = false

func test_shoot():
	if collider == local_player_object:
		pass
	elif collider != null and collider.is_in_group("players"):
		info_sended = true
		if info_sended == true:
			collider_info_enemy = collider
			rpc_id(enemy_player_id,'is_hit', true)
			is_hit(is_hit)
			clean()
			info_sended = false

func clean():
	collider = null

func is_hit(is_hit):
	var selfie = str(self)
	if is_hit == true:
		rpc_id(enemy_player_id,'who_you_are', selfie)
		who_you_are(who_you_are)
		is_hit = false

func who_you_are(who_you_are):
	if who_you_are != null:
		if str(self) != who_you_are:
			collider_info_enemy.visible = false
			rpc_id(enemy_player_id,'enemy_invisible', true)
			enemy_invisible(enemy_invisible)

func enemy_invisible(enemy_invisible):
	if enemy_invisible == true:
		if enemy != null:
			player.visible = false
			network.player_lost = self_player_id
			network.game_over = true
			rpc_id(enemy_player_id,'pass_won', true)
			pass_won(pass_won)
	else:
		pass

func pass_won(pass_won):
	if pass_won == true:
		network.game_over = true
		network.player_lost = enemy_player_id
	else:
		pass

func set_dominant_color(color):
	get_node("player_sprite").modulate = color
