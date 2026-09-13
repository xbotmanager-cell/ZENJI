import fs from 'fs';
import path from 'path';

const root = path.join(process.cwd(), 'godot_project');

const dirs = [
    'scenes', 'scripts', 'fighters', 'combat', 'ui', 'arenas', 'effects', 'audio', 'data'
];

dirs.forEach(d => {
    fs.mkdirSync(path.join(root, d), { recursive: true });
});

const files = {};

files['project.godot'] = `
; Engine configuration file.

config_version=5

[application]
config/name="Shadow Fighter"
config/description="A modern 2D mobile shadow fighting game."
run/main_scene="res://main.tscn"
config/features=PackedStringArray("4.3", "Mobile")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/size/mode=4
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"
window/handheld/orientation=1

[rendering]
renderer/rendering_method="mobile"
textures/vram_compression/import_etc2_astc=true

[input_devices]
pointing/emulate_touch_from_mouse=true
`;

files['main.tscn'] = `
[gd_scene load_steps=2 format=3 uid="uid://cb3a2b3c4d5e"]

[ext_resource type="Script" path="res://scripts/game_manager.gd" id="1_abcd"]

[node name="GameManager" type="Node"]
script = ExtResource("1_abcd")
`;

files['scripts/game_manager.gd'] = `
extends Node
class_name GameManager

var current_scene: Node = null
var save_manager
var settings_manager

func _ready():
	save_manager = load("res://scripts/save_manager.gd").new()
	add_child(save_manager)
	settings_manager = load("res://scripts/settings_manager.gd").new()
	add_child(settings_manager)
	
	load_main_menu()

func load_main_menu():
	if current_scene:
		current_scene.queue_free()
	var menu = load("res://scripts/main_menu.gd").new()
	menu.game_manager = self
	add_child(menu)
	current_scene = menu

func load_fight(training: bool = false):
	if current_scene:
		current_scene.queue_free()
	var fight = Node2D.new()
	fight.name = "FightScene"
	
	var arena = load("res://arenas/arena.gd").new()
	fight.add_child(arena)
	
	var rm = load("res://scripts/round_manager.gd").new()
	rm.game_manager = self
	rm.is_training = training
	fight.add_child(rm)
	
	var ui = load("res://scripts/fight_ui.gd").new()
	ui.round_manager = rm
	fight.add_child(ui)
	
	var input = load("res://scripts/input_mobile.gd").new()
	input.round_manager = rm
	fight.add_child(input)
	
	var cam = load("res://scripts/camera_controller.gd").new()
	rm.camera = cam
	fight.add_child(cam)
	
	var pause = load("res://scripts/pause_menu.gd").new()
	pause.game_manager = self
	fight.add_child(pause)
	
	add_child(fight)
	current_scene = fight
`;

files['scripts/round_manager.gd'] = `
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
	player.neon_color = Color(0, 1, 1)
	get_parent().add_child(player)
	
	enemy = load("res://scripts/enemy.gd").new()
	enemy.position = Vector2(880, 600)
	enemy.direction = -1
	enemy.neon_color = Color(1, 0, 0)
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
		if player.hp <= 0 or enemy.hp <= 0:
			check_ko()
			
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
`;

files['scripts/fighter_base.gd'] = `
extends CharacterBody2D
class_name FighterBase

var max_hp = 100
var hp = 100
var energy = 0
var max_energy = 100
var direction = 1
var gravity = 2000
var speed = 350
var jump_force = -800

var state = "IDLE"
var attack_cooldown = 0.0
var stun_timer = 0.0

var visual: Node2D
var neon_color: Color = Color.WHITE

func _ready():
	visual = Node2D.new()
	add_child(visual)
	var body = ColorRect.new()
	body.size = Vector2(80, 180)
	body.position = Vector2(-40, -180)
	body.color = Color.BLACK
	visual.add_child(body)
	
	var neon = ColorRect.new()
	neon.size = Vector2(10, 180)
	neon.position = Vector2(-5, -180)
	neon.color = neon_color
	visual.add_child(neon)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if state == "HURT":
		stun_timer -= delta
		if stun_timer <= 0:
			state = "IDLE"
	
	if state == "ATTACK":
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			state = "IDLE"
			
	if state == "DEAD":
		velocity.x = 0
		rotation_degrees = lerp(rotation_degrees, -90.0 * direction, 5.0 * delta)
		
	move_and_slide()
	visual.scale.x = direction

func take_damage(amount, kb_force):
	if state == "BLOCK":
		hp -= amount * 0.2
		velocity.x = -direction * kb_force * 0.5
	else:
		hp -= amount
		state = "HURT"
		stun_timer = 0.4
		velocity.x = -direction * kb_force
		velocity.y = -200
	hp = max(0, hp)

func play_anim(anim_name):
	var tw = create_tween()
	if anim_name == "punch":
		visual.rotation_degrees = 15.0 * direction
		tw.tween_property(visual, "rotation_degrees", 0.0, 0.2)
	elif anim_name == "kick":
		visual.rotation_degrees = -15.0 * direction
		tw.tween_property(visual, "rotation_degrees", 0.0, 0.3)
	elif anim_name == "special":
		visual.scale = Vector2(1.2 * direction, 1.2)
		tw.tween_property(visual, "scale", Vector2(1.0 * direction, 1.0), 0.4)
`;

