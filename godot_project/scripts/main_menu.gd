extends Control

var game_manager

func _ready():
	var bg = ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.1)
	add_child(bg)
	
	var title = Label.new()
	title.text = "SHADOW FIGHTER"
	title.add_theme_font_size_override("font_size", 72)
	title.position = Vector2(300, 100)
	add_child(title)
	
	var btn_play = create_btn("PLAY", Vector2(500, 300))
	btn_play.pressed.connect(func(): game_manager.load_fight(false))
	
	var btn_train = create_btn("TRAINING", Vector2(500, 420))
	btn_train.pressed.connect(func(): game_manager.load_fight(true))
	
	var btn_set = create_btn("SETTINGS", Vector2(500, 540))
	
func create_btn(text: String, pos: Vector2) -> Button:
	var b = Button.new()
	b.text = text
	b.position = pos
	b.size = Vector2(280, 80)
	b.add_theme_font_size_override("font_size", 32)
	add_child(b)
	return b
