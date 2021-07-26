extends Panel

var LevelButton = preload("res://widgets/LevelButton.tscn")

func _ready():
	var file = File.new()
	var levels = 1
	while file.file_exists("res://alchemist-server/levels/match-%s.json" % levels):
		levels += 1
	setupLevelButtons(levels)

func _on_level_pressed(level: int):
	var levelsDone = Config.load_levels_done()
	if level <= levelsDone:
		Config.levelIndex = level
		get_tree().change_scene("res://screens/Game.tscn")

func setupLevelButtons(nOfLevels: int):
	var levelsDone = Config.load_levels_done()
	for level in range(1, nOfLevels):
		var button = LevelButton.instance()
		if level < levelsDone:
			button.done()
		button.setLabel(String(level))
		button.connect("pressed", self, "_on_level_pressed", [level])
		$MarginContainer/VBoxContainer/GridContainer.add_child(button)
