extends CanvasLayer

onready var base: Control = find_node("BaseControl")
onready var title: Control = base.find_node("TitleScene")
onready var new_game: Button = base.find_node("NewGame")
onready var exit: Button = base.find_node("Exit")
onready var default_font: Font = Preloader.get_resource("Theme").default_font


func _ready() -> void:
	new_game.connect("pressed", self, "_on_new_game_pressed")
	exit.connect("pressed", self, "_on_exit_pressed")
	
	if OS.is_debug_build(): # not available in release build
		base.add_child(load("res://Debug/Debug.tscn").instance())

func _on_new_game_pressed() -> void:
	Global.new_game()
	title.visible = false

func _on_exit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
