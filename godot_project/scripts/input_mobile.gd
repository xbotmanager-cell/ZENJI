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
				if is_pressed: combat.execute_attack(p, "SPECIAL")\n