extends KinematicBody2D

export var MASS = 5.0
var LIFETIME = 2.0
var vel = Vector2()
var team_index = -1

onready var explosion_particles = load("res://Prefabs/SnowballExplode.tscn")

func _physics_process(delta):
	#Tick away at lifetime and destroy if time runs out
	LIFETIME -= delta
	if(LIFETIME <= 0):
		_explode()
		pass
	#Apply movement to Node
	var apparent_vel = move_and_slide(vel, Vector2.UP)
	#If we're in the air apply gravity
	if(!is_on_floor() and !is_on_ceiling() and !is_on_wall()):
		vel.y += MASS
	#If we're touching something:
	else:
		#Run through every collision
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if(collision.get_collider().is_in_group("Snowball")):
				#If snowball is same team as us, stop colliding with it.
				if(collision.get_collider().get("team_index") == team_index):
					add_collision_exception_with(collision.get_collider())
				else:
					#Otherwise, explode it and myself
					get_slide_collision(i).get_collider()._explode()
					_explode()
					pass
			elif(collision.get_collider().is_in_group("Player")):
				#If player is on my team, add exception in collison
				if(collision.get_collider().get("team_index") == team_index):
					add_collision_exception_with(collision.get_collider())
					pass 
				else:
					#Otherwise, explode and damage player
					_explode()
					collision.get_collider().hurt(1, collision.normal, 50)
					pass
			else:
				_explode()

func _explode():
	#Spawn particles and set their colour to same as sprite's colour modulation
	var inst = explosion_particles.instance()
	inst.global_position = global_position
	inst.modulate = $Sprite.modulate
	#Add the particles to parent
	get_parent().add_child(inst)
	#Make sure they only emit once
	inst.one_shot = true
	#Destroy self
	queue_free()
