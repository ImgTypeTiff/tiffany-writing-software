class_name GetFromGit
extends Node
## AUTHOR: Github @AcoAlexDev

## A utility class for downloading files and fetching content from public GitHub repositories and websites.
## This class provides async functions to:
## -Download files directly to disk
## -Fetch text content as strings  
## -Load images from URLs
## -Handle GitHub URLs automatically (converts to raw URLs)

## Usage examples:

###Github
##@onready var GetFromGitNode: GetFromGit = $GetFromGit
##func _ready() -> void:
##	print(await GetFromGitNode.get_string_content_from_github("https://github.com/godotengine/godot/blob/master/README.md"))

###Any Website
##@onready var GetFromGitNode: GetFromGit = $GetFromGit
##func _ready() -> void:
##	GetFromGitNode.download_file_from_website("https://dummyimage.com/300/09f/fff.png", "res://downloaded_image.png")

enum Operations {
	DOWNLOAD=0,
	GET_STRING=1,
	GET_IMAGE=2
}

const temp_path:String = "user://GetFromGit/temp/"
const request_timeout:float = 30

@export var debug_printing:bool = true

var request_queue:Array[GetFromGitData] = []
var returned:String = "ACO:NULL"
var returned_image:Image = null

@onready var http_request: HTTPRequest = HTTPRequest.new()

func _ready() -> void:
	DirAccess.make_dir_absolute("user://GetFromGit/")
	DirAccess.make_dir_absolute(temp_path)
	for file in DirAccess.open(temp_path).get_files():
		DirAccess.remove_absolute(temp_path + file)
		if debug_printing:
			print("GetFromGit: Cleared temp cache file: ", file)

#region Public Functions: Use these functions in your code

## This function downloads a file to your computer.
func download_file_from_website(url:String, download_path:String = "res://") -> void:
	if not download_path.is_absolute_path():
		push_error("GetFromGit Error: " + download_path + " is not an absolute file path")
		return
	if download_path.get_extension().is_empty():
		download_path += url.get_file()
		if download_path.get_extension().is_empty():
			push_error("GetFromGit Error: " + download_path + " is a folder path and not a file path to store data")
			return
	_git_add_to_queue(url, Operations.DOWNLOAD, download_path)

## This function downloads a file from git to your computer.
## download_path can either be a folder  and the filename and extension will be the same as on git
## or you specify filename and extension yourself.
func download_file_from_github(git_url:String, download_path:String = "res://") -> void:
	if download_path.get_extension().is_empty():
		download_path += git_url.get_file()
	download_file_from_website(_get_raw_url(git_url), download_path)

## Info: This function does not return a string immediately, so it must be called with await
func get_string_content_from_website(url:String) -> String:
	if url.get_extension().is_empty():
		push_error("GetFromGit Error: url: '" + url + "' is not a link to a file")
		return "ACO:ERROR"
	_git_add_to_queue(url, Operations.GET_STRING)
	while returned == "ACO:NULL":
		await get_tree().process_frame
	var sb:String = returned
	returned = "ACO:NULL"
	return sb

## Info: This function does not return a string immediately, so it must be called with await
func get_string_content_from_github(git_url:String) -> String:
	return await get_string_content_from_website(_get_raw_url(git_url))
	
## Info: This function does not return an image immediately, so it must be called with await
## When applying the image you maybe need to turn it into a ImageTexture first with ImageTexture.create_from_image(image)
func load_image_from_website(url:String) -> Image:
	if url.get_extension().is_empty():
		push_error("GetFromGit Error: url: '" + url + "' is not a link to a file")
		return
	var supported_image_extensions:Array[String] = ["png", "jpg", "jpeg", "svg", "ktx", "bmp", "webp", "tga"]
	if not url.get_extension() in supported_image_extensions:
		if debug_printing:
			push_warning("GetFromGit Warning: url '" + url + "' is not in supported image formates: ", supported_image_extensions, "\n It will still try to load the file but it is temporarily stored in ", temp_path)
	_git_add_to_queue(url, Operations.GET_IMAGE)
	while returned_image == null:
		await get_tree().process_frame
	var sb = returned_image
	returned_image = null
	return sb

## Info: This function does not return an image immediately, so it must be called with await
func load_image_from_github(git_url:String) -> Image:
	return await load_image_from_website(_get_raw_url(git_url))
	
func toggle_debug_printing(enabled:bool) -> void:
	debug_printing = enabled

