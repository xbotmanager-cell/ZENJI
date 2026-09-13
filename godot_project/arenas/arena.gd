extends Node2D

var arenas = [
	preload("res://assets/arenas/arena_01.png"),
	preload("res://assets/arenas/arena_03.jpg")
]

func _ready():
	var tex = null
	
	var valid = []
	for a in arenas:
		if a != null:
			valid.append(a)
			
	if valid.size() > 0:
		tex = valid[randi() % valid.size()]
		
	if tex:
		var bg_sprite = Sprite2D.new()
		bg_sprite.texture = tex
		bg_sprite.scale = Vector2(3000.0 / tex.get_width(), 1500.0 / tex.get_height())
		bg_sprite.position = Vector2(1000, 300)
		bg_sprite.modulate = Color(0.3, 0.3, 0.4) # Darken for contrast
		add_child(bg_sprite)
	else:
		var bg = ColorRect.new()
		bg.size = Vector2(3000, 1500)
		bg.position = Vector2(-500, -500)
		bg.color = Color(0.1, 0.05, 0.1)
		add_child(bg)
		
	# Shadow Gradient Overlay (Procedural)
	var overlay = ColorRect.new()
	overlay.size = Vector2(3000, 1500)
	overlay.position = Vector2(-500, -500)
	overlay.color = Color(0, 0, 0, 0.4)
	add_child(overlay)
	
	# Floor
	var floor_rect = ColorRect.new()
	floor_rect.size = Vector2(3000, 400)
	floor_rect.position = Vector2(-500, 600)
	floor_rect.color = Color(0.02, 0.02, 0.02, 0.9)
	add_child(floor_rect)
	
	# Floor line
	var line = ColorRect.new()
	line.size = Vector2(3000, 4)
	line.position = Vector2(-500, 600)
	line.color = Color(0, 1, 1, 0.2)
	add_child(line)
	
	# Physics Boundaries
	var static_body = StaticBody2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(3000, 400)
	col.shape = shape
	col.position = Vector2(1000, 800)
	static_body.add_child(col)
	
	var wall_l = CollisionShape2D.new()
	var s_l = RectangleShape2D.new()
	s_l.size = Vector2(100, 1000)
	wall_l.shape = s_l
	wall_l.position = Vector2(-50, 300)
	static_body.add_child(wall_l)
	
	var wall_r = CollisionShape2D.new()
	var s_r = RectangleShape2D.new()
	s_r.size = Vector2(100, 1000)
	wall_r.shape = s_r
	wall_r.position = Vector2(1330, 300)
	static_body.add_child(wall_r)
	
	add_child(static_body)
	
	# Particle Dust Effect
	for i in range(15):
		var dust = ColorRect.new()
		dust.size = Vector2(4, 4)
		dust.position = Vector2(randf_range(0, 1280), randf_range(400, 600))
		dust.color = Color(1, 1, 1, 0.3)
		add_child(dust)
		animate_dust(dust)
		
func animate_dust(node):
	var tw = create_tween().set_loops()
	var dur = randf_range(4.0, 8.0)
	tw.tween_property(node, "position:y", node.position.y - randf_range(50, 150), dur)
	tw.parallel().tween_property(node, "position:x", node.position.x + randf_range(-50, 50), dur)
	tw.parallel().tween_property(node, "modulate:a", 0.0, dur)
