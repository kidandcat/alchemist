extends Node

var creatorMode = true
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
	if creatorMode:
		readFromNetwork(id)
	else:
		readFromFile(id)
	
func readFromNetwork(id):
	print("request ", server + "/level/%s" % id)
	var err = http.request(server + "/level/%s" % id)
	print("Error: ", err)
	
func readFromFile(id):
	var file = File.new()
	file.open("res://alchemist-server/levels/match-%s.json" % id, file.READ)
	var text = file.get_as_text()
	var json = JSON.parse(text)
	file.close()
	var game = get_tree().root.get_node("Game")
	game._load_save_response(json.result)

func _on_request_completed( result, response_code, headers, body ):
	var json = JSON.parse(body.get_string_from_utf8())
	print("_on_request_completed ", json.result)
	var game = get_tree().root.get_node("Game")
	game._load_save_response(json.result)
