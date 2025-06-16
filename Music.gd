extends AudioStreamPlayer

var musicMuted = false

var fadeDuration = 3
var delayBeforeStart = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	self.volume_db = -80
	
	await get_tree().create_timer(delayBeforeStart).timeout
	play()
	fade_in_tween(fadeDuration)
	
func fade_in_tween(duration: float) -> void:
	# Start at very low volume
	self.volume_db = -80

	# Create and configure tween
	var tween := create_tween()
	tween.tween_method(
		func(vol):
			if is_instance_valid(self):
				self.volume_db = vol,
		-80.0, 0.0, duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func fade_out_tween(duration: float) -> void:
	# Start at very low volume

	# Create and configure tween
	var tween := create_tween()
	tween.tween_method(
		func(vol):
			if is_instance_valid(self):
				self.volume_db = vol,
		0.0, -80.0, duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func log10(x):
	return log(x) / log(10)

func muteToggle():
	if(musicMuted):
		volume_db = 0.0
		musicMuted = false
	else:
		volume_db = -8000.0
		musicMuted = true
