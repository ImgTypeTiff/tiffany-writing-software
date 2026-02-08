class_name GetFromGitData
extends Resource
## AUTHOR: Github @AcoAlexDev

## Resource class for the GetFromGit Plugin.
## For each request, one data is created and added to the queue

@export var operation:GetFromGit.Operations = GetFromGit.Operations.DOWNLOAD
@export var git_url:String = ""
@export var os_path:String = ""
