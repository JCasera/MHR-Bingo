extends CenterContainer

onready var mission_text = $Label
onready var bg = $Background

var complete = false
var tracked = false
var count = -1
var total = -1
var original_text = ""

var track_code = RegEx.new()

func _ready():
	track_code.compile("<T>(\\d+)")

func update_text(t = ""):
	original_text = t
	var result = track_code.search(original_text)
	if result == null:
		mission_text.text = t
		return
		
	tracked = true
	count = 0
	total = int(result.get_string(1))
	mission_text.text = track_code.sub(original_text, str(count)+"/"+str(total))

func update_text_display():
	if tracked:
		mission_text.text = track_code.sub(original_text, str(count)+"/"+str(total))
		
	if complete:
		mission_text.add_color_override("font_color", Color("828282"))
		bg.self_modulate = Color("828282")
	else:
		mission_text.add_color_override("font_color", Color("ffffff"))
		bg.self_modulate = Color.white

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
