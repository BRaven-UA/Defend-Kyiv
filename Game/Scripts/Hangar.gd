class_name Hangar
extends Control

const OVERFLOW := Color(1.0, 0.5, 0.5, 1.0)
enum {SHORT_NAME, NAME, DESCRIPTION, MIN_VALUE, DEFAULT_VALUE, VALUE, MAX_VALUE, STEP, PRICE, TOTAL}
const UPGRADES := [
	{SHORT_NAME: "REGEN", NAME: "Rocket generation per second", DESCRIPTION: "Replenishes over time the main rockets up to the maximum. The cost is for 0.1 rockets per second", PRICE: 50, MIN_VALUE: 0.5, DEFAULT_VALUE: 0.5, MAX_VALUE: 2.0, STEP: 0.1},
	{SHORT_NAME: "HIGHLIGHT", NAME: "Always highlight enemies", DESCRIPTION: "Enemies on the map will be highlighted permanently. Without this upgrade, the highlighting only appears near the crosshair", PRICE: 100},
	{SHORT_NAME: "FLARES", NAME: "Infrared countermeasure", DESCRIPTION: "Adds a system to counter enemy homing missiles. Reuse cooldown is %d seconds" % PlayerBase.FLARES_COOLDOWN, PRICE: 200}
]

var honor_points: int
var table_rows := []
onready var table: VBoxContainer = find_node("Table")
onready var total_cost_label: Label = table.find_node("TotalCost")
onready var header: Control = table.find_node("Header")
onready var honor_points_label: Label = table.find_node("HonorPoints")
onready var back_button: Button = find_node("Back")
onready var start_button: Button = find_node("Start")
onready var row_template: PackedScene = Preloader.get_resource("UpgradeRow")


func _ready() -> void:
	back_button.connect("pressed", self, "_on_back_button_pressed")
	start_button.connect("pressed", self, "_on_start_button_pressed")
	
	# Creating GUI for upgrades
	var above = header
	for upgrade_data in UPGRADES:
		var row = row_template.instance()
		row.connect("total_changed", self, "_on_row_total_changed")
		table.add_child_below_node(above, row, true)
		table_rows.append(row)
		above = row
	
	# setting focus navigation for newly added table rows
	var size = table_rows.size()
	for i in size:
		var previous = table_rows[i if i == 0 else i - 1].get_path()
		var next = table_rows[i + 1].get_path() if i < size - 1 else back_button.get_path()
		table_rows[i].focus_previous = previous
		table_rows[i].focus_neighbour_top = previous
		table_rows[i].focus_neighbour_bottom = next
		table_rows[i].focus_next = next
	var first = table_rows[0].get_path()
	table.focus_neighbour_bottom = first
	table.focus_next = first
	var last = table_rows[size - 1].get_path()
	back_button.focus_neighbour_top = last
	back_button.focus_previous = last

func new_game() -> void:
	honor_points = Global.config.honor_points
	honor_points_label.text = str(honor_points)
	_restore_upgrades()
	visible = true
	table.grab_focus()

func _restore_upgrades() -> void:
	var stored_upgrades = Global.config.upgrades # format: SHORT_NAME: VALUE
	for index in UPGRADES.size():
		var upgrade_data = UPGRADES[index]
		var key = upgrade_data[SHORT_NAME]
		# priority: stored value -> default value -> zero
		var value = stored_upgrades.get(key, upgrade_data.get(DEFAULT_VALUE, 0.0))
		upgrade_data[VALUE] = value
		table_rows[index].init(upgrade_data)

func _store_upgrades() -> void:
	for upgrade_data in UPGRADES:
		var key = upgrade_data[SHORT_NAME]
		Global.config.upgrades[key] = upgrade_data[VALUE]

func _calculate_total_cost() -> void:
	var total_cost := 0
	for upgrade_data in UPGRADES:
		total_cost += upgrade_data.get(TOTAL, 0)
	total_cost_label.text = str(total_cost)
	var can_afford = total_cost <= honor_points
	total_cost_label.set("custom_colors/font_color", Color.white if can_afford else OVERFLOW)
	start_button.disabled = !can_afford

func _on_row_total_changed() -> void:
	_calculate_total_cost()

func _on_back_button_pressed() -> void:
	visible = false
	Global.return_to_main_menu()

func _on_start_button_pressed() -> void:
	_store_upgrades()
	Global.config.honor_points = 0
	get_tree().change_scene_to(Preloader.get_resource("Game"))
	visible = false
