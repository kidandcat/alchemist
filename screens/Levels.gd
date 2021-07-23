extends Panel

var http = HTTPRequest.new()
var LevelButton = preload("res://widgets/LevelButton.tscn")

func _ready():
	if Config.creatorMode:
		add_child(http)
		http.connect("request_completed", self, "_on_request_completed")
		var err = http.request(Config.server + "/levels")
		print("Error: ", err)
	else:
		var file = File.new()
		var levels = 1
		print("start while")
		while file.file_exists("res://alchemist-server/levels/match-%s.json" % levels):
			levels += 1
		print("end while")
		print("levels ", levels)
		setupLevelButtons(levels)

func _on_level_pressed(level: int):
	Config.levelIndex = level
	get_tree().change_scene("res://screens/Game.tscn")

func _on_request_completed( result, response_code, headers, body ):
	var json = JSON.parse(body.get_string_from_utf8())
	print("_on_request_completed ", json.result)
	setupLevelButtons(int(json.result))

func setupLevelButtons(nOfLevels: int):
	for level in range(1, nOfLevels):
		var button = LevelButton.instance()
		button.setLabel(String(level))
		button.connect("pressed", self, "_on_level_pressed", [level])
		$MarginContainer/VBoxContainer/GridContainer.add_child(button)
