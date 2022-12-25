extends "res://Fighter.gd"

func _ready():
	timers['combo_timer'] = time_till_next_input
	lastdirection = 1
	
func _physics_process(delta):
	increment_timers(delta)
	if(timers['stun_timer'] < 0):
		match state:
			'attack':
				state_attack()
			'jump':
				state_jump(delta)
			'land':
				state_land(delta)
			'fly':
				state_fly()
			'idle':
				state_idle()
				
		controls_loop()
		movement_loop()
		spritedir_loop()
		
func controls_loop():
	var left = Input.is_action_pressed('ui_left')
	var right = Input.is_action_pressed('ui_right')
	var up = Input.is_action_pressed('ui_up')
	var down = Input.is_action_pressed('ui_down')
	
	movedir.x = -int(left) + int(right)
	movedir.y = -int(up) + int(down)
	if(movedir.x != 0):
		lastdirection = movedir.x
	
	if(timers['cool_down'] < 0):
		##actions that can be taken when not stunned
		if(Input.is_action_just_pressed('lite_attack')):
			anim_switch(str('lite_attack', current_attack_index))
			attack_input_pressed()
			
		elif(Input.is_action_just_pressed("heavy_attack")):
			if(current_attack_index > 3):
				anim_switch(str('heavy_attack', 3))
			else:
				anim_switch(str('heavy_attack', current_attack_index))
			attack_input_pressed()
			
		elif(Input.is_action_just_pressed("blast")):
			if(state == 'idle' or state == 'attack'):
				anim_switch('blast')
				blast()
				attack_input_pressed()
		elif(Input.is_action_pressed('defend')):
			anim_switch('block')
			
		elif(Input.is_action_just_released('defend')):
			state_machine('idle')
			
		elif(Input.is_action_just_pressed('jump')):
			if(state != 'jump'):
				anim_switch('jump')
				state_machine('jump')
			elif(state == 'flight'):
				state_machine('land')
			else:
				anim_switch('fly')
				state_machine('fly')
				
