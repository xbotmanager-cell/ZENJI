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
var stun_timer = 0.0
var walk_timer = 0.0
var dodge_timer = 0.0

var wants_up = false
var wants_down = false
var wants_left = false
var wants_right = false
var wants_block = false

var base_color = Color(0.05, 0.05, 0.05)
var neon_color: Color = Color.WHITE

var visual: Node2D
var skeleton_nodes: Dictionary = {}
var current_pose_tween: Tween

var attack_tween: Tween
var current_attack: String = ""
var attack_phase: String = ""

var Poses = {
	"IDLE": {
		"hip": 0, "torso": 5, "head": -5,
		"arm_l": 20, "forearm_l": -80,
		"arm_r": 30, "forearm_r": -90,
		"thigh_l": -15, "calf_l": 15, "foot_l": 0,
		"thigh_r": 15, "calf_r": 5, "foot_r": -20
	},
	"WALK_1": {
		"hip": 0, "torso": 10, "head": 0,
		"arm_l": 40, "forearm_l": -40,
		"arm_r": -40, "forearm_r": -60,
		"thigh_l": -45, "calf_l": 40, "foot_l": 5,
		"thigh_r": 30, "calf_r": 10, "foot_r": -10
	},
	"WALK_2": {
		"hip": 0, "torso": 10, "head": 0,
		"arm_l": -40, "forearm_l": -60,
		"arm_r": 40, "forearm_r": -40,
		"thigh_l": 30, "calf_l": 10, "foot_l": -10,
		"thigh_r": -45, "calf_r": 40, "foot_r": 5
	},
	"JUMP": {
		"hip": 0, "torso": -10, "head": 10,
		"arm_l": -120, "forearm_l": -30,
		"arm_r": -130, "forearm_r": -20,
		"thigh_l": -60, "calf_l": 60, "foot_l": 10,
		"thigh_r": -10, "calf_r": 10, "foot_r": 10
	},
	"FALL": {
		"hip": 0, "torso": 10, "head": -10,
		"arm_l": 10, "forearm_l": -50,
		"arm_r": 20, "forearm_r": -60,
		"thigh_l": -20, "calf_l": 20, "foot_l": 0,
		"thigh_r": 10, "calf_r": 0, "foot_r": 0
	},
	"BLOCK": {
		"hip": 0, "torso": 15, "head": 10,
		"arm_l": -40, "forearm_l": -120,
		"arm_r": -30, "forearm_r": -130,
		"thigh_l": -20, "calf_l": 20, "foot_l": 0,
		"thigh_r": 20, "calf_r": 10, "foot_r": -10
	},
	"CROUCH": {
		"hip": 0, "torso": 20, "head": -10,
		"arm_l": -20, "forearm_l": -100,
		"arm_r": -10, "forearm_r": -110,
		"thigh_l": -60, "calf_l": 60, "foot_l": 0,
		"thigh_r": 40, "calf_r": 20, "foot_r": -20
	},
	"DODGE_B": {
		"hip": -20, "torso": -20, "head": 10,
		"arm_l": -40, "forearm_l": -60,
		"arm_r": -30, "forearm_r": -70,
		"thigh_l": -10, "calf_l": 10, "foot_l": 0,
		"thigh_r": 30, "calf_r": 10, "foot_r": -10
	},
	"JAB": {
		"hip": 10, "torso": 10, "head": -10,
		"arm_l": -80, "forearm_l": -10,
		"arm_r": 10, "forearm_r": -100,
		"thigh_l": -20, "calf_l": 20, "foot_l": 0,
		"thigh_r": 20, "calf_r": 10, "foot_r": 0
	},
	"CROSS": {
		"hip": 30, "torso": 30, "head": -20,
		"arm_l": -30, "forearm_l": -90,
		"arm_r": -80, "forearm_r": 0,
		"thigh_l": -30, "calf_l": 25, "foot_l": 5,
		"thigh_r": 30, "calf_r": 5, "foot_r": -10
	},
	"UPPERCUT": {
		"hip": 20, "torso": 10, "head": -30,
		"arm_l": -30, "forearm_l": -90,
		"arm_r": -130, "forearm_r": -20,
		"thigh_l": -15, "calf_l": 15, "foot_l": 0,
		"thigh_r": 15, "calf_r": 5, "foot_r": 0
	},
	"LOW_KICK": {
		"hip": 10, "torso": 0, "head": 10,
		"arm_l": -40, "forearm_l": -80,
		"arm_r": -30, "forearm_r": -90,
		"thigh_l": -40, "calf_l": 10, "foot_l": 0,
		"thigh_r": 20, "calf_r": 10, "foot_r": -10
	},
	"HIGH_KICK": {
		"hip": -30, "torso": -30, "head": 10,
		"arm_l": 10, "forearm_l": -40,
		"arm_r": 40, "forearm_r": -40,
		"thigh_l": -110, "calf_l": 20, "foot_l": 20,
		"thigh_r": 20, "calf_r": 10, "foot_r": -10
	},
	"SPECIAL": {
		"hip": -10, "torso": -10, "head": -20,
		"arm_l": -160, "forearm_l": -10,
		"arm_r": -150, "forearm_r": -20,
		"thigh_l": -20, "calf_l": 20, "foot_l": 0,
		"thigh_r": 20, "calf_r": 20, "foot_r": 0
	},
	"GRAB_REACH": {
		"hip": 15, "torso": 20, "head": -10,
		"arm_l": -70, "forearm_l": -20,
		"arm_r": -60, "forearm_r": -30,
		"thigh_l": -30, "calf_l": 25, "foot_l": 0,
		"thigh_r": 30, "calf_r": 10, "foot_r": 0
	},
	"GRAB_HOLD": {
		"hip": -10, "torso": -10, "head": 0,
		"arm_l": -50, "forearm_l": -50,
		"arm_r": -40, "forearm_r": -60,
		"thigh_l": -20, "calf_l": 20, "foot_l": 0,
		"thigh_r": 20, "calf_r": 10, "foot_r": 0
	},
	"HURT": {
		"hip": -10, "torso": -30, "head": 30,
		"arm_l": 30, "forearm_l": -20,
		"arm_r": 40, "forearm_r": -20,
		"thigh_l": 10, "calf_l": 0, "foot_l": -10,
		"thigh_r": 20, "calf_r": 10, "foot_r": -20
	},
	"HIT_HIGH": {
		"hip": -15, "torso": -30, "head": 40,
		"arm_l": 20, "forearm_l": -20,
		"arm_r": 30, "forearm_r": -20,
		"thigh_l": 10, "calf_l": 0, "foot_l": 0,
		"thigh_r": 20, "calf_r": 10, "foot_r": -10
	},
	"HIT_LOW": {
		"hip": 20, "torso": 40, "head": 20,
		"arm_l": -40, "forearm_l": -20,
		"arm_r": -30, "forearm_r": -30,
		"thigh_l": 20, "calf_l": 30, "foot_l": -20,
		"thigh_r": -10, "calf_r": 10, "foot_r": 0
	},
	"HIT_UPPERCUT": {
		"hip": -20, "torso": -40, "head": 50,
		"arm_l": 60, "forearm_l": -10,
		"arm_r": 70, "forearm_r": -10,
		"thigh_l": 10, "calf_l": -10, "foot_l": 0,
		"thigh_r": 10, "calf_r": -10, "foot_r": 0
	},
	"DEAD": {
		"hip": -90, "torso": -10, "head": -10,
		"arm_l": -10, "forearm_l": -10,
		"arm_r": 10, "forearm_r": -10,
		"thigh_l": 10, "calf_l": 10, "foot_l": 0,
		"thigh_r": -10, "calf_r": 10, "foot_r": 0
	},
	"FATALITY_GRAB": {
		"hip": 10, "torso": 10, "head": -10,
		"arm_l": -80, "forearm_l": 0,
		"arm_r": -70, "forearm_r": -20,
		"thigh_l": -20, "calf_l": 20, "foot_l": 0,
		"thigh_r": 20, "calf_r": 10, "foot_r": 0
	},
	"FATALITY_LIFT": {
		"hip": -10, "torso": -20, "head": -20,
		"arm_l": -160, "forearm_l": -20,
		"arm_r": -150, "forearm_r": -20,
		"thigh_l": -10, "calf_l": 10, "foot_l": 0,
		"thigh_r": 10, "calf_r": 5, "foot_r": -10
	},
	"FATALITY_SLAM": {
		"hip": 45, "torso": 45, "head": 10,
		"arm_l": 20, "forearm_l": 0,
		"arm_r": 30, "forearm_r": 0,
		"thigh_l": -30, "calf_l": 30, "foot_l": 0,
		"thigh_r": 30, "calf_r": 10, "foot_r": -10
	},
	"FATALITY_VICTIM": {
		"hip": -90, "torso": 20, "head": 30,
		"arm_l": 150, "forearm_l": 20,
		"arm_r": 160, "forearm_r": 30,
		"thigh_l": -30, "calf_l": -20, "foot_l": 0,
		"thigh_r": -40, "calf_r": -10, "foot_r": 0
	}
}

