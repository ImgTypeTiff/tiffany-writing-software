extends RayCast3D

@export var DLabel: RichTextLabel
var dialogueType: int
var body
var dialogue
var ControlType

func _process(delta: float) -> void:
	body = get_collider()
	
	if body == null:

		DLabel.text = ""
		return
	

	
	if body.is_in_group("interactable"):
		print(body.name, " is interactable.")
		check_dialogue()
	else:
		print(body.name, " is not interactable")


func check_dialogue():
	print('Checking Dialogue')
	if body.dialogue:
		dialogue = body.dialogue
		if dialogue == " ":
			print(body.name, " dialogue null")
			return
		else:
			print(dialogue)
		check_dialogue_type()



func check_dialogue_type():
	dialogueType = int(body.DialogueType)
	if dialogueType <= 1:
		ControlType = body.ControlType
	Set_Dialogue(dialogueType)

func Set_Dialogue(type):
	print(type)
	if type == 1:
		var finaldialogue = dialogue
		finaldialogue += " press "
		finaldialogue += ControlType["control"]
		DLabel.text = finaldialogue
	if type == 0:
		DLabel.text = dialogue

func interact():
	print(ControlType)
