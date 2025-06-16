extends Node

@export var custom_fade_duration = 1

@export var menu = "MAIN_MENU"


func _ready():
	if(StoredElements.menu != menu):
		fade_in(self, custom_fade_duration)

func fade_in(scene_parent, fade_duration):
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.size = Vector2(2000, 2000)
	fade_rect.anchor_left = 0
	fade_rect.anchor_top = 0
	fade_rect.anchor_right = 1
	fade_rect.anchor_bottom = 1
	scene_parent.add_child(fade_rect)
	
	var from_color = Color(0,0,0,1)
	var to_color = Color(0,0,0,0)
	fade_rect.color = from_color

	var tween = scene_parent.create_tween()
	tween.tween_property(fade_rect, "color", to_color, fade_duration)

	await tween.finished
	
	StoredElements.menu = menu
	
	fade_rect.queue_free()

# Called when the node enters the scene tree for the first time.
func fadeScene(scene_parent : Node, audio, new_scene, fade_duration):
	
	# Comment Out to Use User Specified
	fade_duration = custom_fade_duration
	
	# Play sound
	if(audio != null):
		audio.play()

	scene_parent = scene_parent.get_tree().current_scene

	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)  # Black but fully transparent initially
	fade_rect.size = Vector2(2000, 2000)
	fade_rect.anchor_left = 0
	fade_rect.anchor_top = 0
	fade_rect.anchor_right = 1
	fade_rect.anchor_bottom = 1
	scene_parent.add_child(fade_rect)

	# Create tween for fade to black
	var from_color = Color(0,0,0,0)
	var to_color = Color(0,0,0,1)
	fade_rect.color = from_color

	var tween = scene_parent.create_tween()
	tween.tween_property(fade_rect, "color", to_color, fade_duration)

	# Wait for both fade and sound to finish
	await tween.finished

	# Change to the new scene
	if(new_scene != null):
		scene_parent.get_tree().change_scene_to_file(new_scene)
