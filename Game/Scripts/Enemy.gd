class_name Enemy
extends Area2D

const HEIGHT: float = 1.0 # enemy's height above the ground

var data
var preview: Preview # link to preview
var is_permanent_highlighted: bool # activated by installing the appropriate update
onready var on_map_highlight: Sprite = find_node("OnMapHighlight")
onready var on_map_shadow: Sprite = find_node("OnMapShadow")
onready var on_map_picture: Sprite = find_node("OnMapPicture")


func _ready() -> void:
	is_permanent_highlighted = Global.upgrades["HIGHLIGHT"] as bool
	on_map_highlight.visible = is_permanent_highlighted
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")

func init(_data: Dictionary, pos: Vector2, rot: float) -> void:
	data = _data
	name = data[EnemyManager.NAME]
	position = pos
	rotation = rot
	on_map_shadow.position = Global.SHADOW.rotated(-rot) * 2.5
	
	var rarity = data[EnemyManager.RARITY]
	var color = Global.COLORS[rarity]
	on_map_highlight.self_modulate = color
	
	var frame_index = data[EnemyManager.FRAME]
	on_map_picture.frame = frame_index
	on_map_shadow.frame = frame_index
	
	preview = PoolManager.get_preview()
	if Global.game.path_follow:
		preview.set_meta("Offset", Global.pos_to_offset(pos))
	Global.game.preview_layer.add_child(preview)
	preview.call_deferred("init", pos, frame_index, color)

	monitoring = true
	on_map_picture.visible = true

func get_height() -> float:
	return HEIGHT

func destroy() -> void:
	on_map_highlight.visible = false
	on_map_picture.visible = false # hide picture and keep shadow as representation of remains
	preview.deactivate()
	
	data[EnemyManager.DESTROYED] += 1
	var rarity = data[EnemyManager.RARITY]
	var points = Global.POINTS[rarity]
	var flying_text = PoolManager.get_flying_text()
	flying_text.activate("+%d" % points, Global.COLORS[rarity], global_position)
	Global.game.increase_score(points)
	
	set_deferred("monitoring", false) # cannot change state at the current frame
	yield(get_tree(), "idle_frame") # waiting next frame
	var explosion_type = data[EnemyManager.EXPLOSION]
	var explosion: Explosion = PoolManager.get_explosion(explosion_type)
	Global.game.above_ground_layer.add_child(explosion)
	explosion.activate(Vector3(global_position.x, HEIGHT, global_position.y))

func _on_area_entered(area: Area2D) -> void:
	if area is Explosion:
		destroy()
	elif area is RocketBase:
		return
	else: # highlighting and show preview when under the crossair highlight area
		on_map_highlight.visible = true
		preview.activate()

func _on_area_exited(area: Area2D) -> void:
	if area is RocketBase or area is Explosion:
		return
	else: # cancel highlight when the crossair leave
		on_map_highlight.visible = is_permanent_highlighted
		preview.deactivate()
