extends Control

signal ui_restart

onready var levelLabel = $MarginContainer/HBoxContainer/VBoxContainer/LevelLabel
onready var currentStepsLabel = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/CurrentSteps
onready var stepsLabel = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/StepsLabel
var levelsMode = false
var currentSteps = 0

func levelsMode():
	$MarginContainer/HBoxContainer/Restart2.visible = false
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
