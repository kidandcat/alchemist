extends Node2D

var selectedTube: Node2D = null
const TubeClass = preload("res://widgets/Tube.tscn")
const BallClass = preload("res://widgets/Ball.tscn")
var colors = ["Purple", "Blue", "Red", "Green", "Yellow", "DarkBlue", "Grey", "Lime", "Orange", "Pink"]
var tubes = []
var animationSpeed = 0.1
var coloredTubes = 0
var emptyTubes = 0
var moving = false
var movements = 0
var moves = []
const top = -600

signal move_end

func _ready():
	setTubePositions()
	randomize()
	_load_save_request()
	$audioTube.stream.loop_mode = AudioStreamSample.LOOP_DISABLED
	$audioMove.stream.loop_mode = AudioStreamSample.LOOP_DISABLED
	connect("move_end", self, "move_ended")
		
func move_ended():
	moving = false

func tube_input_event(viewport, event, shape_idx, tube):
	if event is InputEventMouseButton && event.pressed && not moving:
		moving = true
		call_deferred("actionNodeSelected", tube)

func createTube(index: int, color: String):
	var tube: Node2D = TubeClass.instance()
	tube.get_node("Area2D").connect("input_event", self, "tube_input_event", [tube])
	if color != "":
		addDots(tube, color, 4)
	$Tubes.add_child(tube)
	tube.global_position = get_children()[index+1].global_position
	tubes.append(tube)
	return tube

func addDots(tube: Node2D, color: String, number: int):
	for i in number:
		var dot = createDot(color)
		var topDot = getTopDot(tube)
		var targetY = 400
		if topDot:
			targetY = topDot.position.y -200
		tube.add_child(dot)
		dot.position.y = targetY

func createDot(color: String):
	var dot = BallClass.instance()
	match color:
		"Purple":
			dot.set_purple()
		"Green":
			dot.set_green()
		"Red":
			dot.set_red()
		"Yellow":
			dot.set_yellow()
		"Blue":
			dot.set_blue()
		"DarkBlue":
			dot.set_darkblue()
		"Orange":
			dot.set_orange()
		"Pink":
			dot.set_pink()
		"Lime":
			dot.set_lime()
	return dot

func actionNodeSelected(node: Node2D):
	$audioMove.play()
	if selectedTube:
		var selectedDot = getDotByY(selectedTube, top)
		var nextDot = getTopDot(node)
		if (hasFreeSpace(node)
			and node != selectedTube
			and selectedDot != null
			and (nextDot == null || selectedDot.color == nextDot.color)):
			moveDotToTube(node)
			yield(self, "move_end")
			if isVictory():
				finish()
		else:
			toggleDot(selectedTube)
	else:
		toggleDot(node)

func finish():

	Config.resolveLevel(moves)
	Config.levelIndex += 1
	Config.save_levels_done(Config.levelIndex)
	var minSteps = Config.readMinMovementsForLevel(Config.levelIndex-1)
	$WinAnimation.play()
	yield(get_tree().create_timer(2), "timeout")
	_load_save_request()

func isVictory():
	for tube in tubes:
		if not isTubeCompleted(tube):
			return false
	return true

func isTubeCompleted(tube):
	var equalDots = 0
	var color = ""
	for dot in tube.get_children():
		if dot is Ball:
			if color == "":
				color = dot.color
				equalDots += 1
			else:
				if dot.color == color:
					equalDots += 1
				else:
					return false
	if equalDots != 4 && equalDots != 0:
			return false
	return true

func moveDotToTube(node: Node2D):
	moves.append({
		"from": tubes.find(selectedTube),
		"to": tubes.find(node),
	})
	movements += 1
	var _selectedTube = selectedTube
	selectedTube = null
	var dot = getDotByY(_selectedTube, top)
	var pos = node.get_node("Position2D")
	moveDotToPosition2D(dot, pos)
	yield($Tween, "tween_completed")
	_selectedTube.remove_child(dot)
	node.add_child(dot)
	dot.position = Vector2(0, top)
	toggleDot(node)
	if isTubeCompleted(node):
		$audioTube.play()

func moveDotToPosition2D(dot: Node2D, target: Position2D):
	$Tween.interpolate_property(dot, "global_position", dot.global_position, target.global_position, animationSpeed,Tween.EASE_OUT,Tween.EASE_IN)
	$Tween.start()

func toggleDot(node: Node2D):
	var dot = getDotByY(node, top)
	if dot:
		var topDot = getTopDot(node)
		var targetY = 400
		if topDot:
			targetY = topDot.position.y -200
		$Tween.interpolate_property(dot, "position",dot.position, Vector2(0, targetY), animationSpeed, Tween.EASE_OUT,Tween.EASE_IN)
		$Tween.start()
		yield($Tween, "tween_completed")
		selectedTube = null
		emit_signal("move_end")
		return
	dot = getTopDot(node)
	if dot:
		$Tween.interpolate_property(dot, "position",dot.position, Vector2(0, top), animationSpeed, Tween.EASE_OUT,Tween.EASE_IN)
		$Tween.start()
		yield($Tween, "tween_completed")
		selectedTube = node
	emit_signal("move_end")
			
func getDotByY(node: Node2D, y: int):
	for dot in node.get_children():
		if not dot is Ball:
			continue
		if dot.position.y == y:
			return dot
			
func getTopDot(node: Node2D):
	var topNode = null
	for dot in node.get_children():
		if not dot is Ball || dot.position.y == top:
			continue
		if not topNode:
			topNode = dot
			continue
		if dot.position.y < topNode.position.y:
			topNode = dot
	return topNode

func hasFreeSpace(node: Node2D):
	for dot in node.get_children():
		if not dot is Ball:
			continue
		if dot.position.y == -200:
			return false
	return true

func hasDots(node: Node2D):
	for dot in node.get_children():
		if not dot is Ball:
			continue
		return true
	return false

func _on_save_pressed():
	var data = []
	for tube in tubes:
		var dots = []
		for dot in tube.get_children():
			if dot is Ball:
				dots.append(dot.color)
		data.append(dots)
	Config.saveFile(data)

func _load_save_request():
	for t in tubes:
		t.get_parent().remove_child(t)
	tubes = []
	moves = []
	movements = 0
	selectedTube = null
	Config.readLevel(Config.levelIndex)
	
func _load_save_response(data):
	if data == null:
		return
	var index = 0
	for tube in data:
		var tubeNode = createTube(index, "")
		for dot in tube:
			addDots(tubeNode, dot, 1)
		index += 1
	$CanvasLayer/GameUI.setLevel(Config.levelIndex)

func _on_GameUI_ui_restart():
	_load_save_request()


func _on_AudioStreamPlayer_finished():
	print("stop audio")
	$AudioStreamPlayer.stop()

func setTubePositions():
	var size = get_viewport_rect().size
	print("size Y ", size.y)
	$TextureRect.rect_size = size
	$TextureRect.rect_min_size = size
	
	$Position2D5.position.y = size.y * 0.3
	$Position2D6.position.y = size.y * 0.3
	$Position2D7.position.y = size.y * 0.3
	$Position2D8.position.y = size.y * 0.3
	
	$Position2D.position.y = size.y * 0.6
	$Position2D2.position.y = size.y * 0.6
	$Position2D3.position.y = size.y * 0.6
	$Position2D4.position.y = size.y * 0.6
	
	$Position2D9.position.y = size.y  * 0.85
	$Position2D10.position.y = size.y * 0.85
	$Position2D11.position.y = size.y * 0.85
	$Position2D12.position.y = size.y * 0.85
	
