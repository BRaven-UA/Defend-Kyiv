class_name Config
extends Resource

signal settings_changed

const PATH := "user://DefendKyiv.save"
const DEBUG_PATH := "user://Debug.save"
const PASSWORD := "Glory to Ukraine!"
const VOLUME := 1.0
const PREVIEW := true
const BRIGHTNESS := 0.0
const CONTRAST := 1.0
const SATURATION := 1.0

export var master_volume := VOLUME
export var helicopter_volume := VOLUME
export var preview := PREVIEW
export var brightness := BRIGHTNESS
export var contrast := CONTRAST
export var saturation := SATURATION
export var honor_points := 0
export var upgrades: Dictionary
var _file := File.new()


func reset_settings() -> void:
	master_volume = VOLUME
	helicopter_volume = VOLUME
	preview = PREVIEW
	brightness = BRIGHTNESS
	contrast = CONTRAST
	saturation = SATURATION
	emit_signal("settings_changed")

# Returns new config loaded from user directory. If there is no saved config or a loading error then returns default config (self)
func load() -> Config:
	var config = self
	var error
	if Global.game_mode == Global.GAMEMODE.DEBUG:
		error = _file.open(DEBUG_PATH, File.READ)
	else:
		error = _file.open_encrypted_with_pass(PATH, File.READ, PASSWORD)
	if error == OK:
		config = str2var(_file.get_as_text())
	_file.close()
	return config

func save() -> void:
	if Global.game_mode == Global.GAMEMODE.DEBUG:
		_file.open(DEBUG_PATH, File.WRITE)
	else:
		_file.open_encrypted_with_pass(PATH, File.WRITE, PASSWORD)
	_file.store_string(var2str(self))
	_file.close()