files['scripts/player.gd'] = `
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
			state = "IDLE"
`;

files['scripts/enemy.gd'] = `
extends "res://scripts/fighter_base.gd"
`;

files['scripts/enemy_ai.gd'] = `
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
`;

files['scripts/combat_system.gd'] = `
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
	tw.tween_callback(flash.queue_free)
`;

files['scripts/attack_system.gd'] = `
extends Node
class_name AttackSystem

var attacks = {
	"PUNCH": {"damage": 10, "range": 120, "kb": 300, "cooldown": 0.3, "energy": 5},
	"HEAVY": {"damage": 20, "range": 130, "kb": 600, "cooldown": 0.6, "energy": 10},
	"KICK": {"damage": 15, "range": 160, "kb": 450, "cooldown": 0.5, "energy": 10},
	"SPECIAL": {"damage": 30, "range": 200, "kb": 800, "cooldown": 1.0, "energy": -50}
}
`;

files['scripts/input_mobile.gd'] = `
extends CanvasLayer

var round_manager

func _ready():
	var controls = [
		{"name": "Left", "rect": Rect2(50, 500, 120, 120), "action": "left"},
		{"name": "Right", "rect": Rect2(200, 500, 120, 120), "action": "right"},
		{"name": "Block", "rect": Rect2(50, 350, 120, 120), "action": "block"},
		{"name": "Jump", "rect": Rect2(900, 500, 120, 120), "action": "jump"},
		{"name": "Punch", "rect": Rect2(1050, 500, 120, 120), "action": "punch"},
		{"name": "Kick", "rect": Rect2(1100, 350, 120, 120), "action": "kick"},
		{"name": "Special", "rect": Rect2(950, 200, 120, 120), "action": "special"}
	]
	
	for c in controls:
		var btn = TouchButton.new(c.rect, c.name, c.action, self)
		add_child(btn)

class TouchButton extends Control:
	var action: String
	var parent_ref
	var pressed = false
	
	func _init(rect: Rect2, text: String, act: String, parent):
		position = rect.position
		size = rect.size
		action = act
		parent_ref = parent
		
		var bg = ColorRect.new()
		bg.size = size
		bg.color = Color(1, 1, 1, 0.2)
		add_child(bg)
		
		var lbl = Label.new()
		lbl.text = text
		lbl.set_anchors_preset(PRESET_FULL_RECT)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(lbl)
		
	func _gui_input(event):
		if event is InputEventScreenTouch:
			pressed = event.pressed
			modulate.a = 0.5 if pressed else 1.0
			handle_action(pressed)

	func handle_action(is_pressed):
		if not parent_ref.round_manager or not parent_ref.round_manager.player: return
		var p = parent_ref.round_manager.player
		var combat = parent_ref.round_manager.combat
		
		match action:
			"left": p.input_dir = -1 if is_pressed else (0 if p.input_dir == -1 else p.input_dir)
			"right": p.input_dir = 1 if is_pressed else (0 if p.input_dir == 1 else p.input_dir)
			"jump": p.wants_jump = is_pressed
			"block": p.wants_block = is_pressed
			"punch": 
				if is_pressed: combat.execute_attack(p, "PUNCH")
			"kick":
				if is_pressed: combat.execute_attack(p, "KICK")
			"special":
				if is_pressed: combat.execute_attack(p, "SPECIAL")
`;

files['scripts/fight_ui.gd'] = `
extends CanvasLayer

var round_manager
var hp_p1: ProgressBar
var hp_p2: ProgressBar
var en_p1: ProgressBar
var timer_lbl: Label
var score_lbl: Label

func _ready():
	hp_p1 = create_bar(Rect2(50, 50, 400, 30), Color.GREEN)
	hp_p2 = create_bar(Rect2(830, 50, 400, 30), Color.RED)
	hp_p2.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	en_p1 = create_bar(Rect2(50, 90, 300, 15), Color.CYAN)
	
	timer_lbl = Label.new()
	timer_lbl.position = Vector2(590, 40)
	timer_lbl.add_theme_font_size_override("font_size", 48)
	add_child(timer_lbl)
	
	score_lbl = Label.new()
	score_lbl.position = Vector2(50, 120)
	score_lbl.add_theme_font_size_override("font_size", 24)
	add_child(score_lbl)

func create_bar(rect: Rect2, color: Color) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.position = rect.position
	bar.size = rect.size
	bar.show_percentage = false
	var sb = StyleBoxFlat.new()
	sb.bg_color = color
	bar.add_theme_stylebox_override("fill", sb)
	add_child(bar)
	return bar

func _process(_delta):
	if round_manager and round_manager.player and round_manager.enemy:
		hp_p1.value = (float(round_manager.player.hp) / round_manager.player.max_hp) * 100
		en_p1.value = (float(round_manager.player.energy) / round_manager.player.max_energy) * 100
		hp_p2.value = (float(round_manager.enemy.hp) / round_manager.enemy.max_hp) * 100
		timer_lbl.text = str(int(round_manager.timer))
		score_lbl.text = "Score: " + str(round_manager.score_manager.score) + "\\nCombo: " + str(round_manager.score_manager.combo)
`;

