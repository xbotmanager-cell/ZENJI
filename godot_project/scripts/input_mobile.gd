extends CanvasLayer

var round_manager

func _ready():
	var controls = [
		{"name": " ^ ", "rect": Rect2(120, 380, 100, 100), "action": "up"},
		{"name": " v ", "rect": Rect2(120, 600, 100, 100), "action": "down"},
		{"name": " < ", "rect": Rect2(20, 490, 100, 100), "action": "left"},
		{"name": " > ", "rect": Rect2(220, 490, 100, 100), "action": "right"},
		{"name": "BLK", "rect": Rect2(800, 600, 100, 100), "action": "block"},
		{"name": "PCH", "rect": Rect2(920, 490, 100, 100), "action": "punch"},
		{"name": "KCK", "rect": Rect2(1040, 600, 100, 100), "action": "kick"},
		{"name": "SPC", "rect": Rect2(1160, 490, 100, 100), "action": "special"}
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
			"left": p.wants_left = is_pressed
			"right": p.wants_right = is_pressed
			"up": p.wants_up = is_pressed
			"down": p.wants_down = is_pressed
			"block": p.wants_block = is_pressed
			"punch": 
				if is_pressed: 
					if p.wants_block: combat.execute_attack(p, "GRAB")
					else: combat.execute_attack(p, "PUNCH")
			"kick":
				if is_pressed: combat.execute_attack(p, "KICK")
			"special":
				if is_pressed: combat.execute_attack(p, "SPECIAL")
