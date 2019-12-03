extends "res:///Scripts/Human/Human.gd"

signal spacebar_pressed
signal dialog_end
export var text = PoolStringArray()
export var voice:AudioStreamSample

#do something before a dialog begin
func dialog(with):
	look(get_orientation(with.position).round())

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	animation(Vector2(0,0))

func get_voice():
	return voice

func has_a_voice():
	if voice != null:
		return true
	return false