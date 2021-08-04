extends Panel

onready var levelsOriginalScene = preload("res://widgets/Path2D.tscn")
var customLevelsScene = "user://LevelsPathCurrent.tscn"

func _ready():
	var file = File.new()
	if file.file_exists(customLevelsScene):
		loadScene()
	else:
		var s = levelsOriginalScene.instance()
		add_child(s)

func _on_level_pressed(level: int):
	var levelsDone = Config.load_levels_done()
	if level <= levelsDone:
		Config.levelIndex = level
		get_tree().change_scene("res://screens/Game.tscn")

func saveScene():
	var packed_scene = PackedScene.new()
	var node = get_tree().root.get_node("Game/Path")
	packed_scene.pack(node)
	var err = ResourceSaver.save(customLevelsScene, packed_scene)

func loadScene():
	var levelsScene = load(customLevelsScene)
	var my_scene = levelsScene.instance()
	add_child(my_scene)

