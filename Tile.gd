extends CenterContainer

onready var mission_text = $Label

func update_text(t = ""):
	mission_text.text = t
