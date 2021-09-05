extends Panel

var LevelButton = preload("res://widgets/LevelButton.tscn")
var customLevelsScene = "user://LevelsPathCurrent.tscn"

onready var levelsDone = Config.load_levels_done()
onready var stars = Config.load_stars_done()
onready var scroll = $MarginContainer/Scroll

func _ready():
	scroll.get_v_scrollbar().rect_scale.x = 0
	setupLevelButtons(levelsDone +5)
	$GameUI.levelsMode()
	call_deferred("updateScroll")
	
func updateScroll():
	yield(get_tree().create_timer(.1), "timeout")
	scroll.scroll_vertical = scroll.get_v_scrollbar().max_value
	scroll.update()

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

func setupLevelButtons(nOfLevels: int):
	for level in range(1, nOfLevels):
		setupLevelButton(level)

func setupLevelButton(level: int):
	var button = LevelButton.instance()
	if level < levelsDone:
		button.done()
		button.empty()
	if stars.has(level+1):
		button.star()
	if level == levelsDone:
		button.next()
	button.connect("pressed", self, "_on_level_pressed", [level])
	$MarginContainer/Scroll/Dots.add_child(button)
