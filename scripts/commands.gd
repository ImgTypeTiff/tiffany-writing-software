extends Node

# Syntax: Callable(object, "method_name")
var my_callable = Callable(self, "Good_Morning")




func Good_Morning():
	var Label1: RichTextLabel = $OUTPUT
	Label1.text = "
	Good morning
	
	Welcome to the TIFFANY PROJECT INSTALL HUB
	
	Please run \"tiffman -S commands\"
	"
