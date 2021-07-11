extends MarginContainer

signal ui_restart

func setText(text):
	$VBoxContainer/LevelLabel.text = text

func setLevel(level):
	$VBoxContainer/LevelLabel.text = "Level %s" % level

func _on_Restart_pressed():
	print("emit signal ui_restart")
	emit_signal("ui_restart")
