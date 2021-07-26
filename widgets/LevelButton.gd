extends TextureButton


var doneTextureOut = preload("res://assets/camtatz/Buttons/BTN_LORANGE_CIRCLE_OUT.png")
var doneTextureIn = preload("res://assets/camtatz/Buttons/BTN_LORANGE_CIRCLE_IN.png")

func setLabel(text: String):
	$Label.text = text

func done():
	texture_normal = doneTextureOut
	texture_pressed = doneTextureIn
