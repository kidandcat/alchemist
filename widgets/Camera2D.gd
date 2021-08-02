extends Camera2D

export (NodePath) var target

var target_return_enabled = true
var target_return_rate = 0.02

var events = {}
var last_drag_distance = 0


func _process(delta):
	if target and target_return_enabled and events.size() == 0:
		position.x = lerp(position.x, get_node(target).position.x, target_return_rate)
		position.y = lerp(position.y, get_node(target).position.y, target_return_rate)


func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)

	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			position -= event.relative.rotated(rotation)
