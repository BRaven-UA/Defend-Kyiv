class_name Enemy
extends Area2D

const HEIGHT: float = 1.0 # enemy's height above the ground

var preview: Preview # link to preview
var rarity: int
var frame_index: int
var color: Color
var explosion_type: int
var anti_aircraft: int # type of ant-aircraft system
var is_destroyed: bool

onready var on_map_highlight: Sprite = find_node("OnMapHighlight")
onready var on_map_shadow: Sprite = find_node("OnMapShadow")
onready var on_map_picture: Sprite = find_node("OnMapPicture")


func _ready() -> void:
	on_map_highlight.self_modulate = color
	on_map_shadow.global_position = global_position + Global.SHADOW * 1.5
	on_map_picture.frame = frame_index
	
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	
	preview = Preloader.get_resource("Preview").instance()
	preview.init(global_position, frame_index, color)
	Global.preview_layer.add_child(preview)

func init(data: Dictionary, pos: Vector2, rot: float) -> void:
	frame_index = data[EnemyManager.FRAME]
	rarity = data[EnemyManager.RARITY]
	color = Global.COLOR[rarity]
	explosion_type = data[EnemyManager.EXPLOSION]
	anti_aircraft = data.get(EnemyManager.ANTIAIRCRAFT, EnemyManager.AA_NONE)
	position = pos
	rotation = rot

func get_height() -> float:
	return HEIGHT

func destroy() -> void:
	is_destroyed = true
	on_map_highlight.visible = false
	on_map_picture.visible = false # hide picture and keep shadow as representation of remains
	preview.deactivate(true) # deactivate and delete preview
	
	var _points = Global.POINTS[rarity]
	var _flying_text = PoolManager.get_flying_text()
	_flying_text.activate("+%d" % _points, Global.COLOR[rarity], global_position)
	Global.increase_score(_points)
	
	set_deferred("monitoring", false) # cannot change state at the current frame
	yield(get_tree(), "idle_frame") # waiting next frame
	var explosion: Explosion = PoolManager.get_explosion(explosion_type)
	explosion.activate(global_position)

func _on_area_entered(area: Area2D) -> void:
	if area is Explosion:
		destroy()
	else: # highlighting and show preview when under the crossair highlight area
		on_map_highlight.visible = true
		preview.activate()

func _on_area_exited(area: Area2D) -> void:
	if not (area is Explosion): # cancel highlight when the crossair leave
		on_map_highlight.visible = false
		preview.deactivate()
