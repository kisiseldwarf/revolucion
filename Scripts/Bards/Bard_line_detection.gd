extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	var bodies = get_overlapping_bodies()
	var player_found = 0
	var player = Node2D.new()
	
	if event.is_action_pressed("ui_accept"):
		if bodies.size() > 0:
			for i in bodies:
				if i.name == "Player":
					player_found = true
					player = i
		if player_found :
			#cinematic is launched
			player.cin_enable()
			player.move(get_node("../../Meeting").position,60)
			yield(player,"move_finished")
			player.look_up()
			yield(get_tree().create_timer(1),"timeout")
			player.look_right()
			yield(get_tree().create_timer(1),"timeout")
			player.look_left()
			player.cin_disable()