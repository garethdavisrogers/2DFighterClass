extends "res://Fighter.gd"

var in_melee_attack_range = false
var target_position = null
var player_detected = false
##player_detected is based on enter/exit $Detector signals

func _physics_process(delta):
	##enemy can only function if not staggered
	if(stun_timer > 0):
		stun_timer -= delta
	if(player_detected == false):
		state_machine('idle')
	else:
		state_machine('seek')
	match state:
		'attack':
			state_attack('lite')
		'stagger':
			state_stagger()
		'seek':
			state_seek()
		'idle':
			state_idle()
	if(cool_down > 0):
		cool_down -= delta
		
func state_seek():
	var t = get_player_position()
	##if no player is in detect radius, change to idle state
	if(t != null):
		in_melee_attack_range = get_is_in_melee_range(t)
		if(in_melee_attack_range):
			movedir = Vector2(0, 0)
			state_machine('attack')
		else:
			close_distance(t)
	else:
		in_melee_attack_range = false
		state_machine('idle')
	
func get_player_position():
	var bodies = $Detector.get_overlapping_bodies()
	for body in bodies:
		if(body.type == 'player'):
			return body.position

func get_is_in_melee_range(player_pos):
	var s = self.get_position()
	var x_distance = abs(s.x - player_pos.x)
	var y_distance = abs(s.y - player_pos.y)
	if(x_distance < 100 and y_distance < 0):
		return true
	else:
		return false

func close_distance(player_pos):
	var s = self.get_position()
	if(player_pos.x > s.x):
		movedir.x = 1
	else:
		movedir.x = -1
	if(player_pos.y > s.y):
		movedir.y = 1
	else:
		movedir.y = -1
	movement_loop()
	spritedir_loop()
	anim_switch('walk')
	
func _on_Detector_body_entered(body):
	if(body.type == 'player'):
		player_detected = true
		state_machine('seek')


func _on_Detector_body_exited(_body):
	var bodies = $Detector.get_overlapping_bodies()
	for b in bodies:
		if(b.type == 'player'):
			return
	player_detected = false
	movedir = Vector2(0, 0)
