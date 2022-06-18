class_name Hangar
extends Control

const OVERFLOW := Color(1.0, 0.5, 0.5, 1.0)
enum {SHORT_NAME, NAME, DESCRIPTION, MIN_VALUE, DEFAULT_VALUE, VALUE, MAX_VALUE, STEP, PRICE, TOTAL}

var UPGRADES := [
	{SHORT_NAME: "REGEN", NAME: "Rocket generation per second", DESCRIPTION: "Replenishes over time the main rockets up to the maximum. The cost is for 0.1 rockets per second", PRICE: 50, MIN_VALUE: 0.5, DEFAULT_VALUE: 0.5, MAX_VALUE: 2.0, STEP: 0.1},
	{SHORT_NAME: "HIGHLIGHT", NAME: "Always highlight enemies", DESCRIPTION: "Enemies on the map will be highlighted permanently. Without this upgrade, the highlighting only appears near the crosshair", PRICE: 100}
]
var honor_points = Global.config.honor_points
onready var table: VBoxContainer = find_node("Table")
onready var total_cost_label: Label = table.find_node("TotalCost")
onready var header: Control = table.find_node("Header")
onready var honor_points_label: Label = table.find_node("HonorPoints")
onready var back_button: Button = find_node("Back")
onready var start_button: Button = find_node("Start")
onready var row_template: PackedScene = Preloader.get_resource("UpgradeRow")


func _ready() -> void:
	honor_points_label.text = str(honor_points)
	
	back_button.connect("pressed", self, "_on_back_button_pressed")
	start_button.connect("pressed", self, "_on_start_button_pressed")
	
	# Creating GUI for upgrades
	var rows := [] # helper array for setting focus navigation
	var above = header
	for upgrade_data in UPGRADES:
		var row = row_template.instance()
		row.connect("total_changed", self, "_on_row_total_changed")
		row.call_deferred("init", upgrade_data)
		table.add_child_below_node(above, row, true)
		rows.append(row)
		above = row
	
	# setting focus navigation for newly added rows
	var size = rows.size()
	for i in size:
		var previous = rows[i if i == 0 else i - 1].get_path()
		var next = rows[i + 1].get_path() if i < size - 1 else back_button.get_path()
		rows[i].focus_previous = previous
		rows[i].focus_neighbour_top = previous
		rows[i].focus_neighbour_bottom = next
		rows[i].focus_next = next
	var first = rows[0].get_path()
	table.focus_neighbour_bottom = first
	table.focus_next = first
	var last = rows[size - 1].get_path()
	back_button.focus_neighbour_top = last
	back_button.focus_previous = last
	
	table.grab_focus()

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
	Global.return_to_main_menu()

func _on_start_button_pressed() -> void:
	var selected_upgrades := {}
	for upgrade_data in UPGRADES:
		selected_upgrades[upgrade_data[SHORT_NAME]] = upgrade_data[VALUE]
	Global.upgrades = selected_upgrades
	Global.config.honor_points = 0
	get_tree().change_scene_to(Preloader.get_resource("Game"))
