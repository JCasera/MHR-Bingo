extends HBoxContainer

onready var clock = $Timer

var timer_on = false

var minutes = 0
var seconds = 0
var millies = 0

func _physics_process(delta):
	if timer_on:
		millies += delta * 100
		if millies > 100:
			millies -= 100
			seconds += 1
			if seconds > 59:
				seconds = 0
				minutes += 1
	
	clock.text = str("%03d:%02d:%02d" % [minutes, seconds, millies])


func _on_Start_pressed():
	minutes = 0
	seconds = 0
	millies = 0
	timer_on = true

func _on_Retire_pressed():
	timer_on = false
	clock.text = str("000:00:00")