func cancel_all_requests() -> void:
	request_queue.clear()
	if http_request != null:
		http_request.cancel_request()

#endregion

#region Internal Functions: Don't use directly

## Adds data to the request-queue.
func _git_add_to_queue(git_url:String, op:Operations=Operations.DOWNLOAD, os_path:String = "res://") -> void:
	var data:GetFromGitData = GetFromGitData.new()
	data.operation = op
	data.git_url = git_url
	data.os_path = os_path
	request_queue.append(data)
	if request_queue.size() == 1:
		_git_send_request()

## Sends an actual request to the internet.
## Calling this function will not work in this class rather use git_add_to_queue()
func _git_send_request() -> void:
	if not request_queue.size() > 0:
		push_error("GetFromGit Error: Queue cleared before git_request could be sent")
		return
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = request_timeout
	http_request.request_completed.connect(_git_request_completed)
	var error = http_request.request(request_queue[0].git_url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

## Called when the HTTP request is completed.
func _git_request_completed(result:int, response_code:int, _headers:PackedStringArray, body:PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("GetFromGit Error: Request failed with result: %s, response code: %s" % [result, response_code])
	if not request_queue.size() > 0:
		push_warning("GetFromGit Error: Queue cleared before git_request could be completed")
		return
	var request_data:GetFromGitData = request_queue[0]
	if request_data.operation == Operations.DOWNLOAD:
		var file = FileAccess.open(request_data.os_path, FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		if debug_printing:
			print("GetFromGit: Saved file to: ", request_data.os_path)
	elif request_data.operation == Operations.GET_STRING:
		returned = body.get_string_from_utf8()
		if debug_printing:
			print("GetFromGit: Returned string '" + returned + "'")
	elif request_data.operation == Operations.GET_IMAGE:
		var i = Image.new()
		if request_data.git_url.get_extension() == "png":
			i.load_png_from_buffer(body)
		elif request_data.git_url.get_extension() == "svg":
			i.load_svg_from_buffer(body)
		elif request_data.git_url.get_extension() == "jpg" or request_data.git_url.get_extension() == "jpeg":
			i.load_jpg_from_buffer(body)
		elif request_data.git_url.get_extension() == "ktx":
			i.load_ktx_from_buffer(body)
		elif request_data.git_url.get_extension() == "bmp":
			i.load_bmp_from_buffer(body)
		elif request_data.git_url.get_extension() == "tga":
			i.load_tga_from_buffer(body)
		elif request_data.git_url.get_extension() == "webp":
			i.load_webp_from_buffer(body)
		else:
			if request_data.git_url.get_extension().is_empty():
				push_error("GetFromGit Error: " + request_data.git_url + " has no valid file extension")
			else:
				var tpath:String = temp_path + request_data.git_url.get_file() + request_data.git_url.get_extension()
				var file = FileAccess.open(tpath, FileAccess.WRITE)
				if file != null:
					file.store_buffer(body)
					file.close()
					i = Image.load_from_file(tpath)
				else:
					push_error("GetFromGit Error: Couldn't create a file at path: " + temp_path + request_data.git_url.get_file() + request_data.git_url.get_extension())
		returned_image = i
		if debug_printing:
			print("GetFromGit: Returned image '%s' sucessfully" % request_data.git_url.get_file())
	request_queue.pop_front()
	http_request.queue_free()
	http_request = null
	if not request_queue.is_empty():
		await get_tree().process_frame
		_git_send_request()

## This function is currently very specific and easily breakable
func _get_raw_url(url:String) -> String:
	if "raw.githubusercontent.com" in url:
		return url
	else:
		var raw_url = "https://raw.githubusercontent.com/"
		var github_urls = ["https://github.com/", "http://github.com/", "github.com/"]
		for i in github_urls:
			if url.begins_with(i):
				url = url.trim_prefix("https://github.com/")
				break
		var url_parts:Array[String] = Array(Array(url.split("/")), TYPE_STRING, "", null)
		#url_parts.assign(url.split("/"))
		raw_url += url_parts.pop_front() + "/" #User
		raw_url += url_parts.pop_front() + "/" #Branch
		url_parts.pop_front() #blob is nou used in raw links
		raw_url += "refs/heads/"
		for i in url_parts:
			raw_url += i + "/"
		raw_url = raw_url.trim_suffix("/")
		return raw_url

#endregion