func _ready():
	z_index = 10
	visual = Node2D.new()
	add_child(visual)
	visual.position.y = -90 # Center offset
	
	var col = CollisionShape2D.new()
	var shape = CapsuleShape2D.new()
	shape.radius = 25.0
	shape.height = 180.0
	col.shape = shape
	col.position = Vector2(0, -90)
	add_child(col)
	
	build_skeleton()
	set_pose("IDLE", 0.01)

func create_limb(parent: Node, node_name: String, w_top: float, w_bot: float, h: float, p_x: float, p_y: float, col: Color) -> Node2D:
	var joint = Node2D.new()
	joint.name = node_name
	
	var poly = Polygon2D.new()
	var dx = (w_top - w_bot) / 2.0
	poly.polygon = PackedVector2Array([
		Vector2(-p_x, -p_y),
		Vector2(w_top - p_x, -p_y),
		Vector2(w_top - dx - p_x, h - p_y),
		Vector2(dx - p_x, h - p_y)
	])
	poly.color = col
	joint.add_child(poly)
	parent.add_child(joint)
	skeleton_nodes[node_name] = joint
	return joint

func build_skeleton():
	# Root Hip
	var hip = create_limb(visual, "hip", 30, 26, 20, 15, 10, base_color)
	
	# Torso
	var torso = create_limb(hip, "torso", 40, 26, 50, 20, 50, base_color)
	torso.position = Vector2(0, -10)
	var chest_neon = Polygon2D.new()
	chest_neon.polygon = PackedVector2Array([Vector2(-10, -40), Vector2(10, -40), Vector2(5, -10), Vector2(-5, -10)])
	chest_neon.color = neon_color
	torso.add_child(chest_neon)
	
	# Head
	var head = create_limb(torso, "head", 24, 20, 30, 12, 30, base_color)
	head.position = Vector2(0, -50)
	var eye = ColorRect.new()
	eye.size = Vector2(6, 4)
	eye.position = Vector2(4, -20)
	eye.color = neon_color
	head.add_child(eye)
	
	# Right Arm (Back)
	var arm_r = create_limb(torso, "arm_r", 14, 10, 40, 7, 5, base_color.darkened(0.2))
	arm_r.position = Vector2(10, -45)
	var forearm_r = create_limb(arm_r, "forearm_r", 10, 8, 40, 5, 5, base_color.darkened(0.2))
	forearm_r.position = Vector2(0, 35)
	var hand_r = create_limb(forearm_r, "hand_r", 12, 12, 12, 6, 2, neon_color.darkened(0.3))
	hand_r.position = Vector2(0, 35)
	
	# Right Leg (Back)
	var thigh_r = create_limb(hip, "thigh_r", 20, 14, 50, 10, 5, base_color.darkened(0.2))
	thigh_r.position = Vector2(5, 5)
	var calf_r = create_limb(thigh_r, "calf_r", 14, 10, 50, 7, 5, base_color.darkened(0.2))
	calf_r.position = Vector2(0, 45)
	var foot_r = create_limb(calf_r, "foot_r", 10, 25, 12, 5, 2, base_color.darkened(0.2))
	foot_r.position = Vector2(0, 45)
	
	# Left Leg (Front)
	var thigh_l = create_limb(hip, "thigh_l", 20, 14, 50, 10, 5, base_color)
	thigh_l.position = Vector2(-5, 5)
	var calf_l = create_limb(thigh_l, "calf_l", 14, 10, 50, 7, 5, base_color)
	calf_l.position = Vector2(0, 45)
	var foot_l = create_limb(calf_l, "foot_l", 10, 25, 12, 5, 2, base_color)
	foot_l.position = Vector2(0, 45)
	
	# Left Arm (Front)
	var arm_l = create_limb(torso, "arm_l", 14, 10, 40, 7, 5, base_color)
	arm_l.position = Vector2(-10, -45)
	var forearm_l = create_limb(arm_l, "forearm_l", 10, 8, 40, 5, 5, base_color)
	forearm_l.position = Vector2(0, 35)
	var hand_l = create_limb(forearm_l, "hand_l", 12, 12, 12, 6, 2, neon_color)
	hand_l.position = Vector2(0, 35)

