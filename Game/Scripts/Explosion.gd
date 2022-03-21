extends Area2D

class_name Explosion

const GROW_SPEED: float = 25.0

onready var area: CollisionShape2D = find_node("ExplosionArea")
onready var animation: AnimatedSprite = find_node("Animation")
onready var sound: AudioStreamPlayer2D = find_node("Sound")

export var max_radius: float = 12.0
var is_free: bool = false


func _ready() -> void:
	animation.connect("animation_finished", self, "_on_animation_finished") # FACEPALM: animation must be stopped via code

func _physics_process(delta: float) -> void:
	var _radius = area.shape.radius + delta * GROW_SPEED
	if _radius >= max_radius:
		_radius = max_radius
		set_physics_process(false) # stop growing
		place_crater()
	area.shape.radius = _radius # growing the explosion area

func activate(pos: Vector2) -> void:
	is_free = false
	global_position = pos
	global_rotation = Global.player.global_rotation
	animation.flip_h = (randi() % 2) as bool # add some randomness
	animation.frame = 0
	animation.play()
	sound.play()
	set_physics_process(true) # start growing the explosion area

func place_crater():
	var crater = ExplosionManager.get_crater()
	crater.global_position = global_position
	# add some randomness (default crater radius is 22)
	crater.scale.x = max_radius / 22.0 * (0.8 + randf() * 0.4)
	crater.scale.y = max_radius / 22.0 * (0.8 + randf() * 0.4)
	crater.rotation = randf() * PI * 2.0

func _on_animation_finished():
	animation.stop()
	area.shape.radius = 0
	is_free = true
