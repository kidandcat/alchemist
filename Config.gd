extends Node

var lightMode = false
var movements: int = 100
var passFile = "fwegfuywe7r632r732fdjghfvjhfesedwfcdewqyhfewjf"
var server = "https://galax.be"
var http = HTTPRequest.new()
var levelIndex = 1
var cacheLevelsDone
var cacheStarsDone

func _ready():
	print("Config ready")
	add_child(http)
	
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
	var done = load_levels_done()
	if levels > done:
		var file = File.new()
		file.open("user://game.save", File.WRITE)
		file.store_32(levels)
		file.close()

func load_levels_done() -> int:
	var levels: int = 1
	var file = File.new()
	if file.file_exists("user://game.save"):
		file.open("user://game.save", File.READ)
		levels = file.get_32()
		file.close()
	return levels

func save_stars_done(number):
	var file = File.new()
	if file.file_exists("user://stars.save"):
		file.open("user://stars.save", File.READ_WRITE)
		file.seek_end()
	else:
		file.open("user://stars.save", File.WRITE)
	file.store_32(number)
	file.close()

func load_stars_done() -> Array:
	var stars = []
	var file = File.new()
	if file.file_exists("user://stars.save"):
		file.open("user://stars.save", File.READ)
		while file.get_len() != file.get_position():
			stars.append(file.get_32())
		file.close()
	return stars

func readMinMovementsForLevel(id):
	var file = File.new()
	file.open("res://alchemist-server/levels/match-%s.json" % id, file.READ)
	var text = file.get_as_text()
	var json = JSON.parse(text)
	file.close()
	var paths = json.result['paths']
	var shortest = 999
	for path in paths:
		if path.size() < shortest:
			shortest = path.size()
	return shortest
