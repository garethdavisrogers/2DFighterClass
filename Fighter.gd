extends KinematicBody2D

##load nodes
onready var sprite = $Sprite
onready var anim = $anim
onready var blast_spawn = $Sprite/blast_spawn
onready var hitcol = $Sprite/HitCol
onready var hitbox = $Sprite/HitBox

##respective fighter attributes
export(int) var max_speed = 200
export(int) var health = 10
export(int) var max_combo_index = 1
export(float) var acceleration_constant = 0.1

##universal fighter attributes
const time_till_next_input = 0.5
const jump_time = 0.5
var state = 'idle'
var speed = 0
var movedir = Vector2(0, 0)
var knockdir = null
var lastdirection = -1
var gravity = Vector2(0, 0)
var is_in_combo = false
var current_attack_index = 1
##timers
var timers = {
	'cool_down': -1, 
	'jump_timer': -1, 
	'stun_timer': -1, 
	'combo_timer': -1
	}
##cooldown handicap
var handicap = {
	'lite': 0,
	'heavy': 0,
	'combo_time': 0
}
##METHODS
func _ready():
	##helps detect hits
	var groups = get_groups()
	for group in groups:
		hitcol.add_to_group(group)
		hitbox.add_to_group(group)
	hitcol.add_to_group('attacks')
	hitbox.add_to_group('hitboxes')
	
##controls displacement
func movement_loop():
	var motion
	if(knockdir != null):
		motion = knockdir * 300
	elif(movedir == Vector2(0, 0) and (speed > 0)):
		motion = Vector2((lastdirection * speed), 0)
	else:
		motion = movedir.normalized() * speed
# warning-ignore:return_value_discarded
	move_and_slide(motion, gravity)

##matches the sprite fliph
func spritedir_loop():
	if(movedir.x > 0):
		sprite.scale.x = sprite.scale.y * 1
	elif(movedir.x < 0):
		sprite.scale.x = sprite.scale.y * -1

func state_idle():
	if(movedir != Vector2(0,0)):
		if(speed == 0):
			speed += 1
		else:
			speed = accelerate(speed)
			if(speed > 200):
				anim_switch('run')
			else:
				anim_switch('walk')
	else:
		speed = decelerate(speed)
		anim_switch('idle')
		
##the overall attack state, returns to idle on timeout
func state_attack():
	speed = decelerate(speed)
	
	if(timers['combo_timer'] < 0):
		current_attack_index = 1
		state_machine('idle')

func blast():
	var type = ''
	if(is_in_group('players')):
		type = '_player'
	else:
		type = '_enemy'
	var load_string = str('res://blast',type,'.tscn')
	var blast = load(load_string).instance()
	blast.blastdir = lastdirection
	var level = get_owner()
	level.add_child(blast)
	var spawn_pos = blast_spawn.get_global_position()
	blast.set_position(spawn_pos)
		
func state_jump(d):
	movement_loop()
	if(timers['jump_timer'] < jump_time):
		position.y -= 2
		timers['jump_timer'] += d
	else:
		state_machine('land')

func state_land(d):
	movement_loop()
	anim.play('land')
	if(timers['jump_timer'] > 0):
		position.y += 2
		timers['jump_timer'] -= d
	else:
		state_machine('idle')

func state_fly():
	movement_loop()

func state_stagger():
	if(timers['stun_timer'] < 0):
		state_machine('idle')
	
func damage_loop():
	health -= 1
	timers['stun_timer'] = 5

func attack_input_pressed():
	current_attack_index += 1
	current_attack_index = min(current_attack_index, max_combo_index)
	state_machine('attack')
	reset_combo_timer()

func reset_combo_timer():
	timers['combo_timer'] = 0.5 + handicap['combo_time']
	if(current_attack_index <= max_combo_index or anim.current_animation != 'heavy_attack3'):
		timers['cool_down'] = 0.3 + handicap['lite']
	else:
		timers['cool_down'] = 0.7 + handicap['heavy']
	
##HELPER FUNCTIONS

##main state changing function
func state_machine(s):
	if(state != s):
		state = s
		
##plays new animations or continues existing ones
func anim_switch(new_anim):
	if(anim.current_animation != new_anim):
		anim.play(new_anim)

##increment timers
func increment_timers(d):
	for timer in timers:
		if(timers[timer] > -1):
			timers[timer] -= d
	
##change speed functions
func accelerate(s):
	if(s < max_speed):
		return lerp(s, max_speed, acceleration_constant)
	return max_speed

func decelerate(s):
	if(s > 0):
		return lerp(s, 0, 0.1)
	return 0
	
func get_knockdir(c):
	var pos = self.global_position
	return c.global_position.direction_to(pos)

func _on_HitBox_area_entered(area):
	if(area.is_in_group('attacks')):
		var groups = get_groups()
		for group in groups:
			if(area.is_in_group(group) and group != 'physics_process'):
				return
		knockdir = get_knockdir(area)
		damage_loop()
		timers['stun_timer'] = 0.3
		anim_switch('stagger')
		state_machine('stagger')
