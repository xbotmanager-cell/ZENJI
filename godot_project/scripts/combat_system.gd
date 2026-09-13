extends Node

var player
var enemy
var score_manager
var attack_system

func _ready():
	attack_system = load("res://scripts/attack_system.gd").new()
	add_child(attack_system)

func execute_attack(attacker, input_type: String):
	if attacker.state in ["HURT", "DEAD", "FATALITY", "FATALITY_VICTIM", "GRABBED", "DODGE"]: return
	
	var is_crouching = attacker.state == "CROUCH"
	var atk_key = ""
	
	if input_type == "PUNCH":
		if is_crouching: atk_key = "UPPERCUT"
		elif attacker.state == "ATTACK" and attacker.current_attack == "JAB" and attacker.attack_phase == "recovery": atk_key = "CROSS"
		elif attacker.state == "ATTACK": return
		else: atk_key = "JAB"
	elif input_type == "KICK":
		if attacker.state == "ATTACK": return
		if is_crouching: atk_key = "LOW_KICK"
		else: atk_key = "HIGH_KICK"
	elif input_type == "GRAB":
		if attacker.state == "ATTACK": return
		atk_key = "GRAB"
	elif input_type == "SPECIAL":
		if attacker.state == "ATTACK": return
		atk_key = "SPECIAL"
		
	var atk = attack_system.attacks[atk_key]
	if atk.energy < 0 and attacker.energy < abs(atk.energy):
		return
		
	if attacker.attack_tween: attacker.attack_tween.kill()
		
	attacker.state = "ATTACK"
	attacker.current_attack = atk_key
	attacker.attack_phase = "startup"
	attacker.energy = clamp(attacker.energy + atk.energy, 0, attacker.max_energy)
	
	if atk_key in ["CROSS", "HIGH_KICK", "UPPERCUT"]:
		attacker.velocity.x = attacker.direction * 150
	else:
		attacker.velocity.x = 0
	
	attacker.set_pose(atk.anim, atk.startup)
	
	var tw = attacker.create_tween()
	attacker.attack_tween = tw
	tw.tween_interval(atk.startup)
	tw.tween_callback(func():
		attacker.attack_phase = "active"
		if atk_key == "GRAB":
			_check_grab(attacker)
		else:
			_check_hit(attacker, atk_key, atk)
	)
	tw.tween_interval(atk.active)
	tw.tween_callback(func():
		attacker.attack_phase = "recovery"
		if not (atk_key == "GRAB" and (enemy if attacker == player else player).state == "GRABBED"):
			attacker.set_pose("IDLE", atk.recovery)
	)
	tw.tween_interval(atk.recovery)
	tw.tween_callback(func():
		if attacker.state == "ATTACK":
			attacker.state = "IDLE"
		attacker.current_attack = ""
		attacker.attack_phase = ""
	)

func _check_hit(attacker, atk_key, atk):
	var defender = enemy if attacker == player else player
	var dist = defender.position.x - attacker.position.x
	
	if sign(dist) == attacker.direction and abs(dist) <= atk.range:
		if abs(defender.position.y - attacker.position.y) < 150:
			if atk_key in ["CROSS", "HIGH_KICK", "SPECIAL", "UPPERCUT"]:
				hit_stop(0.15)
			else:
				hit_stop(0.05)
				
			defender.take_damage(atk.damage, atk.kb, atk.type)
			create_hit_effect(defender.position + Vector2(0, -90), attacker.neon_color)
			get_parent().camera.shake(0.3 if atk.damage >= 15 else 0.15, 15 if atk.damage >= 15 else 8)
			
			if attacker == player and score_manager:
				score_manager.add_hit(atk.damage)

func _check_grab(attacker):
	var defender = enemy if attacker == player else player
	var dist = defender.position.x - attacker.position.x
	if sign(dist) == attacker.direction and abs(dist) <= 100:
		if defender.state not in ["DEAD", "FATALITY", "FATALITY_VICTIM", "DODGE", "GRABBED", "ATTACK"]:
			if attacker.attack_tween: attacker.attack_tween.kill()
			if defender.attack_tween: defender.attack_tween.kill()
			
			attacker.state = "ATTACK"
			defender.state = "GRABBED"
			
			hit_stop(0.1)
			
			var tw = attacker.create_tween()
	attacker.attack_tween = tw
		attacker.attack_tween = tw
			tw.tween_callback(func():
				attacker.set_pose("GRAB_HOLD", 0.2)
				defender.set_pose("HURT", 0.2)
			)
			tw.tween_interval(0.3)
			tw.tween_callback(func():
				attacker.set_pose("FATALITY_SLAM", 0.15)
				defender.set_pose("FATALITY_VICTIM", 0.15)
				defender.velocity.x = attacker.direction * 500
				defender.velocity.y = -300
				defender.take_damage(20, 0, "throw")
				create_hit_effect(defender.position, attacker.neon_color)
				get_parent().camera.shake(0.5, 20)
			)
			tw.tween_interval(0.5)
			tw.tween_callback(func():
				attacker.state = "IDLE"
				attacker.set_pose("IDLE", 0.3)
			)

func hit_stop(duration: float):
	Engine.time_scale = 0.1
	await get_tree().create_timer(duration * 0.1).timeout
	Engine.time_scale = 1.0

func create_hit_effect(pos: Vector2, col: Color = Color.WHITE):
	var flash = ColorRect.new()
	flash.size = Vector2(50, 50)
	flash.position = pos - Vector2(25, 25)
	flash.color = col
	get_parent().add_child(flash)
	
	for i in range(4):
		var p = ColorRect.new()
		p.size = Vector2(10, 10)
		p.position = pos - Vector2(5, 5)
		p.color = col
		get_parent().add_child(p)
		var ptw = create_tween()
		var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(50, 150)
		ptw.tween_property(p, "position", p.position + random_dir, 0.2).set_ease(Tween.EASE_OUT)
		ptw.parallel().tween_property(p, "modulate:a", 0.0, 0.2)
		ptw.tween_callback(p.queue_free)
	
	var tw = create_tween()
	tw.tween_property(flash, "scale", Vector2(2.5, 2.5), 0.15)
	tw.parallel().tween_property(flash, "modulate:a", 0.0, 0.15)
	tw.tween_callback(flash.queue_free)
