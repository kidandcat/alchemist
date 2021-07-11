extends Node2D

export var creatorMode = false
var levelIndex = 1
var selectedTube: Node2D = null
var TubeClass = preload("res://widgets/Tube.tscn")
var colors = ["Purple", "Blue", "Red", "Green", "Yellow", "DarkBlue", "Grey", "Lime", "Orange", "Pink"]
var tubes = []
var animationSpeed = 0.1
var clutterMode = true # true
var coloredTubes = 0
var emptyTubes = 0
var moving = false
var creatingNewLevel = false
var tempSavedData = []
const top = -600

signal move_end

func _ready():
	randomize()
	_load_save_request()
	if OS.is_debug_build() && creatorMode:
		$CanvasLayer/LevelCreator.visible = true

func recreate():
	creatingNewLevel = true
	$CanvasLayer/GameUI.setText("Creating level")
	for t in tubes:
		t.get_parent().remove_child(t)
	tubes = []
	for child in $Tubes.get_children():
		$Tubes.remove_child(child)
	for i in coloredTubes:
		createTube(i, colors[i])
	for i in emptyTubes:
		createTube(i+coloredTubes, "")

func clutter():
	clutterMode = true
	var oldAnimSpeed = animationSpeed
	animationSpeed = 0
	for i in Config.movements:
		# progress bar
		$CanvasLayer/Control/CenterContainer/ProgressBar.value = (i*100) / Config.movements
		var tube
		while true:
			var rng = randi() % (emptyTubes + coloredTubes)
			if rng >= tubes.size():
				continue
			tube = tubes[rng]
			if ((selectedTube != null && hasFreeSpace(tube))
				or (selectedTube == null && hasDots(tube))):
				break
		var event = InputEventMouseButton.new()
		event.pressed = true
		tube_input_event(get_viewport(), event, 0, tube)
		yield(self, "move_end")
	clutterMode = false
	animationSpeed = oldAnimSpeed
	$CanvasLayer/Control.visible = false
	if creatingNewLevel:
		_temp_save_level()

func tube_input_event(viewport, event, shape_idx, tube):
	if event is InputEventMouseButton && event.pressed && not moving:
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
	var dot: Sprite = Sprite.new()
	match color:
		"Purple":
			dot.texture = preload("res://assets/purple.png")
		"Green":
			dot.texture = preload("res://assets/green.png")
		"Red":
			dot.texture = preload("res://assets/red.png")
		"Yellow":
			dot.texture = preload("res://assets/yellow.png")
		"Blue":
			dot.texture = preload("res://assets/blue.png")
		"DarkBlue":
			dot.texture = preload("res://assets/darkblue.png")
		"Grey":
			dot.texture = preload("res://assets/grey.png")
		"Orange":
			dot.texture = preload("res://assets/orange.png")
		"Pink":
			dot.texture = preload("res://assets/pink.png")
		"Lime":
			dot.texture = preload("res://assets/lime.png")
	return dot
	
func colorFromTexture(texture: String):
	match texture:
		"res://assets/purple.png":
			return "Purple"
		"res://assets/green.png":
			return "Green"
		"res://assets/red.png":
			return "Red"
		"res://assets/yellow.png":
			return "Yellow"
		"res://assets/blue.png":
			return "Blue"
		"res://assets/darkblue.png":
			return "DarkBlue"
		"res://assets/grey.png":
			return "Grey"
		"res://assets/orange.png":
			return "Orange"
		"res://assets/pink.png":
			return "Pink"
		"res://assets/lime.png":
			return "Lime"

func actionNodeSelected(node: Node2D):
	if selectedTube:
		var selectedDot = getDotByY(selectedTube, top)
		var nextDot = getTopDot(node)
		if (hasFreeSpace(node)
			and node != selectedTube
			and selectedDot != null
			and (clutterMode == true || nextDot == null || selectedDot.texture == nextDot.texture)):
			moveDotToTube(node)
			yield(self, "move_end")
			if isVictory():
				levelIndex += 1
				_load_save_request()
		else:
			toggleDot(selectedTube)
	else:
		toggleDot(node)

func isVictory():
	for tube in tubes:
		var equalDots = 0
		var color = ""
		for dot in tube.get_children():
			if dot is Sprite:
				if color == "":
					color = dot.texture.resource_path
					equalDots += 1
				else:
					if dot.texture.resource_path == color:
						equalDots += 1
					else:
						return false
		if equalDots != 4 && equalDots != 0:
			return false
	return true

func moveDotToTube(node: Node2D):
	moving = true
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
		moving = false
		emit_signal("move_end")
		return
	dot = getTopDot(node)
	if dot:
		$Tween.interpolate_property(dot, "position",dot.position, Vector2(0, top), animationSpeed, Tween.EASE_OUT,Tween.EASE_IN)
		$Tween.start()
		yield($Tween, "tween_completed")
		selectedTube = node
		moving = false
		emit_signal("move_end")
		return
	moving = false
	emit_signal("move_end")
			
func getDotByY(node: Node2D, y: int):
	for dot in node.get_children():
		if not dot is Sprite:
			continue
		if dot.position.y == y:
			return dot
			
func getTopDot(node: Node2D):
	var topNode = null
	for dot in node.get_children():
		if not dot is Sprite || dot.position.y == top:
			continue
		if not topNode:
			topNode = dot
			continue
		if dot.position.y < topNode.position.y:
			topNode = dot
	return topNode

func hasFreeSpace(node: Node2D):
	for dot in node.get_children():
		if not dot is Sprite:
			continue
		if dot.position.y == -200:
			return false
	return true

func hasDots(node: Node2D):
	for dot in node.get_children():
		if not dot is Sprite:
			continue
		return true
	return false

func _on_save_pressed():
	var data = []
	for tube in tubes:
		var dots = []
		for dot in tube.get_children():
			if dot is Sprite:
				dots.append(colorFromTexture(dot.texture.resource_path))
		data.append(dots)
	Config.saveFile(data)

func _temp_save_level():
	var data = []
	for tube in tubes:
		var dots = []
		for dot in tube.get_children():
			if dot is Sprite:
				dots.append(colorFromTexture(dot.texture.resource_path))
		data.append(dots)
	tempSavedData = data

func _load_save_request():
	for t in tubes:
		t.get_parent().remove_child(t)
	tubes = []
	if creatingNewLevel:
		var index = 0
		for tube in tempSavedData:
			var tubeNode = createTube(index, "")
			for dot in tube:
				addDots(tubeNode, dot, 1)
			index += 1
		clutterMode = false
	else:
		Config.readFile(levelIndex)
	
func _load_save_response(data):
	if data == null:
		return
	var index = 0
	for tube in data:
		var tubeNode = createTube(index, "")
		for dot in tube:
			addDots(tubeNode, dot, 1)
		index += 1
	$CanvasLayer/GameUI.setLevel(levelIndex)
	clutterMode = false
		
func _on_Reload_pressed():
	clutter()

func _on_MatchIndexInput_text_changed(new_text):
	levelIndex = int(new_text)

func _on_TubesInput_text_changed(new_text):
	coloredTubes = int(new_text)

func _on_EmptyInput_text_changed(new_text):
	emptyTubes = int(new_text)

func _on_Recreate_pressed():
	recreate()

func _on_GameUI_ui_restart():
	_load_save_request()
