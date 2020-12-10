extends KinematicBody2D

#Movement, gravity, and jumping stuff
export var MASS = 8.0
export var MAX_SPEED = 100.0
export var ACC = 8.0
export var DEC = 5.0

export var JUMP_FORCE = 120

var vel = Vector2()
var JUMP_TIME = 0.3
var on_player = false
var jump_time_counter = JUMP_TIME
var jumping = false

onready var og_gun_pos = $GunSprite.position


export var team = "blue"
var team_index
export var player_number = 1
#Set controls to be based on player number.
onready var left_input = "move_left_" + str(player_number)
onready var right_input = "move_right_" + str(player_number)
onready var jump_input = "jump_" + str(player_number)

onready var shoot_input = "shoot_" + str(player_number)

#Shooting stuff
var facing_dir = 1
onready var snowball_prefab = load("res://Prefabs/Snowball.tscn")
export var INITIAL_THROW_FORCE = 150.0
export var CHARGE_PER_FRAME = 5.0
export var MAX_THROW_FORCE = 300.0
var current_force = INITIAL_THROW_FORCE
export var RELOAD_TIME = 0.5
var can_shoot = true

#HEALTH
export var HEALTH = 10.0
var MAX_HEALTH = HEALTH

func _ready():
	#Duplicating the material of the player sprite so that when it's colour is changed with shader, it won't affect
	#every other player.
	var mat = $Sprite.get_material().duplicate()
	#Run through all the team names, looking for a match
	for i in range(len(TeamColoursInfo.teams)):
		if(team == TeamColoursInfo.teams[i]):
			#Set the material's team_color (param in bandana_changer.shader) to team_colour corresponding to team.
			mat.set_shader_param("team_color", TeamColoursInfo.colours[i])
			#Set the duplicate material as the actual sprite's material
			$Sprite.material = mat
			#Set the team index (used for spawning snowballs) to the current point in list
			team_index = i
			#Blue is already the colour for the gun sprite's details, so no need to change.
			if(team == "blue"):
				$GunSprite.material = null
			else:
				#Same duplication workaround used as with body sprite
				var gun_mat = $GunSprite.get_material().duplicate()
				#Set the gun sprite's new colour (found in blue_to_other_colour.shader) to team colour.
				gun_mat.set_shader_param("change_color", TeamColoursInfo.colours[i])
				#Apply material to sprite
				$GunSprite.material = gun_mat
			#No need to look for more teams if we already found ours.
			break
		else:
			#If no team was found, set the team_index to -1 (spawns white snowballs that are on nobody's team.
			team_index = -1

func _physics_process(delta):
	#Horizontal input
	var hor = Input.get_action_strength(right_input) - Input.get_action_strength(left_input)
	#Apply movement
	vel = move_and_slide(vel, Vector2.UP)
	#If not on floor, add to gravity, and play the idle animation, there's no actual falling animation because I'm lazy.
	if(!is_on_floor()):
		vel.y += MASS
		_play_anim("idle")
	#If not on floor, play the running animation if horizontal input is held, otherwise play idle. Also, set velocity to the mass so the player doesn't fly off with velocity from falling before.
	else:
		if(hor != 0):
			_play_anim("run")
		else:
			_play_anim("idle")
		vel.y = MASS
		
	#Add to horizontal movement by accelerating based on input. Also sprite flipping.
	if(hor > 0):
		facing_dir = 1
		$Sprite.flip_h = false
		$GunSprite.position.x = og_gun_pos.x
		vel.x += ACC
		if(vel.x > MAX_SPEED):
			vel.x = MAX_SPEED
	elif(hor < 0):
		facing_dir = -1
		$GunSprite.position.x = -og_gun_pos.x
		$Sprite.flip_h = true
		vel.x -= ACC
		if(vel.x < -MAX_SPEED):
			vel.x = -MAX_SPEED
	#If horizontal input axis is 0, decelerate based on the current horizontal velocity, will continue until vel.x is zero
	else:
		if(vel.x > 0):
			if(vel.x - DEC < 0):
				vel.x = 0
			else:
				vel.x -= DEC
		elif(vel.x < 0):
			if(vel.x + DEC > 0):
				vel.x = 0
			else:
				vel.x += DEC
	#While jump key is held, jump until time runs out for it.
	if(jumping and jump_time_counter < JUMP_TIME):
		vel.y = -JUMP_FORCE
		jump_time_counter += delta
		
	for i in range(get_slide_count()):
		var coll = get_slide_collision(i).get_collider()
		if(coll.is_in_group("Player")  and coll.position.x - position.x < 10 and coll.position.y - position.y > 4):	
			vel.y = -10
			_play_anim("idle")
			on_player = true
		else:
			on_player = false

func _process(delta):
	#Initiate jumping if on floor.
	if(Input.is_action_just_pressed(jump_input) and (is_on_floor() or on_player)):
		jumping = true
		jump_time_counter = 0
		on_player = false
	#If jump key let go or ceiling is hit, stop jumping.
	if(Input.is_action_just_released(jump_input) or is_on_ceiling()):
		jumping = false
		
	if(Input.is_action_pressed(shoot_input) and can_shoot):
		current_force += CHARGE_PER_FRAME
		if(current_force > MAX_THROW_FORCE):
			current_force = MAX_THROW_FORCE
		#Shake controller (intensity depends on how full charge shot is)
		Input.start_joy_vibration(player_number-1, current_force / MAX_THROW_FORCE - 0.5, current_force / MAX_THROW_FORCE - 0.5, 0.01)

	if(Input.is_action_just_released(shoot_input) and can_shoot):
		#When shoot button is released, shoot with current force. Reload time is based off of how powerful the shot is.
		shoot(current_force, RELOAD_TIME * current_force / MAX_THROW_FORCE + 0.1)
		#Reset throw force.
		current_force = INITIAL_THROW_FORCE
	else:
		$Crosshair.visible = false

func shoot(force, reload):
	#Can't shoot for now
	can_shoot = false
	#Play shoot animation on gun.
	$GunSprite/AnimationPlayer.play("shoot")
	#Instance of snowball
	var ball = snowball_prefab.instance()
	#Positioning and setting velocity.
	ball.global_position = $GunSprite/ShootPoint.global_position + Vector2((8*facing_dir), 0)
	ball.set("vel", Vector2(facing_dir, 0)*force + vel/2 - Vector2(0,70))
	#Set the team index of the snowball to this, so it'll only hurt those not on it's team
	ball.set("team_index", team_index)
	get_parent().add_child(ball)
	#Wait for reload to finish.
	yield(get_tree().create_timer(reload),"timeout")
	#We can shoot again!
	can_shoot = true
	#Vibrate controller a little to show that you can shoot again (2 small pulses)
	Input.start_joy_vibration(player_number - 1, 0.1, 0, 0.1)
	yield(get_tree().create_timer(0.1),"timeout")
	Input.start_joy_vibration(player_number - 1, 0.1, 0, 0.1)
	
func hurt(damage, knockback_direction, knockback_amount):
	HEALTH -= damage
	vel -= knockback_direction * knockback_amount
	for i in range(3):
		$Sprite.visible = false
		$GunSprite.visible = false
		yield(get_tree().create_timer(0.05), "timeout")
		$Sprite.visible = true
		$GunSprite.visible = true

#Function to play animations if they are not already playing on AnimPlayer so that they won't always be on frame 0 of the animation.
func _play_anim(anim):
	if($AnimationPlayer.current_animation != anim):
		$AnimationPlayer.play(anim)
