extends Area2D

class_name Enemy

onready var on_map_picture: Sprite = find_node("OnMapPicture")
onready var on_map_shadow: Sprite = find_node("OnMapShadow")
#onready var preview: Sprite = find_node("Preview")
#onready var preview_shadow: Sprite = find_node("PreviewShadow")
#onready var preview_picture: Sprite = find_node("PreviewPicture")

export (Texture) var on_map_texture
export (Texture) var preview_texture
export (Global.RARITY) var rarity
export (ExplosionManager.EXPLOSION) var explosion_type = ExplosionManager.EXPLOSION.VehicleExplosion

var preview: Preview # link to active preview


func _ready() -> void:
	on_map_picture.texture = on_map_texture
	on_map_shadow.global_position = global_position + Global.SHADOW * 1.5
#	preview_picture.texture = preview_texture
#	preview.visible = false
#	preview.self_modulate = Global.COLOR[rarity]
	
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")

func _on_area_entered(area: Area2D) -> void:
	if area is Explosion:
		destroy()
	else: # highlighting when under the crossair
		on_map_picture.texture = Preloader.get_resource("White")
		on_map_picture.self_modulate = Global.COLOR[rarity]
		
#		var _direction = global_position - area.global_position
#		preview.rotation = _direction.angle() + 0.785398
#		preview_picture.global_rotation = Global.player.global_rotation
#		preview.visible = true
		
		yield(get_tree(), "physics_frame")
		preview = PreviewManager.activate_preview(global_position, preview_texture, Global.COLOR[rarity])

func _on_area_exited(area: Area2D) -> void:
	if not (area is Explosion): # cancel highlighting when the crossair leave
		on_map_picture.texture = on_map_texture
		on_map_picture.self_modulate = Global.COLOR_COMMON # reset to deafult white color
#		preview.visible = false
		_deactivate_preview()

func _deactivate_preview() -> void:
	if preview:
		PreviewManager.deactivate_preview(preview)
		preview = null

func destroy() -> void:
	on_map_picture.visible = false # hide picture and keep shadow as representation of remains
#	preview.visible = false
	_deactivate_preview()
	Global.increase_score(Global.POINTS[rarity])
	
	set_deferred("monitoring", false) # cannot change state at the current frame
	yield(get_tree(), "idle_frame") # waiting next frame
	var explosion: Explosion = ExplosionManager.get_explosion(explosion_type)
	explosion.activate(global_position)
