extends Control

func _ready():
	var texture_size = $Sprite2D.texture.get_size()
	var actual_size = texture_size * $Sprite2D.scale
	print("Actual displayed size: ", actual_size)

	# You can also get individual components
	var actual_width = actual_size.x
	var actual_height = actual_size.y
	print("Actual width: ", actual_width, " Actual height: ", actual_height)
	self.size = actual_size
