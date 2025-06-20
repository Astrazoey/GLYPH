extends HSlider

@onready var gold_counter = $"../HBoxContainer2/GoldCounter"
@onready var wager_counter = $"../HBoxContainer2/WagerAmount"
@onready var wager_label = $"../HBoxContainer2/VBoxContainer/WagerLabel"

func _ready():
	value = StoredElements.wager
	max_value = min(StoredElements.max_wager, StoredElements.gold)
	wager_counter.text = str(StoredElements.wager)
	value_changed.connect(_on_value_changed)
	
	if max_value <= 0:
		editable = false
		wager_label.text = "[LOCKED]"
	else:
		editable = true
		wager_label.text = "WAGER"


func _on_value_changed(value: float):
	StoredElements.wager = value
	gold_counter.text = str(StoredElements.gold - StoredElements.wager)
	wager_counter.text = str(StoredElements.wager)
	AudioManager.get_node("Sounds/ButtonClick").play()
