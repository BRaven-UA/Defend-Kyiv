class_name UpgradeRow
extends PanelContainer

signal total_changed

const INSTALLED := Color(0.6, 0.8, 1.0, 1.0)
const INSTALLED_SELECTED := Color(0.4, 0.7, 1.0, 1.0)
const SELECTED := Color(0.7, 0.7, 0.7, 1.0)
const DEFAULT := Color.transparent

var data: Dictionary
onready var quantity_label: Label = find_node("Quantity")
onready var name_label: Label = find_node("Name")
onready var description_label: Label = find_node("Description")
onready var slider: Slider = find_node("Slider")
onready var price_label: Label = find_node("Price")
onready var total_label: Label = find_node("Total")


func _ready() -> void:
	connect("focus_entered", self, "_on_focus_entered")
	slider.connect("focus_exited", self, "_on_slider_focus_exited")
	slider.connect("value_changed", self, "_on_slider_value_changed")

func init(_data: Dictionary) -> void:
	data = _data
	description_label.visible = false
	slider.visible = false
	name_label.text = data[Hangar.NAME]
	price_label.text = str(data[Hangar.PRICE])
	description_label.text = data[Hangar.DESCRIPTION]
	slider.min_value = data.get(Hangar.MIN_VALUE, 0.0)
	slider.max_value = data.get(Hangar.MAX_VALUE, 1.0)
	slider.step = data.get(Hangar.STEP, 1.0)
	slider.value = data.get(Hangar.DEFAULT_VALUE, 0.0) # also triggers `value_changed` signal

func _on_focus_entered() -> void:
	self_modulate = INSTALLED_SELECTED if slider.value else SELECTED
	description_label.visible = true
	slider.visible = true
	slider.grab_focus()

func _on_slider_focus_exited() -> void:
	self_modulate = INSTALLED if slider.value else DEFAULT
	description_label.visible = false
	slider.visible = false

func _on_slider_value_changed(value: float) -> void:
	data[Hangar.VALUE] = value
	quantity_label.text = str(value)
	var request_value = value - slider.min_value
	var total = request_value / slider.step * data[Hangar.PRICE]
	data[Hangar.TOTAL] = total
	total_label.text = str(total)
	emit_signal("total_changed")
