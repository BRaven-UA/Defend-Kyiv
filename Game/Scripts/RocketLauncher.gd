class_name RocketLauncher
extends Node2D

var trace_pool: Array # let each launcher has its own trace pool to prevent unnecessary adding/removing to the tree
onready var flame: Particles2D = $Flame


func activate(dir: Vector2) -> void:
	global_rotation = -dir.angle_to(Vector2.UP)
	var trace = get_trace()
	flame.restart()
	trace.restart()

func get_trace() -> Particles2D: # get reference to new trace from the trace pool
	for trace in trace_pool: # search for inactive trace
		if not trace.emitting:
			return trace
	
	# add new instance to the scene and to the pool if there no free traces left
	var new_trace = Preloader.get_resource("Trace").instance()
	trace_pool.append(new_trace)
	add_child(new_trace)
	return new_trace
