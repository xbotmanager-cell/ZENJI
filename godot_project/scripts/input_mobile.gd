extends CanvasLayer

var round_manager

var joystick
var btn_punch
var btn_kick
var btn_block
var btn_special
var btn_jump

var kb_state = { "punch": false, "kick": false, "special": false, "up": false, "joy_up": false }

func _ready():
	joystick = VirtualJoystick.new(Vector2(250, 500), 130.0)
	add_child(joystick)
	
	btn_block = VirtualActionButton.new(Vector2(900, 600), 55.0, "block", Color(0.5, 0.5, 1.0))
	add_child(btn_block)
	
	btn_punch = VirtualActionButton.new(Vector2(1040, 530), 55.0, "punch", Color(1, 0.4, 0.4))
	add_child(btn_punch)
	
	btn_kick = VirtualActionButton.new(Vector2(1180, 460), 55.0, "kick", Color(0.4, 0.8, 1.0))
	add_child(btn_kick)
	
	btn_special = VirtualActionButton.new(Vector2(1180, 600), 55.0, "special", Color(1.0, 0.8, 0.2))
	add_child(btn_special)
	
	btn_jump = VirtualActionButton.new(Vector2(900, 460), 55.0, "jump", Color(0.6, 1.0, 0.6))
	add_child(btn_jump)

func _process(_delta):
	if not round_manager or not round_manager.player: return
	var p = round_manager.player
	var combat = round_manager.combat
	
	var joy_vec = joystick.get_value()
	
	p.wants_left = Input.is_physical_key_pressed(KEY_A) or joy_vec.x < -0.3
	p.wants_right = Input.is_physical_key_pressed(KEY_D) or joy_vec.x > 0.3
	p.wants_down = Input.is_physical_key_pressed(KEY_S) or joy_vec.y > 0.5
	p.wants_block = Input.is_physical_key_pressed(KEY_SPACE) or btn_block.pressed
	
	var pc_up = Input.is_physical_key_pressed(KEY_W)
	var joy_up = joy_vec.y < -0.5
	
	if (pc_up and not kb_state.get("up", false)) or (joy_up and not kb_state.get("joy_up", false)) or btn_jump.just_pressed:
		p.wants_up = true
	
	kb_state["up"] = pc_up
	kb_state["joy_up"] = joy_up
	
	var pc_punch = Input.is_physical_key_pressed(KEY_CTRL)
	var pc_kick = Input.is_physical_key_pressed(KEY_SHIFT)
	var pc_special = Input.is_physical_key_pressed(KEY_ALT)
	
	var do_punch = (pc_punch and not kb_state["punch"]) or btn_punch.just_pressed
	var do_kick = (pc_kick and not kb_state["kick"]) or btn_kick.just_pressed
	var do_special = (pc_special and not kb_state["special"]) or btn_special.just_pressed
	
	kb_state["punch"] = pc_punch
	kb_state["kick"] = pc_kick
	kb_state["special"] = pc_special
	
	btn_punch.just_pressed = false
	btn_kick.just_pressed = false
	btn_special.just_pressed = false
	btn_jump.just_pressed = false
	btn_block.just_pressed = false
	
	if do_punch:
		if p.wants_block: combat.execute_attack(p, "GRAB")
		else: combat.execute_attack(p, "PUNCH")
	if do_kick:
		combat.execute_attack(p, "KICK")
	if do_special:
		combat.execute_attack(p, "SPECIAL")

