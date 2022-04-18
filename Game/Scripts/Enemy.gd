extends Area2D

class_name Enemy

onready var on_map_picture: Sprite = find_node("OnMapPicture")
onready var on_map_shadow: Sprite = find_node("OnMapShadow")

var preview: Preview # link to preview
var texture_white: Texture = Preloader.get_resource("White")
var texture_atlas: Texture

var rarity: int
var frame_index: int
var color: Color
var explosion_type: int


func _ready() -> void:
	texture_atlas = on_map_picture.texture
	on_map_picture.frame = frame_index
	on_map_shadow.global_position = global_position + Global.SHADOW * 1.5
	
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
	position = pos
	rotation = rot

func _on_area_entered(area: Area2D) -> void:
	if area is Explosion:
		destroy()
	else: # highlighting and show preview when under the crossair highlight area
		on_map_picture.texture = texture_white
		on_map_picture.self_modulate = color
		on_map_picture.self_modulate.a = 0.5
#		yield(get_tree(), "physics_frame")
		preview.activate()

func _on_area_exited(area: Area2D) -> void:
	if not (area is Explosion): # back to deafult atate when the crossair leave
		on_map_picture.texture = texture_atlas
		on_map_picture.self_modulate = Global.COLOR_COMMON # reset to deafult white color
		preview.deactivate()

func destroy() -> void:
	on_map_picture.visible = false # hide picture and keep shadow as representation of remains
	preview.deactivate(true) # deactivate and delete
	
	var _points = Global.POINTS[rarity]
	var _flying_text = PoolManager.get_flying_text()
	_flying_text.activate("+%d" % _points, Global.COLOR[rarity], global_position)
	Global.increase_score(_points)
	
	set_deferred("monitoring", false) # cannot change state at the current frame
	yield(get_tree(), "idle_frame") # waiting next frame
	var explosion: Explosion = PoolManager.get_explosion(explosion_type)
	explosion.activate(global_position)
