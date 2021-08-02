extends Control

signal ui_restart

onready var levelLabel = $MarginContainer/HBoxContainer/LevelLabel

func setText(text):
	levelLabel.text = text

func setLevel(level):
	levelLabel.text = "Level %s" % level

func _on_Restart_pressed():
	emit_signal("ui_restart")


func _on_Back_pressed():
	get_tree().change_scene("res://screens/LevelsPath.tscn")
