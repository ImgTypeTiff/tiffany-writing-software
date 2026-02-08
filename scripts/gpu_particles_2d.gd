extends GPUParticles2D


func _on_finished() -> void:
	explode.explode()

func hi():
	self.emitting = true
