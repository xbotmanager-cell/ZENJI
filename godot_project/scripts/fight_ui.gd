extends CanvasLayer

var round_manager
var hp_p1: ProgressBar
var hp_p2: ProgressBar
var en_p1: ProgressBar
var timer_lbl: Label
var score_lbl: Label
var combo_lbl: Label

var last_combo = 0

func _ready():
	hp_p1 = create_bar(Rect2(50, 50, 400, 30), Color.GREEN)
	hp_p2 = create_bar(Rect2(830, 50, 400, 30), Color.RED)
	hp_p2.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	en_p1 = create_bar(Rect2(50, 90, 300, 15), Color.CYAN)
	
	timer_lbl = Label.new()
	timer_lbl.position = Vector2(590, 40)
	timer_lbl.add_theme_font_size_override("font_size", 48)
	add_child(timer_lbl)
	
	score_lbl = Label.new()
	score_lbl.position = Vector2(50, 120)
	score_lbl.add_theme_font_size_override("font_size", 24)
	add_child(score_lbl)
	
	combo_lbl = Label.new()
	combo_lbl.position = Vector2(50, 160)
	combo_lbl.add_theme_font_size_override("font_size", 36)
	combo_lbl.add_theme_color_override("font_color", Color(1, 0.8, 0))
	add_child(combo_lbl)

func create_bar(rect: Rect2, color: Color) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.position = rect.position
	bar.size = rect.size
	bar.show_percentage = false
	var sb = StyleBoxFlat.new()
	sb.bg_color = color
	bar.add_theme_stylebox_override("fill", sb)
	add_child(bar)
	return bar

func _process(_delta):
	if round_manager and round_manager.player and round_manager.enemy:
		hp_p1.value = (float(round_manager.player.hp) / round_manager.player.max_hp) * 100
		en_p1.value = (float(round_manager.player.energy) / round_manager.player.max_energy) * 100
		hp_p2.value = (float(round_manager.enemy.hp) / round_manager.enemy.max_hp) * 100
		timer_lbl.text = str(int(round_manager.timer))
		score_lbl.text = "Score: " + str(round_manager.score_manager.score)
		
		var cur_combo = round_manager.score_manager.combo
		if cur_combo >= 2:
			combo_lbl.text = str(cur_combo) + " HITS!"
			if cur_combo > last_combo:
				bump_combo()
		else:
			combo_lbl.text = ""
		last_combo = cur_combo

func bump_combo():
	var tw = create_tween()
	combo_lbl.scale = Vector2(1.5, 1.5)
	combo_lbl.modulate = Color(1, 1, 1, 1)
	tw.tween_property(combo_lbl, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
