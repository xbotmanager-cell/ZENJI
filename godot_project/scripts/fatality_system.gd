extends Node

func trigger_fatality(player, enemy, camera):
	player.state = "FATALITY"
	enemy.state = "FATALITY"
	
	Engine.time_scale = 0.2
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	get_parent().add_child(bg)
	
	camera.shake(1.0, 30.0)
	await get_tree().create_timer(0.5).timeout
	Engine.time_scale = 1.0
	
	if randf() > 0.5:
		# SLAM FINISHER
		player.set_pose("FATALITY_GRAB", 0.2)
		enemy.set_pose("HURT", 0.2)
		
		var tw = create_tween()
		tw.tween_property(enemy, "position:x", player.position.x + (60 * player.direction), 0.2)
		await tw.finished
		
		player.set_pose("FATALITY_LIFT", 0.3)
		enemy.set_pose("FATALITY_VICTIM", 0.3)
		var tw2 = create_tween()
		tw2.tween_property(enemy, "position:y", player.position.y - 120, 0.3)
		tw2.parallel().tween_property(enemy.visual, "rotation_degrees", -90 * player.direction, 0.3)
		await tw2.finished
		
		await get_tree().create_timer(0.2).timeout
		
		player.set_pose("FATALITY_SLAM", 0.1)
		enemy.set_pose("DEAD", 0.1)
		var tw3 = create_tween()
		tw3.tween_property(enemy, "position:y", player.position.y, 0.1)
		tw3.parallel().tween_property(enemy.visual, "rotation_degrees", 0, 0.1)
		await tw3.finished
		
		camera.shake(1.5, 40.0)
	else:
		# CHOKE / RESTRAINT FINISHER
		var behind_x = enemy.position.x - (70 * enemy.direction)
		var tw = create_tween()
		tw.tween_property(player, "position:x", behind_x, 0.2)
		await tw.finished
		
		player.direction = enemy.direction
		player.set_pose("FATALITY_GRAB", 0.2)
		enemy.set_pose("HURT", 0.2)
		
		await get_tree().create_timer(0.3).timeout
		camera.shake(0.5, 10.0)
		enemy.set_pose("FATALITY_VICTIM", 0.2)
		
		await get_tree().create_timer(0.8).timeout
		player.set_pose("CROUCH", 0.5)
		enemy.set_pose("CROUCH", 0.5)
		
		await get_tree().create_timer(0.8).timeout
		
		enemy.set_pose("DEAD", 0.3)
		var tw3 = create_tween()
		tw3.tween_property(enemy, "position:y", enemy.position.y + 50, 0.3)
		tw3.parallel().tween_property(enemy.visual, "rotation_degrees", 90 * enemy.direction, 0.3)
		await tw3.finished
		camera.shake(1.0, 20.0)
		
	var flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = player.neon_color
	get_parent().add_child(flash)
	
	var flash_tw = create_tween()
	flash_tw.tween_property(flash, "modulate:a", 0.0, 1.5)
	
	await get_tree().create_timer(2.0).timeout
	flash.queue_free()
	bg.queue_free()
	get_parent().game_manager.load_main_menu()
