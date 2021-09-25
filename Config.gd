extends Node

signal newlevel

var lightMode = false
var movements: int = 100
var passFile = "fwegfuywe7r632r732fdjghfvjhfesedwfcdewqyhfewjf"
var server = "https://galax.be"
var http = HTTPRequest.new()
var levelIndex = 1
var cacheLevelsDone
var cacheStarsDone
var levelsCount = 100
var levelFetchIndex = 1

func _ready():
	add_child(http)
	http.connect("request_completed", self, "_on_request_completed")
	fetchLevels()
	
func readDay() -> int:
	var directory = Directory.new();
	if not directory.file_exists("user://last_fetch.dat"):
		return -1
	var file = File.new()
	file.open("user://last_fetch.dat", File.READ)
	var content = file.get_as_text()
	file.close()
	return int(content)
	
func writeDay():
	var time = OS.get_datetime()
	var dayofmonth = time["day"]
	var file = File.new()
	file.open("user://last_fetch.dat", File.WRITE)
	file.store_line(str(dayofmonth))
	file.close()
	
func readLevel(id):
	readFromFile(id)
	
func fetchLevels():	
	var time = OS.get_datetime()
	var dayofmonth = time["day"]
	if readDay() != dayofmonth:
		var dir = Directory.new()
		dir.remove("user://game.save")
		dir.remove("user://stars.save")
		remove_recursive("user://levels")
		dir.make_dir("user://levels")
		writeDay()
		fetchLevel()

func countLevels():
	var total = 0
	var dir = Directory.new()
	dir.open("user://levels")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			total += 1
	dir.list_dir_end()
	return total

func fetchLevel():
	http.set_download_file("user://levels/match-%s.json" % levelFetchIndex)
	http.request("https://galax.be/levels/%s" % levelFetchIndex)

func _on_request_completed(result, response_code, headers, body):
	emit_signal("newlevel", levelFetchIndex)
	levelFetchIndex += 1
	if levelFetchIndex <= 100:
		fetchLevel()
	
func readFromFile(id):
	var file = File.new()
	file.open("user://levels/match-%s.json" % id, file.READ)
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
	file.open("user://levels/match-%s.json" % id, file.READ)
	var text = file.get_as_text()
	var json = JSON.parse(text)
	file.close()
	var paths = json.result['paths']
	var shortest = 999
	for path in paths:
		if path.size() < shortest:
			shortest = path.size()
	return shortest

func remove_recursive(path):
	var directory = Directory.new()
	# Open directory
	var error = directory.open(path)
	if error == OK:
		# List directory content
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				remove_recursive(path + "/" + file_name)
			else:
				directory.remove(file_name)
			file_name = directory.get_next()
		# Remove current path
		directory.remove(path)
	else:
		print("Error removing " + path)
