extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var HP = 100
export var attack = 50
signal death
signal select_pressed
signal select_released
signal new_physics_frame
signal move_finished
signal dialog_began
signal dialog_finished
export var velocity = 4
export var text_speed : float = 0
var in_dialog = 0 
var in_cinematic = 0
var last_direction = Vector2(0,0)
enum direction { UP, DOWN, RIGHT, LEFT}

#cinematic API
#use this when you want to code a cinematic
#cinematic prevents any control from the user

func cin_enable():
	in_cinematic = 1

func cin_disable():
	in_cinematic = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if HP == 0:
		die()
	$Camera2D/HUD/DialogPanel.hide()
	$Camera2D/HUD/TextInterfaceEngine.show()


func _process(delta):
	pass

func _physics_process(delta):
	emit_signal("new_physics_frame")
	var direction = Vector2(0,0)
	if !in_dialog && !in_cinematic:
		direction = movement(direction,delta)
		animation(direction)

#signals script and actions
func _input(event):
	if event.is_action_pressed("ui_select"):
		emit_signal("select_pressed")
		if !in_dialog:
			dialog()
	if event.is_action_released("ui_select"):
		emit_signal("select_released")
	if event.is_action_pressed("ui_action"):
		attack()

#dialog script
func dialog():
	emit_signal("dialog_began")
	var pnjs = $Dialog_Area.get_overlapping_bodies()
	if pnjs.size() > 1 && pnjs[1].is_in_group("PNJs") && !in_dialog:
		in_dialog = 1
		#To make the pnj look at you
		var orientation = pnjs[1].get_orientation(position).round()
		pnjs[1].look(orientation)
		look(last_direction)
		#Dialog
		$Camera2D/HUD/DialogPanel.show()
		for i in pnjs[1].text:
			if pnjs[1].has_a_voice():
				$Camera2D/HUD/TextInterfaceEngine.buff_text(i,text_speed,"",false,pnjs[1].get_voice())
			else:
				$Camera2D/HUD/TextInterfaceEngine.buff_text(i,text_speed)
			$Camera2D/HUD/TextInterfaceEngine.set_state(1)
			yield(self,"select_pressed")
			$Camera2D/HUD/TextInterfaceEngine.reset()
		$Camera2D/HUD/DialogPanel.hide()
		yield(self,"select_released")
		in_dialog = 0
	emit_signal("dialog ended")

#movement script ( /!\ )
func movement(direction,delta):
	if Input.is_action_pressed("ui_left"):
		direction =+ Vector2(-1,0)
	if Input.is_action_pressed("ui_right"):
		direction += Vector2(1,0)
	if Input.is_action_pressed("ui_down"):
		direction += Vector2(0,1)
	if Input.is_action_pressed("ui_up"):
		direction += Vector2(0,-1)
	
	var movement = direction.normalized() * velocity
	move_and_slide(movement)
	return direction

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

#die script
func die():
	#play a death animation
	#wait a few seconds
	$"Dying Time".start()
	yield($"Dying Time","timeout")
	#erasing the player from existence
	emit_signal("death")
	free()

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

#use 4 area2D (one for each orientation) to know what is striked
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

func set_dialog(texts):
	#Dialog
	in_dialog = 1
	$Camera2D/HUD/DialogPanel.show()
	for i in texts:
		$Camera2D/HUD/TextInterfaceEngine.buff_text(i,text_speed)
		$Camera2D/HUD/TextInterfaceEngine.set_state(1)
		yield(self,"select_pressed")
		$Camera2D/HUD/TextInterfaceEngine.reset()
	$Camera2D/HUD/DialogPanel.hide()
	yield(self,"select_released")
	in_dialog = 0

