extends "res://Fighter.gd"

var in_melee_attack_range = false
var target_position = null
var player_detected = false
onready var detector = $Detector
onready var in_range_collider = $Sprite/InRangeCollider
##player_detected is based on enter/exit $Detector signals

func _physics_process(delta):
	##enemy can only function if not staggered
	if(stun_timer > 0 or cool_down > 0):
		stun_timer -= delta
		cool_down -= delta
	if(in_melee_attack_range):
		state_machine('attack')
	elif(player_detected):
		state_machine('seek')
	else:
		movedir = Vector2(0, 0)
		state_machine('idle')
		
	match state:
		'attack':
			state_attack('lite')
		'stagger':
			state_stagger()
		'seek':
			state_seek()
		'idle':
			state_idle(delta)
		
func state_seek():
	var t = get_player_position()
	##if no player is in detect radius, change to idle state
	if(t != null):
		close_distance(t)
	else:
		player_detected = false
	
func get_player_position():
	var players = get_tree().get_nodes_in_group('players')
	var player_position = players[0].get_position()
	return player_position

func close_distance(player_pos):
	var s = sprite.get_position()
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
	if(body.is_in_group('players')):
		player_detected = true


func _on_Detector_body_exited(_body):
	var bodies = detector.get_overlapping_bodies()
	for b in bodies:
		if(b.is_in_group('players')):
			return
	player_detected = false


func _on_InRangeCollider_body_entered(body):
	if(body.is_in_group('players')):
		in_melee_attack_range = true


func _on_InRangeCollider_body_exited(body):
	var bodies = in_range_collider.get_overlapping_bodies()
	for b in bodies:
		if(b.is_in_group('players')):
			return
	in_melee_attack_range = false
	state_machine('seek')
