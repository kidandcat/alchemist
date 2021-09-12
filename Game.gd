extends Panel


func _on_Easy_pressed():
	get_tree().change_scene("res://screens/LevelsPath.tscn")


func _on_LightMode_pressed():
	Config.lightMode = true
	_on_Easy_pressed()

