extends KinematicBody2D

onready var sprite = $Sprite

##the factor by which speed increases while moving
export(int) var max_speed = 200
export(int) var health = 1
export(int) var max_combo_index = 1
var BLAST = load('res://blast.tscn')
##get projectile instance
var movedir = Vector2(0, 0)
var lastdirection = -1
##determines the direction of the blast
var state = 'idle'
var speed = 0
var cool_down = -1
var defense = 0
var gravity = Vector2(0, 0)
var jump_timer = 0
var jump_time = 0.5

var stun_timer = -1
## limits stagger

var combo_timer = 0
var time_till_next_input = 0.5

var is_in_combo = false
var current_attack_index = 1

##main state changing function
func state_machine(s):
	if(state != s):
		state = s

##plays new animations or continues existing ones
func anim_switch(new_anim):
	if($anim.current_animation != new_anim):
		$anim.play(new_anim)
		
##controls displacement
func movement_loop():
	var motion
	if(movedir == Vector2(0, 0) and (speed > 0)):
		motion = Vector2((lastdirection * speed), 0)
	else:
		motion = movedir.normalized() * speed
# warning-ignore:return_value_discarded
	move_and_slide(motion, gravity)

##matches the sprite fliph
func spritedir_loop():
	if(movedir.x > 0):
		sprite.scale.x = sprite.scale.y * 1
		lastdirection = 1
	elif(movedir.x < 0):
		sprite.scale.x = sprite.scale.y * -1
		lastdirection = -1

func state_idle():
	combo_timer = 0
	if(movedir != Vector2(0,0)):
		if(speed == 0):
			speed += 1
		else:
			speed = helpers.accelerate(speed, max_speed)
			if(speed > 200):
				anim_switch('run')
			else:
				anim_switch('walk')
	else:
		speed = helpers.decelerate(speed)
		anim_switch('idle')
		
##the overall attack state, returns to idle on timeout
func state_attack(d):
	speed = helpers.decelerate(speed)
	if(is_in_combo):
		combo_timer -= d
	
		if(combo_timer < 0):
			is_in_combo = false
			combo_timer = time_till_next_input
			current_attack_index = 1
			state_machine('idle')

func blast():
	var blast = BLAST.instance(1)
	var level = get_owner()
	level.add_child(blast)
	blast.add_to_group('player')
	var spawn_pos = $Sprite/blast_spawn.get_global_position()
	blast.set_position(spawn_pos)
	blast.blastdir = lastdirection
		
func state_jump(d):
	movement_loop()
	if(jump_timer < jump_time):
		position.y -= 2
		jump_timer += d
	else:
		state_machine('land')

func state_land(d):
	movement_loop()
	$anim.play('land')
	if(jump_timer > 0):
		position.y += 2
		jump_timer -= d
	else:
		state_machine('idle')

func state_fly():
	movement_loop()

func damage_loop(damage):
	health -= damage
	stun_timer = 5

func attack_input_pressed():
	is_in_combo = true
	current_attack_index = min(current_attack_index + 1, max_combo_index)
	state_machine('attack')
	reset_combo_timer()

func reset_combo_timer():
	if(current_attack_index < max_combo_index or $anim.current_animation != 'heavy_attack3'):
		cool_down = 0.5
		combo_timer = time_till_next_input
	else:
		cool_down = 2
		combo_timer = 1
	
