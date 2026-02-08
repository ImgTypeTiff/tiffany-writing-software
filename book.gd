extends AnimationPlayer

func _ready() -> void:
	self.play("CubeAction_005")

func _on_animation_finished(anim_name: StringName) -> void:
	self.play("CubeAction_005")
