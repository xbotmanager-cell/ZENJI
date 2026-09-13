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
	add_child(static_body)\n