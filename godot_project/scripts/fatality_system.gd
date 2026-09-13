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
	get_parent().game_manager.load_main_menu()\n