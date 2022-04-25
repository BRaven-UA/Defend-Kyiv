class_name Explosion
extends Area2D

const GROW_SPEED: float = 25.0

onready var area: CollisionShape2D = find_node("ExplosionArea")
onready var flash: Sprite = find_node("Flash")
onready var shockwave: Sprite = find_node("Shockwave")
onready var animation: AnimatedSprite = find_node("Animation")
onready var sound: AudioStreamPlayer2D = find_node("Sound")
onready var anim_names: PoolStringArray = animation.frames.get_animation_names()

export var max_radius: float = 12.0
var is_free: bool = false


func _ready() -> void:
	animation.connect("animation_finished", self, "_on_animation_finished")

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
	
	var names_amount = anim_names.size()
	if names_amount > 1:
		animation.animation = anim_names[randi() % names_amount] # random animation
	animation.flip_h = (randi() % 2) as bool # add some randomness by flipping picture
	animation.frame = 0
	animation.play()
	
	GlobalTween.explosion_flash(flash, max_radius)
	GlobalTween.explosion_shockwave(shockwave, max_radius)
	
	sound.play()
	
	set_physics_process(true) # start growing the explosion area

func place_crater():
	var crater = PoolManager.get_crater()
	crater.global_position = global_position
	# add some randomness (default crater radius is 22)
	crater.scale.x = max_radius / 22.0 * (0.8 + randf() * 0.4)
	crater.scale.y = max_radius / 22.0 * (0.8 + randf() * 0.4)
	crater.rotation = randf() * PI * 2.0

func _on_animation_finished():
	animation.stop() # FACEPALM: animation must be stopped via code
	area.shape.radius = 0
#	get_parent().remove_child(self)
	is_free = true
