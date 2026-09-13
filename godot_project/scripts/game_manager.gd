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
