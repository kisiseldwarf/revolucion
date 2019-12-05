extends "res:///Scripts/Human/Human.gd"

onready var nav2D = get_parent().get_parent().get_node("Navigation2D")
var moving = 0

func _physics_process(delta):
	pass

func _process(delta):
	if is_player_in($Aggro) && !moving && !is_player_in(get_active_interabox()):
		follow(is_player_in($Aggro))

func follow(object):
	moving = 1
	var start_point = position
	var end_point = object.position
	var path = nav2D.get_simple_path(start_point,end_point,false)
	var i = 1
	while !is_player_in(get_active_interabox()) && i != path.size()-1:
		move(path[i],1)
		yield(self,"move_finished")
		if object == null:
			moving=0
			break
		if end_point.round() != object.position.round():
			i = 1
			end_point = object.position
			path = nav2D.get_simple_path(start_point,end_point,false)
		i = i +1
	moving = 0

func is_player_in(area2D):
	var bodies = area2D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			return body
	return false