class VirtualJoystick extends Control:
	var radius: float
	var current_offset: Vector2
	var is_dragging = false
	var touch_index = -1
	
	func _init(pos: Vector2, r: float):
		radius = r
		position = pos - Vector2(r * 1.5, r * 1.5)
		size = Vector2(r * 3.0, r * 3.0)
		current_offset = Vector2.ZERO
		mouse_filter = Control.MOUSE_FILTER_PASS
		
	func _gui_input(event):
		if event is InputEventScreenTouch:
			if event.pressed and not is_dragging:
				var center = size / 2.0
				if event.position.distance_to(center) <= radius * 1.5:
					is_dragging = true
					touch_index = event.index
					current_offset = event.position - center
					if current_offset.length() > radius:
						current_offset = current_offset.normalized() * radius
					queue_redraw()
			elif not event.pressed and event.index == touch_index:
				is_dragging = false
				touch_index = -1
				current_offset = Vector2.ZERO
				queue_redraw()
		elif event is InputEventScreenDrag:
			if is_dragging and event.index == touch_index:
				var center = size / 2.0
				current_offset = event.position - center
				if current_offset.length() > radius:
					current_offset = current_offset.normalized() * radius
				queue_redraw()
				
	func get_value() -> Vector2:
		if not is_dragging: return Vector2.ZERO
		return current_offset / radius
		
	func _draw():
		var center = size / 2.0
		draw_circle(center, radius, Color(0, 0, 0, 0.4))
		draw_arc(center, radius, 0, TAU, 32, Color(1, 1, 1, 0.2), 3.0, true)
		draw_circle(center + current_offset, radius * 0.35, Color(1, 1, 1, 0.6))

class VirtualActionButton extends Control:
	var action: String
	var radius: float
	var base_color: Color
	var pressed = false
	var just_pressed = false
	var touch_index = -1
	
	func _init(pos: Vector2, r: float, act: String, col: Color):
		position = pos - Vector2(r * 1.2, r * 1.2)
		size = Vector2(r * 2.4, r * 2.4)
		radius = r
		action = act
		base_color = col
		mouse_filter = Control.MOUSE_FILTER_PASS
		
	func _gui_input(event):
		if event is InputEventScreenTouch:
			if event.pressed and not pressed:
				var center = size / 2.0
				if event.position.distance_to(center) <= radius * 1.2:
					pressed = true
					just_pressed = true
					touch_index = event.index
					queue_redraw()
			elif not event.pressed and event.index == touch_index:
				pressed = false
				touch_index = -1
				queue_redraw()
				
	func _draw():
		var center = size / 2.0
		var col = base_color if not pressed else base_color.lightened(0.5)
		draw_circle(center, radius, Color(0, 0, 0, 0.4))
		draw_arc(center, radius, 0, TAU, 32, col, 4.0, true)
		
		var r = radius * 0.45
		if action == "punch":
			draw_circle(center - Vector2(r*0.2, r*0.3), r*0.4, col)
			draw_circle(center + Vector2(r*0.2, -r*0.3), r*0.4, col)
			draw_circle(center - Vector2(r*0.6, -r*0.1), r*0.4, col)
			draw_rect(Rect2(center - Vector2(r*0.6, r*0.1), Vector2(r*1.2, r*0.8)), col)
		elif action == "kick":
			draw_rect(Rect2(center - Vector2(r*0.2, r*0.8), Vector2(r*0.4, r*1.2)), col)
			draw_rect(Rect2(center - Vector2(r*0.2, r*0.4), Vector2(r*0.8, r*0.4)), col)
		elif action == "block":
			var pts = PackedVector2Array([
				center + Vector2(-r, -r),
				center + Vector2(r, -r),
				center + Vector2(r, r*0.5),
				center + Vector2(0, r*1.2),
				center + Vector2(-r, r*0.5)
			])
			draw_polygon(pts, PackedColorArray([col]))
		elif action == "jump":
			var pts = PackedVector2Array([
				center + Vector2(0, -r),
				center + Vector2(r*0.6, r*0.2),
				center + Vector2(r*0.3, r*0.2),
				center + Vector2(r*0.3, r*0.8),
				center + Vector2(-r*0.3, r*0.8),
				center + Vector2(-r*0.3, r*0.2),
				center + Vector2(-r*0.6, r*0.2)
			])
			draw_polygon(pts, PackedColorArray([col]))
		elif action == "special":
			var pts = PackedVector2Array([
				center + Vector2(0, -r),
				center + Vector2(r*0.3, -r*0.3),
				center + Vector2(r, 0),
				center + Vector2(r*0.3, r*0.3),
				center + Vector2(0, r),
				center + Vector2(-r*0.3, r*0.3),
				center + Vector2(-r, 0),
				center + Vector2(-r*0.3, -r*0.3)
			])
			draw_polygon(pts, PackedColorArray([col]))
