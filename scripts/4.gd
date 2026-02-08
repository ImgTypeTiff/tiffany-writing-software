extends GPUParticles2D

func notready():
	emitting = true
	$Timer.start()
	$Timer2.start()
func _on_timer_timeout() -> void:
	print("fun")
	$"../GPUParticles2D2".emitting = true

func _on_timer_2_timeout() -> void:
	pass # Replace with function body.
	$"../GPUParticles2D3".emitting = true




func _on_gpu_particles_2d_3_finished() -> void:
	notready()
