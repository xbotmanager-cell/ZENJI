extends CanvasLayer

var game_manager
var menu_root

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu_root = Control.new()
	menu_root.hide()
	add_child(menu_root)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0,0,0,0.8)
	menu_root.add_child(bg)
	
	var btn_resume = Button.new()
	btn_resume.text = "RESUME"
	btn_resume.size = Vector2(200, 60)
	btn_resume.position = Vector2(540, 250)
	btn_resume.pressed.connect(toggle_pause)
	menu_root.add_child(btn_resume)
	
	var btn_quit = Button.new()
	btn_quit.text = "QUIT TO MENU"
	btn_quit.size = Vector2(200, 60)
	btn_quit.position = Vector2(540, 350)
	btn_quit.pressed.connect(func():
		get_tree().paused = false
		game_manager.load_main_menu()
	)
	menu_root.add_child(btn_quit)
	
	var btn_pause = Button.new()
	btn_pause.text = "II"
	btn_pause.size = Vector2(60, 60)
	btn_pause.position = Vector2(1200, 20)
	btn_pause.pressed.connect(toggle_pause)
	add_child(btn_pause)

func toggle_pause():
	get_tree().paused = not get_tree().paused
	menu_root.visible = get_tree().paused\n