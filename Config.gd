extends Node

var movements: int = 100
var passFile = "fwegfuywe7r632r732fdjghfvjhfesedwfcdewqyhfewjf"
var server = "https://galax.be"
var http = HTTPRequest.new()

func _ready():
	add_child(http)
	http.connect("request_completed", self, "_on_request_completed")

func saveFile(data):
	var query = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	print("post ", server+"/create/level")
	var err = http.request(server+"/create/level", headers, true, HTTPClient.METHOD_POST, query)
	print("Error: ", err)
	
func readFile(id):
	print("request ", server + "/level/%s" % id)
	var err = http.request(server + "/level/%s" % id)
	print("Error: ", err)

func _on_request_completed( result, response_code, headers, body ):
	var json = JSON.parse(body.get_string_from_utf8())
	print("_on_request_completed ", json.result)
	var game = get_tree().root.get_node("Game")
	game._load_save_response(json.result)
