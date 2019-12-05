extends "res:///Scripts/Human/Human.gd"

onready var nav2D = get_parent().get_parent().get_node("Navigation2D")

func _physics_process(delta):
	animation(direction_v)

func _process(delta):
	if is_player_in($Aggro) && !is_player_in(get_active_interabox()):
		fill_curve(is_player_in($Aggro))
		$Path2D/PathFollow2D.offset += velocity
		direction_v = get_orientation($Path2D/PathFollow2D.position).round()
		move_and_slide(direction_v * velocity)
	else:
		direction_v = Vector2(0,0)

func fill_curve(object):
	var start_point = position
	var end_point = object.position
	var path = nav2D.get_simple_path(start_point,end_point)
	var curve = Curve2D.new()
	for point in path:
		curve.add_point(point)
	$Path2D.curve = curve

func is_player_in(area2D):
	var bodies = area2D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			return body
	return false