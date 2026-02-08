extends Control

## Examples for usage of the GetFromGit Node

func _ready() -> void:
	var gfg:GetFromGit = GetFromGit.new()
	add_child(gfg)
	## Downlaod
	gfg.download_file_from_github("https://github.com/AcoAlexDev/GetFromGit-for-Godot/blob/main/LICENSE.md", "res://addons/GetFromGit/downloaded_license.md")
	
	## Get as String
	var content:String = await gfg.get_string_content_from_github("https://github.com/AcoAlexDev/GetFromGit-for-Godot/blob/main/README.md")
	print_debug("GetFromGit Example: ", content)
	
	## Load image
	var image = await gfg.load_image_from_github("https://github.com/AcoAlexDev/GetFromGit-for-Godot/blob/main/icon.png")
	var texture_rect = TextureRect.new()
	texture_rect.texture = ImageTexture.create_from_image(image)
	add_child(texture_rect)
	
	## All functions are also available as website-form e.g. gfg.download_file_from_website("YOUR_WEBSITE.com/file.txt")
	
