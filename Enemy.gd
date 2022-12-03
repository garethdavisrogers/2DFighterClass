extends "res://Fighter.gd"

var attack_range = 100
var target_position = null
##Vector2 of player coordinates
var player_detected = false
##player_detected is based on enter/exit $Detector signals

func _physics_process(delta):
	##enemy can only function if not staggered
	if(stun_timer < 0):
		if(player_detected):
			state_machine('seek')
		if(movedir.x != 0 or movedir.y != 0):
			anim_switch('walk')
		match state:
			'seek':
				state_seek()
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
	
func state_seek():
	var t = get_player_position()
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
		if(body.type == 'player'):
			return body.position

func _on_Detector_body_entered(body):
	if(body.type == 'player'):
		player_detected = true
		state_machine('seek')


func _on_Detector_body_exited(_body):
	var bodies = $Detector.get_overlapping_bodies()
	for b in bodies:
		if(b.type == 'player'):
			return
	state_machine('idle')
