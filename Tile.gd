extends CenterContainer

onready var mission_text = $Label

var complete = false

func update_text(t = ""):
	mission_text.text = t


func _on_Tile_gui_input(event):
	# Highlight on Hover
	# Grey out on click
	if event is InputEventMouseButton && event.pressed:
		complete = !complete
		if complete:
			mission_text.add_color_override("font_color", Color(0,0,0))
		else:
			mission_text.add_color_override("font_color", Color("ffffff"))
	pass