files['scripts/camera_controller.gd'] = `
extends Camera2D

var shake_time = 0.0
var shake_intensity = 0.0

func _ready():
	position = Vector2(640, 360)
	
func shake(duration: float, intensity: float):
	shake_time = duration
	shake_intensity = intensity

func _process(delta):
	if shake_time > 0:
		shake_time -= delta
		offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
	else:
		offset = Vector2.ZERO
`;

files['scripts/score_manager.gd'] = `
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
	score += damage * 10 + (combo * 5)
`;

files['scripts/fatality_system.gd'] = `
extends Node

func trigger_fatality(player, enemy, camera):
	player.state = "FATALITY"
	enemy.state = "FATALITY"
	Engine.time_scale = 0.2
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0,0,0,0.8)
	get_parent().add_child(bg)
	
	camera.shake(1.0, 30.0)
	
	await get_tree().create_timer(0.5).timeout
	Engine.time_scale = 1.0
	
	var tw = create_tween()
	tw.tween_property(player.visual, "position", Vector2(200, -200), 0.2)
	tw.tween_property(enemy.visual, "rotation_degrees", 720.0, 0.5)
	
	await get_tree().create_timer(1.0).timeout
	bg.queue_free()
	get_parent().game_manager.load_main_menu()
`;

files['scripts/main_menu.gd'] = `
extends Control

var game_manager

func _ready():
	var bg = ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.1)
	add_child(bg)
	
	var title = Label.new()
	title.text = "SHADOW FIGHTER"
	title.add_theme_font_size_override("font_size", 72)
	title.position = Vector2(300, 100)
	add_child(title)
	
	var btn_play = create_btn("PLAY", Vector2(500, 300))
	btn_play.pressed.connect(func(): game_manager.load_fight(false))
	
	var btn_train = create_btn("TRAINING", Vector2(500, 420))
	btn_train.pressed.connect(func(): game_manager.load_fight(true))
	
	var btn_set = create_btn("SETTINGS", Vector2(500, 540))
	
func create_btn(text: String, pos: Vector2) -> Button:
	var b = Button.new()
	b.text = text
	b.position = pos
	b.size = Vector2(280, 80)
	b.add_theme_font_size_override("font_size", 32)
	add_child(b)
	return b
`;

files['arenas/arena.gd'] = `
extends Node2D

func _ready():
	var bg = ColorRect.new()
	bg.size = Vector2(3000, 1000)
	bg.position = Vector2(-500, -200)
	bg.color = Color(0.1, 0.05, 0.1)
	add_child(bg)
	
	var floor_rect = ColorRect.new()
	floor_rect.size = Vector2(3000, 400)
	floor_rect.position = Vector2(-500, 600)
	floor_rect.color = Color(0.02, 0.02, 0.02)
	add_child(floor_rect)
	
	var static_body = StaticBody2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(3000, 400)
	col.shape = shape
	col.position = Vector2(1000, 800)
	static_body.add_child(col)
	add_child(static_body)
`;

files['scripts/pause_menu.gd'] = `
extends CanvasLayer

var game_manager
var menu_root

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu_root = Control.new()
	menu_root.hide()
	add_child(menu_root)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0,0,0,0.8)
	menu_root.add_child(bg)
	
	var btn_resume = Button.new()
	btn_resume.text = "RESUME"
	btn_resume.size = Vector2(200, 60)
	btn_resume.position = Vector2(540, 250)
	btn_resume.pressed.connect(toggle_pause)
	menu_root.add_child(btn_resume)
	
	var btn_quit = Button.new()
	btn_quit.text = "QUIT TO MENU"
	btn_quit.size = Vector2(200, 60)
	btn_quit.position = Vector2(540, 350)
	btn_quit.pressed.connect(func():
		get_tree().paused = false
		game_manager.load_main_menu()
	)
	menu_root.add_child(btn_quit)
	
	var btn_pause = Button.new()
	btn_pause.text = "II"
	btn_pause.size = Vector2(60, 60)
	btn_pause.position = Vector2(1200, 20)
	btn_pause.pressed.connect(toggle_pause)
	add_child(btn_pause)

func toggle_pause():
	get_tree().paused = not get_tree().paused
	menu_root.visible = get_tree().paused
`;

files['scripts/settings_manager.gd'] = `
extends Node

var music_volume = 1.0
var sfx_volume = 1.0
var vibration = true
`;

files['scripts/save_manager.gd'] = `
extends Node

var high_score = 0
`;

for (const [p, content] of Object.entries(files)) {
    fs.writeFileSync(path.join(root, p), content.trim() + '\\n', 'utf-8');
}

console.log("Godot scaffold generated.");
