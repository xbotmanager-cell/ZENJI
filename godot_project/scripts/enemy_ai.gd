extends Node

var enemy
var player
var combat
var attack_timer = 0.0
var block_timer = 0.0

func _process(delta):
	if not enemy or not player or not combat: return
	
	if enemy.state in ["HURT", "DEAD", "FATALITY", "FATALITY_VICTIM", "GRABBED"] or player.state == "DEAD":
		enemy.wants_left = false
		enemy.wants_right = false
		enemy.wants_up = false
		enemy.wants_down = false
		enemy.wants_block = false
		return
		
	var dist = player.position.x - enemy.position.x
	var abs_dist = abs(dist)
	
	if enemy.state not in ["ATTACK", "DODGE"]:
		if abs_dist > 180:
			enemy.wants_right = dist > 0
			enemy.wants_left = dist < 0
		elif abs_dist < 80:
			# Too close, maybe retreat
			enemy.wants_right = dist < 0
			enemy.wants_left = dist > 0
		else:
			enemy.wants_right = false
			enemy.wants_left = false
		
	if player.state == "ATTACK" and abs_dist < 200:
		if randf() > 0.4 and block_timer <= 0:
			enemy.wants_block = true
			block_timer = 0.5
			# Maybe crouch block
			if player.current_attack == "LOW_KICK":
				enemy.wants_down = true
			else:
				enemy.wants_down = false
	
	if block_timer > 0:
		block_timer -= delta
		if block_timer <= 0:
			enemy.wants_block = false
			enemy.wants_down = false
			
	if enemy.state in ["IDLE", "WALK", "CROUCH", "BLOCK"]:
		attack_timer -= delta
		if attack_timer <= 0 and abs_dist <= 220:
			attack_timer = randf_range(0.4, 1.5)
			enemy.wants_block = false
			if abs_dist <= 110 and randf() > 0.8:
				combat.execute_attack(enemy, "GRAB")
			elif randf() > 0.6:
				enemy.state = "CROUCH" if randf() > 0.5 else "IDLE"
				combat.execute_attack(enemy, "PUNCH")
			elif randf() > 0.4:
				enemy.state = "CROUCH" if randf() > 0.5 else "IDLE"
				combat.execute_attack(enemy, "KICK")
			elif enemy.energy >= 50 and randf() > 0.7:
				combat.execute_attack(enemy, "SPECIAL")
