extends Panel

var LevelButton = preload("res://widgets/LevelButton.tscn")
var customLevelsScene = "user://LevelsPathCurrent.tscn"

onready var levelsDone = Config.load_levels_done()
onready var scroll = $MarginContainer/Scroll

func _ready():
	scroll.get_v_scrollbar().rect_scale.x = 0
	setupLevelButtons()
	$GameUI.levelsMode()
	Config.connect("newlevel", self, "setupLevelButton")	

func _on_level_pressed(level: int):
	var levelsDone = Config.load_levels_done()
	if level <= levelsDone:
		Config.levelIndex = level
		get_tree().change_scene("res://screens/Game.tscn")

func setupLevelButtons():
	for child in $MarginContainer/Scroll/Dots.get_children():
		child.queue_free()
	for level in range(1, Config.countLevels()):
		setupLevelButton(level)

func setupLevelButton(level: int):
	var button = LevelButton.instance()
	if level < levelsDone:
		button.done()
		button.empty()
		button.star()
	elif level == levelsDone || level == 1:
		button.next()
	button.connect("pressed", self, "_on_level_pressed", [level])
	$MarginContainer/Scroll/Dots.add_child(button)

