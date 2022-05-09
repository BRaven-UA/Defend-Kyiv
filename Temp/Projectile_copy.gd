#class_name Projectile
extends Particles2D

onready var timer: Timer = find_node("Timer")


func _ready() -> void:
	amount = EnemyManager.AA_CANNON_PARTICLES
	timer.connect("timeout", self, "_on_timer_timeout")

func activate(pos: Vector3, target: Node2D) -> void:
	if Global.midair_layer:
		Global.midair_layer.add_child(self)
#	var target_pos_2D = target.global_position
#	var target_pos_3D = Vector3(target_pos_2D.x, target.HEIGHT, target_pos_2D.y)
#
#	var direction = (target_pos_3D - pos).normalized()
#	var distance = (target_pos_3D - pos).length()
#	var time = distance / process_material.initial_velocity
#
#	if target is PlayerBase:
#		var path_follow = Global.path_follow
#		if path_follow:
#			var scroll_speed = path_follow.scroll_speed
#			var offset = path_follow.offset
#			var path_2D = path_follow.get_parent()
#			var curve = path_2D.curve
#			var new_base_pos = curve.interpolate_baked(offset + scroll_speed * time, true)
#			target_pos_2D = new_base_pos + target.position
#
#	var target_predicted_pos = target_pos_2D + target.velocity * time
	
	var target_pos_2D = target.global_position
	var target_pos_3D = Vector3(target_pos_2D.x, target.HEIGHT, target_pos_2D.y)
	
	var target_velocity_3D = Vector3.ZERO
	
	if target is PlayerBase:
		var target_local_velocity = target.velocity
		
		var path_follow = Global.path_follow
		if path_follow:
			var scroll_velocity = Vector2(0, -path_follow.scroll_speed)
			target_local_velocity += scroll_velocity
		
		var target_velocity_2D = target_local_velocity.rotated(target.global_rotation) # converting to global coords
		target_velocity_3D = Vector3(target_velocity_2D.x, 0, target_velocity_2D.y)
	printt("Terget velocity (A):", target_velocity_3D)
	
	var speed = process_material.initial_velocity
	var vector_to_target = target_pos_3D - pos
	printt("Vector to target (C):", vector_to_target)
	
	var _targ_vel_proj = target_velocity_3D.project(vector_to_target).length()
	var _vel_proj = sqrt(pow(_targ_vel_proj, 2) + pow(speed, 2) - pow(target_velocity_3D.length(), 2))
	var _total_vel_proj = _targ_vel_proj + _vel_proj
#	var _coef = _total_vel_proj / vector_to_target.length()
#	var _proj_vector = vector_to_target * _coef
	var _proj_vector = vector_to_target.normalized() * _total_vel_proj
	printt("C1 + C2:", _proj_vector)
	
	var shoot_vector = _proj_vector + target_velocity_3D
	printt("B:", shoot_vector)
	printt("B len check:", speed, shoot_vector.length())
	
	var time = vector_to_target.length() / (shoot_vector.length() + target_velocity_3D.length())
	printt("Time:", time)
	
	global_position = Vector2(pos.x, pos.z)
	global_rotation = -Vector2(shoot_vector.x, shoot_vector.z).angle_to(Vector2.UP)
	scale.y = shoot_vector.y * time / Global.player.HEIGHT
	
#	var spread = process_material.spread
#	var radius = sin(deg2rad(spread)) * distance
#
#	global_position = Vector2(pos.x, pos.z)
#	global_rotation = -Vector2(direction.x, direction.z).angle_to(Vector2.UP)
#	scale.y = 1.0 - direction.y
	lifetime = time
	restart()
	
	timer.start(time)

func _on_timer_timeout() -> void:
	timer.stop()
	get_parent().remove_child(self)

