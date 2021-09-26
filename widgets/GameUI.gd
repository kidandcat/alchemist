extends Control

signal ui_restart

onready var levelLabel = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LevelLabel
onready var restart = $MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/Restart2
onready var coins = $MarginContainer/HBoxContainer/HBoxContainer/MarginContainer/Coins
var levelsMode = false
var currentSteps = 0

func _ready():
	Config.connect("coins", self, "update_coins")
	update_coins()
	if Config.lightMode:
		levelLabel.modulate = Color(0,0,0,1)

func update_coins():
	coins.text = "Coins %s" % Config.coins

func levelsMode():
	restart.visible = false
	levelsMode = true

func setText(text):
	levelLabel.text = text

func setLevel(level):
	levelLabel.text = "Level %s" % level

func _on_Restart_pressed():
	emit_signal("ui_restart")

func _on_Back_pressed():
	if levelsMode:
		get_tree().change_scene("res://Game.tscn")
	else:
		get_tree().change_scene("res://screens/LevelsPath.tscn")
