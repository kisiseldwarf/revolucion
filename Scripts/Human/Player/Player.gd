extends "res:///Scripts/Human/Human.gd"

signal select_pressed
signal select_released
signal dialog_began
signal dialog_finished
export var text_speed : float = 0
var in_dialog = 0 

func _ready():
	$Camera2D/HUD/DialogPanel.hide()
	$Camera2D/HUD/TextInterfaceEngine.show()

func _physics_process(delta):
	if !in_dialog && !in_cinematic:
		movement(delta)

func _input(event):
	if event.is_action_pressed("ui_select"):
		emit_signal("select_pressed")
		if !in_dialog:
			dialog()
	if event.is_action_released("ui_select"):
		emit_signal("select_released")
	if event.is_action_pressed("ui_action"):
		attack()

#dialog script
func dialog():
	emit_signal("dialog_began")
	var pnjs = get_active_interabox().get_overlapping_bodies()
	print(get_active_interabox().get_overlapping_bodies())
	if pnjs.size() > 1 && pnjs[1].is_in_group("PNJs") && !in_dialog:
		in_dialog = 1
		pnjs[1].dialog(self)
		look(last_direction)

		#Dialog
		$Camera2D/HUD/DialogPanel.show()
		for i in pnjs[1].text:
			if pnjs[1].has_a_voice():
				$Camera2D/HUD/TextInterfaceEngine.buff_text(i,text_speed,"",false,pnjs[1].get_voice())
			else:
				$Camera2D/HUD/TextInterfaceEngine.buff_text(i,text_speed)
			$Camera2D/HUD/TextInterfaceEngine.set_state(1)
			yield(self,"select_pressed")
			$Camera2D/HUD/TextInterfaceEngine.reset()
		$Camera2D/HUD/DialogPanel.hide()
		yield(self,"select_released")
		in_dialog = 0
	emit_signal("dialog ended")

func set_dialog(texts):
	in_dialog = 1
	$Camera2D/HUD/DialogPanel.show()
	for i in texts:
		$Camera2D/HUD/TextInterfaceEngine.buff_text(i,text_speed)
		$Camera2D/HUD/TextInterfaceEngine.set_state(1)
		yield(self,"select_pressed")
		$Camera2D/HUD/TextInterfaceEngine.reset()
	$Camera2D/HUD/DialogPanel.hide()
	yield(self,"select_released")
	in_dialog = 0

func movement(delta):
	var direction = Vector2(0,0)
	if Input.is_action_pressed("ui_left"):
		direction =+ Vector2(-1,0)
	if Input.is_action_pressed("ui_right"):
		direction += Vector2(1,0)
	if Input.is_action_pressed("ui_down"):
		direction += Vector2(0,1)
	if Input.is_action_pressed("ui_up"):
		direction += Vector2(0,-1)
	
	var movement = direction.normalized() * velocity
	move_and_slide(movement)
	animation(direction)
	return direction

func get_active_interabox():
	match get_direction():
		direction.UP:
			return $Interabox/Up
		direction.DOWN:
			return $Interabox/Down
		direction.RIGHT:
			return $Interabox/Right
		direction.LEFT:
			return $Interabox/Left