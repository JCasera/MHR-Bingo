extends VBoxContainer

onready var board = $Board
onready var options = $Options
onready var rng_seed = $Options/Seed
onready var modes_list = $PopupMenu/OptionList/ModeList
onready var tile = preload("res://Tile.tscn")

var mission_list
var fill_in_values
var bingo_options
const board_size = 25
const values_exhausted = "Values Exhausted"

var rng = RandomNumberGenerator.new()
var used_values = []
var regex = RegEx.new()
var board_modes = ButtonGroup.new()

func _ready():
	rng.randomize()
	regex.compile("\\[[a-z_]*\\]")
	load_monsters()
	load_missions()
	load_options()

func load_missions():
	var f = File.new()
	f.open("res://data/Missions.json", File.READ)
	mission_list = parse_json(f.get_as_text())
	f.close()

func load_monsters():
	var f = File.new()
	f.open("res://data/values.json", File.READ)
	fill_in_values = parse_json(f.get_as_text())
	f.close()

func load_options():
	var f = File.new()
	f.open("res://data/options.json", File.READ)
	bingo_options = parse_json(f.get_as_text())
	f.close()
	var boards = bingo_options["mode"]
	for i in boards:
		var radbtn = CheckBox.new()
		modes_list.add_child(radbtn)
		radbtn.name = i
		radbtn.text = i.capitalize()
		radbtn.group = board_modes
	board_modes.get_buttons()[0].pressed = true

func roll_missions():
	used_values.clear()
	rng_seed.text = str(rng.state)
	return load_board_by_type()
	
func load_board_by_type():
	print("Creating board for " + board_modes.get_pressed_button().name)
	var generation_rules = bingo_options["mode"][board_modes.get_pressed_button().name]
	var board_missions = []
	
	for tile_type in generation_rules:
		var tile_count = rng.randi_range(tile_type[0], tile_type[1])
		if tile_count == -1:
			tile_count = board_size - board_missions.size()
		elif tile_count == -2:
			break
		board_missions.append_array(select_randomized_missions_for(tile_type.slice(2, tile_type.size()), tile_count))
	
	# Needed as sometimes we end up with 1 less than expected
	print("Missing " + str(board_size-board_missions.size()) + " tiles")
	while board_missions.size() < board_size:
		var filler_mission = select_randomized_missions_for(generation_rules[-1].slice(2,generation_rules[-1].size()), 1)
		if board_missions.has(filler_mission):
			continue
		board_missions.append_array(filler_mission)
		
	return board_missions

func select_randomized_missions_for(types, count):
	var list = get_mission_list_for(types)
	if list.size() == 0:
		return []
	var board_missions = []
	for i in count:
		var m = null
		while m == null:
			m = list[rng.randi_range(0, list.size()-1)]
			var placeholder = regex.search(m)
			if placeholder != null:
				var replacement = replace_placeholder(m, placeholder.get_string())
				if replacement == values_exhausted:
					return board_missions
				m = replacement
			if board_missions.has(m):
				m = null

		board_missions.append(m)
	return board_missions

func replace_placeholder(text, tag):
	var new_text = text

	var list = []
	for i in fill_in_values[tag]:
		if not used_values.has(i):
			list.append(i)

	if list.size() == 0:
		return values_exhausted

	var replacement = list[rng.randi_range(0, list.size()-1)]
	new_text = regex.sub(new_text, replacement)
	used_values.append(replacement)
	return new_text

func get_mission_list_for(types):
	var list = []
	
	if types[0] == "Any":
		types = mission_list.keys()
		
	for i in types:
		list.append_array(mission_list[i])
	return list


func _on_Generate_pressed():
	for i in board.get_children():
		board.remove_child(i)

	var missions = roll_missions()
	print("Mission Count: " + str(missions.size()))
	print(missions)
	print("\n")

	for i in board_size:
		var select = rng.randi_range(0, max(missions.size()-1, 0))
		if select >= missions.size():
			rng_seed.text = "Invalid Board - Not enough tiles"
			break
			
		var mission_text = missions[select]
		missions.remove(select)

		var l = tile.instance()
		board.add_child(l)
		l.update_text(mission_text)

func _on_Options_pressed():
	print(bingo_options.keys())
	print(bingo_options["mode"].keys())
	$PopupMenu.popup_centered()


func _on_SeededGenerate_pressed():
	rng.state = int($PopupMenu/OptionList/SharedSeed/CustomSeed.text)
	_on_Generate_pressed()
