extends Node2D

func _ready():
	if Config.lightMode:
		$Node2D/Sprite.modulate = Color( 0, 0, 0, 1 )