func set_pose(pose_name: String, time: float = 0.2):
	if not Poses.has(pose_name): return
	var p = Poses[pose_name]
	
	if current_pose_tween:
		current_pose_tween.kill()
	current_pose_tween = create_tween().set_parallel(true)
	
	for bone in p.keys():
		if skeleton_nodes.has(bone):
			current_pose_tween.tween_property(skeleton_nodes[bone], "rotation_degrees", p[bone], time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	var dir = int(wants_right) - int(wants_left)
	
	if state in ["IDLE", "WALK", "CROUCH", "BLOCK", "DODGE"]:
		if wants_block:
			if dir != 0 and state != "DODGE":
				state = "DODGE"
				dodge_timer = 0.35
				velocity.x = dir * speed * 1.5 # Dodge in direction
				set_pose("DODGE_B", 0.15)
			elif state != "DODGE":
				state = "BLOCK"
				velocity.x = move_toward(velocity.x, 0, 3000 * delta)
				if wants_down:
					set_pose("CROUCH", 0.1) # Block low
				else:
					set_pose("BLOCK", 0.1)
		elif wants_down:
			state = "CROUCH"
			velocity.x = move_toward(velocity.x, 0, 3000 * delta)
			if not current_pose_tween or not current_pose_tween.is_running():
				set_pose("CROUCH", 0.15)
		elif dir != 0:
			state = "WALK"
			velocity.x = move_toward(velocity.x, dir * speed, 2500 * delta)
		else:
			state = "IDLE"
			velocity.x = move_toward(velocity.x, 0, 3000 * delta)
			
		if wants_up and is_on_floor() and state != "DODGE":
			velocity.y = jump_force
			wants_up = false
			state = "IDLE"
			
	if state == "DODGE":
		velocity.x = move_toward(velocity.x, 0, 1500 * delta)
		dodge_timer -= delta
		if dodge_timer <= 0:
			state = "IDLE"
			
	if state == "HURT":
		stun_timer -= delta
		if stun_timer <= 0:
			state = "IDLE"
			set_pose("IDLE", 0.3)
			
	if state == "ATTACK":
		velocity.x = move_toward(velocity.x, 0, 1000 * delta)
		
	if state == "WALK":
		walk_timer += delta * 12.0
		if fmod(walk_timer, 2.0) < 1.0:
			if not current_pose_tween or not current_pose_tween.is_running():
				set_pose("WALK_1", 0.1)
		else:
			if not current_pose_tween or not current_pose_tween.is_running():
				set_pose("WALK_2", 0.1)
				
	if state == "DEAD":
		velocity.x = move_toward(velocity.x, 0, 1000 * delta)
		
	if state == "IDLE" and not is_on_floor():
		if velocity.y < 0:
			if not current_pose_tween or not current_pose_tween.is_running():
				set_pose("JUMP", 0.2)
		else:
			if not current_pose_tween or not current_pose_tween.is_running():
				set_pose("FALL", 0.2)
	elif state == "IDLE":
		if not current_pose_tween or not current_pose_tween.is_running():
			set_pose("IDLE", 0.3)
			
	move_and_slide()
	visual.scale.x = direction

func take_damage(amount, kb_force, hit_type = "high"):
	if attack_tween: attack_tween.kill()
	
	if state == "BLOCK" or (state == "CROUCH" and wants_block):
		hp -= amount * 0.1
		velocity.x = -direction * kb_force * 0.3
		set_pose("BLOCK", 0.1)
	elif state == "DODGE":
		pass # Missed
	else:
		hp -= amount
		state = "HURT"
		stun_timer = 0.4
		velocity.x = -direction * kb_force
		if hit_type == "uppercut":
			velocity.y = -500
			set_pose("HIT_UPPERCUT", 0.1)
		elif hit_type == "low":
			set_pose("HIT_LOW", 0.1)
		else:
			set_pose("HIT_HIGH", 0.1)
	hp = max(0, hp)
