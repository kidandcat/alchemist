extends Node2D
class_name Ball

var color = "Grey"

func set_red():
	$Sprite.modulate = Color.from_hsv(0, .7, 1)
	color = "Red"

func set_blue():
	$Sprite.modulate = Color.from_hsv(.51, .7, 1)
	color = "Blue"

func set_darkblue():
	$Sprite.modulate = Color.from_hsv(.66, .7, 1)
	color = "DarkBlue"
	
func set_green():
	$Sprite.modulate = Color.from_hsv(.31, .7, 1)
	color = "Green"
	
func set_lime():
	$Sprite.modulate = Color.from_hsv(.22, .7, 1)
	color = "Lime"
	
func set_orange():
	$Sprite.modulate = Color.from_hsv(.09, .7, 1)
	color = "Orange"

func set_pink():
	$Sprite.modulate = Color.from_hsv(.83, .7, 1)
	color = "Pink"

func set_purple():
	$Sprite.modulate = Color.from_hsv(.77, .7, 1)
	color = "Purple"
	
func set_yellow():
	$Sprite.modulate = Color.from_hsv(.16, .7, 1)
	color = "Yellow"
