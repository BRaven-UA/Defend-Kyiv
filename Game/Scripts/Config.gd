class_name Config
extends Resource

signal settings_changed

const PATH := "user://DefendKyiv.save"
const PASSWORD := "Glory to Ukraine!"
const BRIGHTNESS := 0.0
const CONTRAST := 1.0
const SATURATION := 1.0

export var brightness := BRIGHTNESS
export var contrast := CONTRAST
export var saturation := SATURATION
export var honor_points := 0
var _file := File.new()


func reset_settings() -> void:
	brightness = BRIGHTNESS
	contrast = CONTRAST
	saturation = SATURATION
	emit_signal("settings_changed")

# Returns new config loaded from user directory. If there is no saved config or a loading error then returns default config (self)
func load() -> Config:
	var config = self
	if _file.open_encrypted_with_pass(PATH, File.READ, PASSWORD) == OK:
		config = str2var(_file.get_as_text())
	_file.close()
	return config

func save() -> void:
	_file.open_encrypted_with_pass(PATH, File.WRITE, PASSWORD)
	_file.store_string(var2str(self))
	_file.close()
