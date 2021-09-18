extends Control

signal ui_restart

onready var levelLabel = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/LevelLabel
onready var currentStepsLabel = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/CurrentSteps
onready var stepsLabel = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/StepsLabel
onready var restart = $MarginContainer/HBoxContainer/VBoxContainer/Restart2
var levelsMode = false
var currentSteps = 0

func _ready():
	if Config.lightMode:
		levelLabel.modulate = Color(0,0,0,1)
		currentStepsLabel.modulate = Color(0,0,0,1)
		stepsLabel.modulate = Color(0,0,0,1)

func levelsMode():
	restart.visible = false
	levelsMode = true

func setText(text):
	levelLabel.text = text

func setLevel(level):
	levelLabel.text = "Level %s" % level
	
func resetSteps():
	currentSteps = 0
	refreshSteps()

func upSteps():
	currentSteps += 1
	refreshSteps()
	
func refreshSteps():
	currentStepsLabel.text = "Current: %s" % currentSteps

func setSteps(steps: int):
	stepsLabel.text = "Min Steps: %s" % steps

func _on_Restart_pressed():
	emit_signal("ui_restart")

func _on_Back_pressed():
	if levelsMode:
		get_tree().change_scene("res://Game.tscn")
	else:
		get_tree().change_scene("res://screens/LevelsPath.tscn")
