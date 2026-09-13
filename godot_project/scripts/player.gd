extends "res://scripts/fighter_base.gd"

var input_dir = 0
var wants_jump = false
var wants_block = false

func _physics_process(delta):
	super._physics_process(delta)
	
	if state in ["IDLE", "WALK"]:
		velocity.x = input_dir * speed
		if input_dir != 0:
			state = "WALK"
			direction = input_dir
		else:
			state = "IDLE"
			
		if wants_jump and is_on_floor():
			velocity.y = jump_force
			
		if wants_block:
			state = "BLOCK"
			velocity.x = 0
			
	elif state == "BLOCK":
		if not wants_block:
			state = "IDLE"\n