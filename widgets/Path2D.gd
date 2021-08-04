extends Node2D

var LevelButton = preload("res://widgets/LevelButton.tscn")
var LevelButtonClass = preload("res://widgets/LevelButton.gd")
var dot = preload("res://widgets/GrandientDot.tscn")
export var offsetStep = 30
export var timePeriod = 0.1
export var levelsSpacing = 50
var end = false
var time = 0
export var index = 1
onready var path = $Path2D
onready var follow = $Path2D/PathFollow2D
onready var pathLength = path.curve.get_baked_length()
onready var levelsDone = Config.load_levels_done()
onready var stars = Config.load_stars_done()

func _ready():
	reconnectButtons()
	set_process(true)

func reconnectButtons():
	var level = 1
	for child in get_children():
		if child is LevelButtonClass:
			child.connect("pressed", get_tree().root.get_node("Game"), "_on_level_pressed", [level])
			if level < levelsDone:
				child.done()
				child.empty()
			if stars.has(level+1):
				child.star()
			if level == levelsDone:
				child.next()
			level += 1

func _process(delta):
	time += delta
	if levelsDone+2 <= index:
				ended()
	elif time > timePeriod && !end:
		time = 0
		var s = dot.instance()
		s.global_position = follow.global_position
		s.rotation = follow.rotation
		$YellowLine.add_child(s)
		_set_owner(s)
		if int(follow.offset) % levelsSpacing == 0:
			setupLevelButton(index)
			index += 1
		follow.offset += offsetStep
		if follow.offset > (pathLength-50):
			ended()

func _set_owner(node):
	if node != self:
		node.owner = self
	for child in node.get_children():
		_set_owner(child)

func ended():
	end = true
	$Camera2D.target_return_enabled = false
	var gameNode = get_tree().root.get_node("Game")
	gameNode.saveScene()

func setupLevelButton(level: int):
	var button = LevelButton.instance()
	if level < levelsDone:
		button.done()
		button.empty()
	if stars.has(level+1):
		button.star()
	if level == levelsDone:
		button.next()
	button.connect("pressed", get_tree().root.get_node("Game"), "_on_level_pressed", [level])
	button.set_global_position(follow.global_position)
	add_child(button)
	_set_owner(button)

func setupLevelButtons(nOfLevels: int):
	for level in range(1, nOfLevels):
		var button = LevelButton.instance()
		if level < levelsDone:
			button.done()
			button.empty()
		if stars.has(level+1):
			button.star()
		if level == levelsDone:
			button.next()
		button.connect("pressed", self, "_on_level_pressed", [level])
		button.set_global_position(follow.global_position)
		add_child(button)
		_set_owner(button)
		follow.offset += offsetStep

