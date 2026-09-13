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
		tw.tween_property(visual, "scale", Vector2(1.0 * direction, 1.0), 0.4)\n