extends HBoxContainer

onready var board = $Board
onready var options = $Options
onready var tile = preload("res://Tile.tscn")

var mission_list
var fill_in_values
const board_size = 25

var rng = RandomNumberGenerator.new()
var used_values = []
var used_missions = []
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

func roll_missions():
	# 2-4 restrictions
	# 1-2 gathering
	# 1-2 exploring
	# 1-2 battle
	# 4-6 quest/arena
	# remaining should be target missions
	used_values.clear()
	used_missions.clear()
	var board_missions = []
	var restriction_count = rng.randi_range(2,4)
	var gathering_count = rng.randi_range(1,2)
	var exploring_count = rng.randi_range(1,2)
	var battle_count = rng.randi_range(1,2)
	var quest_count = rng.randi_range(4,6)

	board_missions.append_array(get_missions_for_type("restrictions", restriction_count))
	board_missions.append_array(get_missions_for_type("gathering", gathering_count))
	board_missions.append_array(get_missions_for_type("exploring", exploring_count))
#	board_missions.append_array(get_missions_for_type("battle", battle_count))
#	board_missions.append_array(get_missions_for_type("quest", quest_count))
	board_missions.append_array(get_missions_for_type("target", board_size - board_missions.size()))

	return board_missions

func get_missions_for_type(type, count):
	var board_missions = []
	for i in count:
		var m = null
		while m == null:
			m = get_mission(type, rng.randi_range(0, get_mission_count_by_type(type)-1))
			var placeholder = regex.search(m)
			if placeholder != null:
				m = replace_placeholder(m, placeholder.get_string())
		
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
	
func get_mission_count_by_type(mission_type):
	return mission_list[mission_type].size()

func get_mission(type, pos):
	return mission_list[type][pos]


func _on_Button_pressed():
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


func _on_Hide_pressed():
	options.hide()
