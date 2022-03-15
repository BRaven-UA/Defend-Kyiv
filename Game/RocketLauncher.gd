extends Node2D

class_name RocketLauncher

onready var flame: Particles2D = $Flame
#onready var timer: Timer = $Timer

var trace_pool: Array


func activate() -> void:
	flame.restart()
	var trace = get_trace()
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

#func get_trace() -> Particles2D: # get reference to new trace from the trace pool
#	for trace in trace_pool: # search for free trace
#		if not trace.emmiting:
#			return trace
#
#	# add new instance to the pool if there no free traces left
#	var new_trace = Preloader.get_resource("Trace").instance()
#	trace_pool.append(new_trace)
#	return new_trace

#func trace_timeout() -> void:
#	pass
