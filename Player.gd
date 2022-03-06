extends Area2D

const PLAYER_SPEED: int = 300

var horizontal_limit: int
var vertical_limit: int


func _ready() -> void:
	var player_radius = $CollisionShape2D.shape.radius
	var viewport_size = get_viewport_rect()
	horizontal_limit = viewport_size.size.x / 2 - player_radius
#	horizontal_limit = OS.window_size.x / 2 - player_radius
#	horizontal_limit = ProjectSettings.get_setting("display/window/size/width") / 2 - player_radius
	vertical_limit = viewport_size.size.y / 2 - player_radius
#	vertical_limit = OS.window_size.y / 2 - player_radius
#	vertical_limit = ProjectSettings.get_setting("display/window/size/height") / 2 - player_radius

func _process(delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x += Input.get_action_strength("ui_right")
	direction.x -= Input.get_action_strength("ui_left")
	direction.y -= Input.get_action_strength("ui_up")
	direction.y += Input.get_action_strength("ui_down")
	
	var velocity: Vector2 = direction.normalized() * delta * PLAYER_SPEED
	position += velocity.rotated(-rotation)
	position.x = clamp(position.x, -horizontal_limit, horizontal_limit)
	position.y = clamp(position.y, -vertical_limit, vertical_limit)
