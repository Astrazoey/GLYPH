extends Node

var font = preload("res://Fonts/HWYGOTH.TTF")

func clearMenu(container):
	for child in container.get_children():
		child.queue_free()

func makeNewLabel(text, fontSize):
	var heading = Label.new()
	heading.text = text
	heading.set("theme_override_font_sizes/font_size", fontSize)
	heading.set("theme_override_fonts/font", font)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return heading

func addHeading(text, fontSize, posY, container):	
	var heading = makeNewLabel(text, fontSize)
	#var font = ThemeDB.fallback_font.duplicate()
	heading.add_theme_font_override("font", font)
	heading.add_theme_font_size_override("font_size", fontSize)
	var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, fontSize)
	heading.position = Vector2(-text_size.x / 2.0, posY)
	container.add_child(heading)
	return heading
	
func addTextButton(text, fontSize, method, posY, container):
	var button = Button.new()
	var labelSettings = load("res://Label Settings/description.tres")
	button.text = text
	button.set("theme_override_font_sizes/font_size", fontSize)
	button.set("theme_override_fonts/font", font)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.connect("pressed", method)
	container.add_child(button)
	button.position = Vector2(button.size.x / -2, posY)
	return button
	
func addTextureButton(texture, texture_hover, method, scale, position, container):
	var button = TextureButton.new()
	button.texture_normal = texture
	button.texture_hover = texture_hover
	button.connect("pressed", method)
	container.add_child(button)
	button.scale = scale
	button.position = position
	return button

func createSimpleLabel(text, fontSize, pos, container):
	var heading = makeNewLabel(text, fontSize)
	heading.position = pos
	container.add_child(heading)
	return heading

func createSimpleButton(texture, texture_hover, pos, container):
	var button = TextureButton.new()
	button.texture_normal = texture
	if(texture_hover != null):
		button.texture_hover = texture_hover
	button.position = pos
	container.add_child(button)
	return button

func centerText(button):
	button.position = Vector2(button.size.x / -2, button.position.y)
