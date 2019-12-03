extends "res:///Scripts/Human/Human.gd"

onready var nav2D = get_parent().get_parent().get_node("Navigation2D")
var moving = 0

func _physics_process(delta):
	emit_signal("new_physics_frame")
	if is_player_in():
		if(nav2D != null):
			var path = nav2D.get_simple_path(is_player_in().position,position)
			move_along_path(path)

func move_along_path(path):
	moving = 1
	var start_point = position
	for point in path:
		print("aha")
		var dir = get_orientation(point)
		while position.round() != point.round():
			move_and_slide(dir*velocity)
			animation(dir.round())
			yield(self,"new_physics_frame")
	moving = 0

func is_player_in():
	var bodies = $Aggro.get_overlapping_bodies()
	for i in bodies:
		if i.is_in_group("Player"):
			return i
	return false