extends Node

var player
var enemy
var score_manager
var attack_system

func _ready():
	attack_system = load("res://scripts/attack_system.gd").new()
	add_child(attack_system)

func execute_attack(attacker, type: String):
	if attacker.state in ["HURT", "DEAD", "ATTACK"]: return
	
	var atk = attack_system.attacks[type]
	if atk.energy < 0 and attacker.energy < abs(atk.energy):
		return
		
	attacker.state = "ATTACK"
	attacker.attack_cooldown = atk.cooldown
	attacker.energy = clamp(attacker.energy + atk.energy, 0, attacker.max_energy)
	attacker.velocity.x = 0
	
	var anim = "punch" if type == "PUNCH" else "kick"
	if type == "SPECIAL": anim = "special"
	attacker.play_anim(anim)
	
	var defender = enemy if attacker == player else player
	
	var dist = defender.position.x - attacker.position.x
	if sign(dist) == attacker.direction and abs(dist) <= atk.range:
		if abs(defender.position.y - attacker.position.y) < 100:
			defender.take_damage(atk.damage, atk.kb)
			
			create_hit_effect(defender.position + Vector2(0, -90))
			get_parent().camera.shake(0.2, 10)
			
			if attacker == player and score_manager:
				score_manager.add_hit(atk.damage)

func create_hit_effect(pos: Vector2):
	var flash = ColorRect.new()
	flash.size = Vector2(40, 40)
	flash.position = pos - Vector2(20, 20)
	flash.color = Color.WHITE
	get_parent().add_child(flash)
	var tw = create_tween()
	tw.tween_property(flash, "scale", Vector2(2, 2), 0.15)
	tw.parallel().tween_property(flash, "modulate:a", 0.0, 0.15)
	tw.tween_callback(flash.queue_free)\n