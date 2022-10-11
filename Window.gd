extends VBoxContainer

onready var board = $Board
onready var options = $Options
onready var rng_seed = $Options/Seed
onready var tile = preload("res://Tile.tscn")

var mission_list
var fill_in_values
var bingo_options
const board_size = 25

var rng = RandomNumberGenerator.new()
var used_values = []
var regex = RegEx.new()

const rare_life_placeholder = "[rare_endemic_life]"
const quest_placeholder = "[quest]"
const monster_placeholder = "[monster]"
const non_elder_monster_placeholder = "[non_elder_monster]"
const species_placeholder = "[species]"
const life_placeholder = "[endemic_life]"

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

func roll_missions():
	# 2-4 restrictions
	# 1-2 gathering
	# 1-2 exploring
	# 1-2 battle
	# 4-6 quest/arena
	# remaining should be target missions
	used_values.clear()
	var board_missions = []
	
	# Save rng state
	rng_seed.text = str(rng.state)
	
	var restriction_count = rng.randi_range(2,4)
	var gathering_count = rng.randi_range(1,2)
	var exploring_count = rng.randi_range(1,2)
	var battle_count = rng.randi_range(1,2)
	var quest_count = rng.randi_range(4,6)

	board_missions.append_array(select_randomized_missions(get_mission_list_for(["restrictions"]), restriction_count))
	board_missions.append_array(select_randomized_missions(get_mission_list_for(["gathering"]), gathering_count))
	board_missions.append_array(select_randomized_missions(get_mission_list_for(["exploring"]), battle_count))
#	board_missions.append_array(get_missions_for_type("battle", battle_count))
#	board_missions.append_array(get_missions_for_type("quest", quest_count))
	board_missions.append_array(select_randomized_missions(get_mission_list_for(["target", "hunts"]), board_size - board_missions.size()))

	return board_missions

func select_randomized_missions(list, count):
	var board_missions = []
	for i in count:
		var m = null
		while m == null:
			m = list[rng.randi_range(0, list.size()-1)]
			var placeholder = regex.search(m)
			if placeholder != null:
				m = replace_placeholder(m, placeholder.get_string())
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
		return null

	var replacement = list[rng.randi_range(0, list.size()-1)]
	new_text = regex.sub(new_text, replacement)
	used_values.append(replacement)
	return new_text

func get_mission_list_for(types):
	var list = []
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
		var select = rng.randi_range(0,missions.size()-1)
		var mission_text = missions[select]
		missions.remove(select)

		var l = tile.instance()
		board.add_child(l)
		l.update_text(mission_text)

func _on_Options_pressed():
	print(bingo_options.keys())
	print(bingo_options["Generation"].keys())
	$PopupMenu.popup_centered()


func _on_SeededGenerate_pressed():
	rng.state = int($PopupMenu/OptionList/SharedSeed/CustomSeed.text)
	_on_Generate_pressed()
