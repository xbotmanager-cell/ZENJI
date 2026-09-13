extends CanvasLayer

var round_manager
var hp_p1: ProgressBar
var hp_p2: ProgressBar
var en_p1: ProgressBar
var timer_lbl: Label
var score_lbl: Label

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
		score_lbl.text = "Score: " + str(round_manager.score_manager.score) + "\nCombo: " + str(round_manager.score_manager.combo)
