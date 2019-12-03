extends Node

var chemins = []
var graph = AStar.new()
export var end_id = 500000

func static follow(start,object_to_follow,speed,parent):
	var start_id = graph.get_closest_point(start)
	_move(graph.get_point_position(graph.get_closest_point(start)),parent)
	_connect_vector(graph,object_to_follow.position)
	chemins = graph.get_id_path(start_id,end_id)
	while !chemins.empty():
		if  object_to_follow.position != graph.get_point_position(end_id):
			start = object_to_follow.position
			start_id = graph.get_closest_point(start)
			_move(graph.get_point_position(start_id),parent)
			chemins.clear()
			chemins = graph.get_id_path(start_id,end_id)
		_move(chemins.front(),parent)
		chemins.pop_front()

func _move(vector,parent):
	parent.move_and_slide(vector)

func _connect_vector(graph,pos):
	graph.add_point(end_id,pos)
	graph.connect_points(graph.get_closest_point(pos),end_id)