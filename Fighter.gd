extends KinematicBody2D

onready var sprite = $Sprite

export(float) var acceleration_coefficient = 5
export(int) var max_speed = 200
export(int) var health = 1
var BLAST = load('res://blast.tscn')
var movedir = Vector2(0, 0)
var lastdirection = 1
var state = 'idle'
export(int) var speed = 1
export(String) var type = 'enemy'
var cool_down = -1
var defense = 0
var gravity = Vector2(0, 0)
var jump_timer = 0
var jump_time = 0.5

var stun_timer = -1
## limits stagger
var inflicting_damage = 0
## is the damage coming from the player's attack

var combo_timer = 0
var time_till_next_input = 0.5

var input_cooldowns = {'lite': 0.2, 'heavy': 0.25, 'finish': 1, 'blast': 0.8}
var input_damage = {'lite': 2, 'heavy': 3, 'finish': 5, 'blast': 2}
var is_in_combo = false
var current_attack_index = 1

func state_machine(s):
	if(state != s):
		state = s

func anim_switch(new_anim):
	if($anim.current_animation != new_anim):
		$anim.play(new_anim)
func movement_loop():
	var motion = movedir.normalized() * speed
# warning-ignore:return_value_discarded
	move_and_slide(motion, gravity)

func spritedir_loop():
	if(movedir.x > 0):
		sprite.scale.x = sprite.scale.y * 1
	elif(movedir.x < 0):
		sprite.scale.x = sprite.scale.y * -1
	else:
		return

func state_attack(d):
	if(is_in_combo):
		combo_timer -= d
	
		if(combo_timer < 0):
			combo_timer = time_till_next_input
			is_in_combo = false
			current_attack_index = 1
			state_machine('idle')

func state_defend():
	speed = 80

func blast():
	var blast = BLAST.instance(1)
	var level = get_owner()
	level.add_child(blast)
	blast.type = self.type
	var spawn_pos = $Sprite/blast_spawn.get_global_position()
	blast.set_position(spawn_pos)
	if(lastdirection == 1):
		blast.blastdir = 1
	else:
		blast.blastdir = -1
		
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
	
func state_idle():
	inflicting_damage = input_damage['lite']
	combo_timer = 0
	movement_loop()
	if(movedir != Vector2(0,0)):
		speed = min((speed * acceleration_coefficient), max_speed)
		if(speed > 150):
			anim_switch('run')
		else:
			anim_switch('walk')
	else:
		speed = max((speed * 0.9) - 1, 1)
		anim_switch('idle')
		
func reset_combo_timer(a):
	if(current_attack_index < 5 or $anim.current_animation != 'heavy_attack3'):
		if(a == 'heavy'):
			inflicting_damage = input_damage['heavy']
		combo_timer = time_till_next_input
		cool_down = input_cooldowns[a]
	else:
		cool_down = input_cooldowns['finish']
		inflicting_damage = input_damage['finish']
		combo_timer = cool_down

func damage_loop(damage):
	health -= damage
	stun_timer = 5
	
func state_stagger():
	if(stun_timer > 0):
		anim_switch('stagger')
	else:
		state_machine('idle')
