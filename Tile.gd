extends CenterContainer

onready var mission_text = $Label

var complete = false
var tracked = false
var count = -1
var total = -1
var original_text = ""

const track_code = "<T>"

func update_text(t = ""):
	original_text = t
	if not track_code in t:
		mission_text.text = t
		return
		
	tracked = true
	count = 0
	total = int(original_text.right(t.find(track_code))[3])
	mission_text.text = original_text.replace(track_code, str(count)+"/")

func update_text_display():
	if tracked:
		mission_text.text = original_text.replace(track_code, str(count)+"/")
	if complete:
		mission_text.add_color_override("font_color", Color(0,0,0))
	else:
		mission_text.add_color_override("font_color", Color("ffffff"))

func _on_Tile_gui_input(event):
	# Grey out on click
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == BUTTON_LEFT && not complete:
			if tracked && count < total:
				count += 1
			complete = (count == total)
		elif event.button_index == BUTTON_RIGHT:
			if tracked && count > 0:
				count -= 1
			complete = false
		
		update_text_display()
	pass


func _on_Tile_mouse_entered():
	mission_text.add_color_override("font_color_shadow", Color("ffffcc00"))

func _on_Tile_mouse_exited():
	mission_text.add_color_override("font_color_shadow", Color("00ffcc00"))
