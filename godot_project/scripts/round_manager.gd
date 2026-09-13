extends Node
class_name RoundManager

var game_manager
var is_training = false
var player
var enemy
var combat
var ui
var camera
var score_manager
var fatality_system

var round_num = 1
var player_wins = 0
var enemy_wins = 0
var state = "INTRO"
var timer = 99.0

var enemy_profiles = [
	{"name": "VORTEX", "color": Color(0.2, 0.4, 1.0), "speed": 400, "hp": 90},
	{"name": "RAVEN", "color": Color(1.0, 0.2, 0.2), "speed": 300, "hp": 120},
	{"name": "NOVA", "color": Color(0.6, 0.1, 0.8), "speed": 350, "hp": 100},
	{"name": "BLAZE", "color": Color(1.0, 0.5, 0.1), "speed": 380, "hp": 95},
	{"name": "TOXIN", "color": Color(0.2, 0.8, 0.3), "speed": 340, "hp": 110}
]

func _ready():
	score_manager = load("res://scripts/score_manager.gd").new()
	add_child(score_manager)
	
	fatality_system = load("res://scripts/fatality_system.gd").new()
	add_child(fatality_system)
	
	combat = load("res://scripts/combat_system.gd").new()
	add_child(combat)
	
	spawn_fighters()
	start_round()

func spawn_fighters():
	player = load("res://scripts/player.gd").new()
	player.position = Vector2(400, 600)
	player.neon_color = Color(0, 1, 1) # Cyan - ZENJI
	player.speed = 350
	player.max_hp = 100
	get_parent().add_child(player)
	
	var chosen_enemy = enemy_profiles[randi() % enemy_profiles.size()]
	enemy = load("res://scripts/enemy.gd").new()
	enemy.position = Vector2(880, 600)
	enemy.direction = -1
	enemy.neon_color = chosen_enemy.color
	enemy.speed = chosen_enemy.speed
	enemy.max_hp = chosen_enemy.hp
	get_parent().add_child(enemy)
	
	combat.player = player
	combat.enemy = enemy
	combat.score_manager = score_manager
	
	if not is_training:
		var ai = load("res://scripts/enemy_ai.gd").new()
		ai.enemy = enemy
		ai.player = player
		ai.combat = combat
		add_child(ai)

func start_round():
	player.hp = player.max_hp
	enemy.hp = enemy.max_hp
	player.position = Vector2(400, 600)
	enemy.position = Vector2(880, 600)
	player.state = "IDLE"
	enemy.state = "IDLE"
	timer = 99.0
	state = "FIGHT"

func _process(delta):
	if state == "FIGHT":
		if not is_training:
			timer -= delta
			if timer <= 0:
				check_ko()
				return
		if player.hp <= 0 or enemy.hp <= 0:
			check_ko()
			
		if player.state not in ["DEAD", "FATALITY", "FATALITY_VICTIM", "GRABBED"]:
			player.direction = 1 if enemy.position.x > player.position.x else -1
		if enemy.state not in ["DEAD", "FATALITY", "FATALITY_VICTIM", "GRABBED"]:
			enemy.direction = 1 if player.position.x > enemy.position.x else -1
			
		var mid = (player.position.x + enemy.position.x) / 2.0
		camera.position.x = lerp(camera.position.x, mid, 5.0 * delta)
		camera.position.y = 360.0

func check_ko():
	state = "KO"
	camera.shake(0.5, 20)
	if player.hp <= 0:
		enemy_wins += 1
		player.state = "DEAD"
	elif enemy.hp <= 0:
		player_wins += 1
		enemy.state = "DEAD"
		if player_wins == 2 and player.energy >= 50:
			fatality_system.trigger_fatality(player, enemy, camera)
			return
	
	await get_tree().create_timer(3.0).timeout
	if player_wins >= 2 or enemy_wins >= 2:
		game_manager.load_main_menu()
	else:
		round_num += 1
		start_round()
