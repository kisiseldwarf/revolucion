extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var HP = 100
signal death
signal spacebar_pressed
signal dialog_end
export var velocity = 4
export var text = PoolStringArray()
var last_direction = Vector2(0,0)
export var voice:AudioStreamSample
enum direction { UP, DOWN, RIGHT, LEFT}

# Called when the node enters the scene tree for the first time.
func _ready():
	if HP == 0:
		die()

func _process(delta):
	pass

func _physics_process(delta):
	var direction = Vector2(0,0)
	animation(direction)

#movement animation script ( /!\ )
func animation(direction):
	match direction:
		Vector2(0,0):
			match last_direction:
				Vector2(1,0):
					$AnimatedSprite.play("idle_right")
				Vector2(-1,0):
					$AnimatedSprite.play("idle_left")
				Vector2(0,-1),Vector2(1,-1),Vector2(-1,-1):
					$AnimatedSprite.play("idle_up")
				_:
					$AnimatedSprite.play("idle")
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

#die script
func die():
	#play a death animation
	#wait a few seconds
	yield(get_tree().create_timer(3),"timeout")
	#erasing the player from existence
	emit_signal("death")
	free()

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
#TODO
func look(direction):
	match direction:
		Vector2(1,0):
			look_right()
		Vector2(-1,0):
			look_left()
		Vector2(0,-1),Vector2(1,-1),Vector2(-1,-1):
			look_up()
		_:
			look_down()

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

func take_damage(hp):
	HP = HP - hp
	if HP == 0:
		die()

func get_voice():
	return voice

func has_a_voice():
	if voice != null:
		return true
	return false

#return the direction in form of integers
#compare it to the enum direction
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