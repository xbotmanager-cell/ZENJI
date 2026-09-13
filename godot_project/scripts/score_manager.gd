extends Node

var score = 0
var combo = 0
var combo_timer = 0.0

func _process(delta):
	if combo > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo = 0

func add_hit(damage):
	combo += 1
	combo_timer = 2.0
	score += damage * 10 + (combo * 5)\n