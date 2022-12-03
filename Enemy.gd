extends "res://Fighter.gd"

var attack_range = 100
var target_position = null
var player_detected = false

func _physics_process(delta):
	if(stun_timer < 0):
		if(not player_detected):
			get_player_position()
		if(movedir.x != 0 or movedir.y != 0):
			anim_switch('walk')
		target_position = get_player_position()
		if(target_position != null):
			state_machine('seek')
		match state:
			'seek':
				state_seek(target_position)
			'idle':
				state_idle()
			'attack':
				state_attack('lite')
			'stagger':
				state_stagger()
		if(cool_down > -1):
			cool_down -= delta
	else:
		stun_timer -= delta
	
func state_seek(t):
	movement_loop()
	spritedir_loop()
	var s = self.get_position()
	var x_distance = abs(s.x - t.x)
	var y_distance = abs(s.y - t.y)
	if(x_distance < attack_range and y_distance < attack_range and cool_down < 0):
		var r = randi()%2 + 1
		anim_switch(str('lite_attack', r))
		cool_down = 2
		state_machine('attack')
	if(t.x < s.x and x_distance > attack_range):
		movedir.x = -1
	elif(t.x > s.x and x_distance > attack_range):
		movedir.x = 1
	else:
		movedir.x = 0
	if(t.y < s.y and y_distance > attack_range):
		movedir.y = -1
	elif(t.y > s.y and y_distance > attack_range):
		movedir.y = 1
	else:
		movedir.y = 0
	
func get_player_position():
	var bodies = $Detector.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('players')):
			return body.position
