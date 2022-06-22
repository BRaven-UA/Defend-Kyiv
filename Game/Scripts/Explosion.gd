class_name Explosion
extends Area2D

const GROW_SPEED: float = 25.0

#var is_free: bool = false
export var max_radius: float = 12.0
var height: float
onready var area: CollisionShape2D = find_node("ExplosionArea")
onready var flash: Sprite = find_node("Flash")
onready var shockwave: Sprite = find_node("Shockwave")
onready var animation: AnimatedSprite = find_node("Animation")
onready var sound: AudioStreamPlayer2D = find_node("Sound")
onready var anim_names: PoolStringArray = animation.frames.get_animation_names()


func _ready() -> void:
	set_physics_process(false)
	animation.connect("animation_finished", self, "_on_animation_finished")

func _exit_tree() -> void:
	animation.stop() # FACEPALM: animation must be stopped via code

func _physics_process(delta: float) -> void:
	var _radius = area.scale.x + delta * GROW_SPEED
	if _radius >= max_radius:
		set_physics_process(false) # stop growing
		place_crater()
	area.scale = Vector2.ONE * _radius # growing the explosion area

func activate(pos: Vector3) -> void:
#	is_free = false
	area.scale = Vector2.ONE
	
	height = pos.y
	global_position = Vector2(pos.x, pos.z)
	global_rotation = Global.game.player.global_rotation
	
	var names_amount = anim_names.size()
	if names_amount > 1:
		animation.animation = anim_names[randi() % names_amount] # random animation
	animation.flip_h = (randi() % 2) as bool # add some randomness by flipping picture
	animation.frame = 0
	animation.play()
	
	sound.play()
	
	var _scale = lerp(1.0, 5.0, height / PlayerBase.HEIGHT) * Vector2.ONE
	shockwave.scale = _scale
	flash.scale = _scale
	GlobalTween.explosion_flash(flash, max_radius)
	GlobalTween.explosion_shockwave(shockwave, max_radius)
	
	set_physics_process(height < 10.0) # start growing the explosion area

func place_crater():
	if Global.game.ground_layer:
		var crater = PoolManager.get_crater()
		Global.game.ground_layer.add_child(crater)
		crater.global_position = global_position
		# add some randomness (default crater radius is 22)
		crater.scale.x = max_radius / 20.0 * (0.8 + randf() * 0.4)
		crater.scale.y = max_radius / 20.0 * (0.8 + randf() * 0.4)
		crater.rotation = randf() * PI * 2.0
		if Global.game.path_follow:
			crater.set_meta("Offset", Global.pos_to_offset(global_position))

func _on_animation_finished():
#	animation.stop() # FACEPALM: animation must be stopped via code
	if is_inside_tree():
		get_parent().remove_child(self)
#	is_free = true
