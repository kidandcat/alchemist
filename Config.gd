extends Node

var movements: int = 100
var passFile = "fwegfuywe7r632r732fdjghfvjhfesedwfcdewqyhfewjf"
var server = "https://galax.be"
var http = HTTPRequest.new()
var levelIndex = 1

func _ready():
	add_child(http)
	http.connect("request_completed", self, "_on_request_completed")

func saveFile(data):
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	print("post ", server+"/create/level")
	var err = http.request(server+"/create/level", headers, true, HTTPClient.METHOD_POST, query)
	print("Error: ", err)
	
func readLevel(id):
	readFromFile(id)
	
func readFromFile(id):
	var file = File.new()
	file.open("res://alchemist-server/levels/match-%s.json" % id, file.READ)
	var text = file.get_as_text()
	var json = JSON.parse(text)
	file.close()
	var game = get_tree().root.get_node("Game")
	game._load_save_response(json.result['tubes'])

func save_levels_done(levels: int):
	var file = File.new()
	file.open("user://game.save", File.WRITE)
	file.store_32(levels)
	file.close()

func load_levels_done() -> int:
	var levels: int = 0
	var file = File.new()
	if file.file_exists("user://game.save"):
		file.open("user://game.save", File.READ)
		levels = file.get_32()
		file.close()
	return levels
