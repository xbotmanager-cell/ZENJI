extends Node

var enemy
var player
var combat
var attack_timer = 0.0

func _process(delta):
	if enemy.state in ["HURT", "DEAD"] or player.state == "DEAD":
		return
		
	var dist = player.position.x - enemy.position.x
	enemy.direction = 1 if dist > 0 else -1
	
	if enemy.state in ["IDLE", "WALK"]:
		if abs(dist) > 150:
			enemy.velocity.x = enemy.direction * enemy.speed * 0.7
			enemy.state = "WALK"
		else:
			enemy.velocity.x = 0
			enemy.state = "IDLE"
			
			attack_timer -= delta
			if attack_timer <= 0:
				attack_timer = randf_range(0.5, 1.5)
				if randf() > 0.5:
					combat.execute_attack(enemy, "PUNCH")
				else:
					combat.execute_attack(enemy, "KICK")
