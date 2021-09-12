extends TextureRect


func _ready():
	if Config.lightMode:
		lightMode()
	else:
		darkMode()

func lightMode():
	var g = GradientTexture.new()
	var gradient = Gradient.new()
	gradient.set_color(0, Color(.94, .93, .76, 255))
	gradient.set_color(1, Color(.94, .93, .76, 255))
	g.gradient = gradient
	texture = g

func darkMode():
	var g = GradientTexture.new()
	var gradient = Gradient.new()
	gradient.set_color(0, Color(.19, .21, .48, 255))
	gradient.set_color(1, Color(.11, .11, .23, 255))
	g.gradient = gradient
	texture = g
