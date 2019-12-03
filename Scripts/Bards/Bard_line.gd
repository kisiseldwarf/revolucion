extends RichTextLabel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Bard_line_detection_body_entered(body):
	if body.name == "Player":
		show()

func _on_Bard_line_detection_body_exited(body):
	hide()
