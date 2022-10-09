extends HBoxContainer

onready var board = $Board

var mission_list
var monster_list
const board_size = 25
var rng = RandomNumberGenerator.new()
var used_values = []

const rare_life_placeholder = "[rare_endemic_life]"
const quest_placeholder = "[quest]"
const monster_placeholder = "[monster]"
const non_elder_monster_placeholder = "[non_elder_monster]"
const species_placeholder = "[species]"
const life_placeholder = "[endemic_life]"

func _ready():
	rng.randomize()
	load_monsters()
	load_missions()	

func load_missions():
	var f = File.new()
	f.open("res://data/Missions.json", File.READ)
	mission_list = parse_json(f.get_as_text())
	f.close()

func load_monsters():
	var f = File.new()
	f.open("res://data/Creatures.json", File.READ)
	monster_list = parse_json(f.get_as_text())
	f.close()

func roll_missions():
	# 2-4 restrictions
	# 1-2 gathering
	# 1-2 exploring
	# 1-2 battle
	# 4-6 quest/arena
	# remaining should be target missions
	used_values = []
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
		var m = get_mission(type, rng.randi_range(0, get_mission_count_by_type(type)-1))
		m = finalize_mission(m)
		board_missions.append(m)
	return board_missions
	
func finalize_mission(m):
	var placeholder = ""
	if m.find(rare_life_placeholder) > 0:
		placeholder = rare_life_placeholder
	elif m.find(life_placeholder) > 0:
		placeholder = life_placeholder
	elif m.find(monster_placeholder) > 0:
		placeholder = monster_placeholder
	elif m.find(non_elder_monster_placeholder) > 0:
		placeholder = non_elder_monster_placeholder
	elif m.find(species_placeholder) > 0:
		placeholder = species_placeholder
	elif m.find(quest_placeholder) > 0:
		placeholder = quest_placeholder
	else:
		print("No placeholder for " + m)
		return m
	
	var fill = fill_in_placeholder(monster_list[placeholder])
	used_values.append(fill)
	return m.replace(placeholder, fill)

func fill_in_placeholder(list):
	var replacement_list = []
	for i in list:
		if not used_values.has(i):
			replacement_list.append(i)
	return list[rng.randi_range(0, replacement_list.size()-1)]

func get_mission_count_by_type(mission_type):
	return mission_list[mission_type].size()
	
func get_mission(type, pos):
	return mission_list[type][pos]


func _on_Button_pressed():
	for i in board.get_children():
		board.remove_child(i)
		
	var missions = roll_missions()
	
	for i in board_size:
		var select = rng.randi_range(0,missions.size()-1)
		var mission_text = missions[select]
		missions.remove(select)
		
		var l = Label.new()
		l.text = mission_text
		l.autowrap = true
		l.size_flags_horizontal = SIZE_EXPAND_FILL
		l.size_flags_vertical = SIZE_EXPAND_FILL
		board.add_child(l)
