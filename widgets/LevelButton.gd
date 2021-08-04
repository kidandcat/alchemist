extends TextureButton


var doneTextureOut = preload("res://assets/camtatz/Buttons/BTN_LORANGE_CIRCLE_OUT.png")
var doneTextureIn = preload("res://assets/camtatz/Buttons/BTN_LORANGE_CIRCLE_IN.png")
var nextTextureOut = preload("res://assets/camtatz/Buttons/BTN_BLUE_CIRCLE_OUT.png")
var nextTextureIn = preload("res://assets/camtatz/Buttons/BTN_BLUE_CIRCLE_IN.png")
var fill = preload("res://assets/fill.png")
var emptyImage = preload("res://assets/void.png")

func star():
	$CenterContainer/TextureRect.texture = fill
	
func empty():
	$CenterContainer/TextureRect.texture = emptyImage

func done():
	texture_normal = doneTextureOut
	texture_pressed = doneTextureIn

func next():
	texture_normal = nextTextureOut
	texture_pressed = nextTextureIn
