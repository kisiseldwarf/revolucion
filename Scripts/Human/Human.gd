extends KinematicBody2D

export var HP = 1
export var attack = 50
export var dying_time = 3
signal death
signal move_finished
export var velocity = 4
var last_direction = Vector2(0,0)
enum direction { UP, DOWN, RIGHT, LEFT}
var in_cinematic

#cinematic API
#use this when you want to code a cinematic
#cinematic prevents any control from the user
func cin_enable():
	in_cinematic = 1
func cin_disable():
	in_cinematic = 0
	#make the sprite look up
func look_up():
	last_direction = Vector2(0,-1)
	$AnimatedSprite.play("idle_up")
#make the sprite look down
func look_down():
	last_direction = Vector2(-1,1)
	$AnimatedSprite.play("idle")
#make the sprite look left
func look_left():
	last_direction = Vector2(-1,0)
	$AnimatedSprite.play("idle_left")
#make the sprite look right
func look_right():
	last_direction = Vector2(1,0)
	$AnimatedSprite.play("idle_right")
#make the sprite look in a certain direction.
#direction must be normalized and rounded.
func look(direction):
	match direction:
		Vector2(0,-1),Vector2(1,-1),Vector2(-1,-1):
			look_up()
		Vector2(0,1),Vector2(1,1),Vector2(-1,1):
			look_down()
		Vector2(1,0):
			look_right()
		Vector2(-1,0):
			look_left()
func know_direction():
	match last_direction:
		Vector2(0,-1),Vector2(1,-1),Vector2(-1,-1):
			return direction.UP
		Vector2(0,1),Vector2(1,1),Vector2(-1,1):
			return direction.DOWN
		Vector2(1,0):
			return direction.RIGHT
		Vector2(-1,0):
			return direction.LEFT
		_:
			return direction.DOWN

#movement animation script
func animation(direction):
	match direction:
		Vector2(0,0):
			look(last_direction)
		Vector2(1,0):
			$AnimatedSprite.play("side_walk_left")
			last_direction = direction
		Vector2(-1,0):
			$AnimatedSprite.play("side_walk_right")
			last_direction = direction
		Vector2(0,1):
			$AnimatedSprite.play("walk_down")
			last_direction = direction
		Vector2(0,-1):
			$AnimatedSprite.play("walk_up")
			last_direction = direction
		Vector2(1,1):
			$AnimatedSprite.play("walk_down")
			last_direction = direction
		Vector2(-1,1):
			$AnimatedSprite.play("walk_down")
			last_direction = direction
		Vector2(1,-1):
			$AnimatedSprite.play("walk_up")
			last_direction = direction
		Vector2(-1,-1):
			$AnimatedSprite.play("walk_up")
			last_direction = direction

#for in-game cinematic purpose ONLY (or maybe boss battles, but this is special...)
func move(point,speed):
	var direction = Vector2()
	direction = get_orientation(point)
	var absolute = position - point
	absolute = absolute.abs()
	while absolute > Vector2(1,1):
		move_and_slide(direction * speed)
		var direction_rounded = direction.round()
		animation(direction_rounded)
		yield(self,"new_physics_frame")
		absolute = position - point
		absolute = absolute.abs()
	emit_signal("move_finished")

#get the orientation towards the position
#used in move to know the orientation to follow to reach the point
func get_orientation(point):
	var direction = Vector2()
	direction.x = point.x - position.x
	direction.y = point.y - position.y
	return direction.normalized()

#TODO : Animation
func attack():
	var orientation = know_direction()
	var area_of_attack = Area2D.new()
	
	match orientation:
		direction.UP:
			area_of_attack = $Attack_Areas/Up
		direction.DOWN:
			area_of_attack = $Attack_Areas/Down
		direction.LEFT:
			area_of_attack = $Attack_Areas/Left
		direction.RIGHT:
			area_of_attack = $Attack_Areas/Right
	
	var bodies = area_of_attack.get_overlapping_bodies()
	for i in bodies:
		if i.is_in_group("Attackable"):
			i.take_damage(attack)

func take_damage(damage):
	HP = HP - damage
	if HP == 0:
		die()

#TODO : animation
func die():
	#play a death animation
	#wait a few seconds
	var dying = Timer.new()
	dying.wait_time = dying_time
	yield(dying.start(),"timeout")
	#erasing the player from existence
	emit_signal("death")
	free()