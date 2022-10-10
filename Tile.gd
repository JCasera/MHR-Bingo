extends CenterContainer

onready var mission_text = $Label

var complete = false

func update_text(t = ""):
	mission_text.text = t

func update_text_display():
	if complete:
		mission_text.add_color_override("font_color", Color(0,0,0))
	else:
		mission_text.add_color_override("font_color", Color("ffffff"))

func _on_Tile_gui_input(event):
	# Grey out on click
	if event is InputEventMouseButton && event.pressed:
		complete = !complete
		update_text_display()
	pass


func _on_Tile_mouse_entered():
	mission_text.add_color_override("font_color_shadow", Color("ffffcc00"))

func _on_Tile_mouse_exited():
	mission_text.add_color_override("font_color_shadow", Color("00ffcc00"))
