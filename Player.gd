extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var sprite = get_node("Sprite")
var direction = Vector2(0,1)
var velocity = 3
var rush_state = 4
var in_rush = 0
var time_of_immortality = 3
var time_since_rush = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	direction = Vector2(0,0)
	direction = movement(direction)
	rush(direction,delta)



#movement script
func movement(direction):
	if Input.is_action_pressed("ui_up"):
		direction = direction + Vector2(0,-1)
	if Input.is_action_pressed("ui_down"):
		direction = direction + Vector2(0,1)
	if Input.is_action_pressed("ui_left"):
		direction = direction + Vector2(-1,0)
	if Input.is_action_pressed("ui_right"):
		direction = direction + Vector2(1,0)
	
	set_position(get_position()+direction.normalized()*velocity)
	return direction

func rush(direction,delta):
	if Input.is_action_pressed("ui_accept"):
		direction = direction * rush_state
		set_position(get_position()+direction)
		in_rush = 1
		rush_refresh(delta)

func rush_refresh(delta):
	if in_rush == 1:
		time_since_rush = time_since_rush + delta
		if time_since_rush >= time_of_immortality:
			in_rush = 0