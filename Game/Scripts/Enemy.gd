extends Area2D

class_name Enemy

onready var on_map_picture: Sprite = find_node("OnMapPicture")
onready var on_map_shadow: Sprite = find_node("OnMapShadow")

export (Texture) var on_map_texture
export (Texture) var preview_texture
export (Global.RARITY) var rarity
export (PoolManager.EXPLOSION) var explosion_type = PoolManager.EXPLOSION.VehicleExplosion

var preview: Preview # link to preview


func _ready() -> void:
	on_map_picture.texture = on_map_texture
	on_map_shadow.global_position = global_position + Global.SHADOW * 1.5
	
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	
	preview = Preloader.get_resource("Preview").instance()
	Global.preview_layer.add_child(preview)
	yield(preview, "ready")
	preview.init(global_position, preview_texture, Global.COLOR[rarity])

func _on_area_entered(area: Area2D) -> void:
	if area is Explosion:
		destroy()
	else: # highlighting and show preview when under the crossair highlight area
		on_map_picture.texture = Preloader.get_resource("White")
		on_map_picture.self_modulate = Global.COLOR[rarity]
		on_map_picture.self_modulate.a = 0.5
#		yield(get_tree(), "physics_frame")
		preview.activate()

func _on_area_exited(area: Area2D) -> void:
	if not (area is Explosion): # back to deafult atate when the crossair leave
		on_map_picture.texture = on_map_texture
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
