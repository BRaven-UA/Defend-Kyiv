extends CanvasLayer

onready var base: Control = find_node("BaseControl")
onready var title: Control = base.find_node("TitleScene")
onready var hangar: Hangar = base.find_node("Hangar")
onready var new_game: Button = base.find_node("NewGame")
onready var settings: Button = base.find_node("Settings")
onready var exit: Button = base.find_node("Exit")
onready var default_font: Font = Preloader.get_resource("Theme").default_font


func _ready() -> void:
	new_game.connect("pressed", self, "_on_new_game_pressed")
	settings.connect("pressed", self, "_on_settings_pressed")
	exit.connect("pressed", self, "_on_exit_pressed")
	
	if OS.is_debug_build(): # not available in release build
		base.add_child(load("res://Debug/Debug.tscn").instance())
	
#	title_screen(false)
	title_screen(true)

func title_screen(state: bool) -> void:
	title.visible = state
	if state:
		title.grab_focus()

func _on_new_game_pressed() -> void:
	Global.new_game()
	title_screen(false)

func _on_settings_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
