extends Node2D

onready var blast_timer = 5
onready var sprite = $Detector/Sprite
var blastdir = 1
var exploding = false
var inflicting_damage = 2
var type = null

func _physics_process(delta):
	var bodies = $Detector.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('enemy')):
			exploding = true
	if(not exploding):
		if(blastdir > 0):
			sprite.scale.x = sprite.scale.y * 1
		elif(blastdir < 0):
			sprite.scale.x = sprite.scale.y * -1
		if(blast_timer > 0):
			$Detector.position.x += blastdir * 5
			anim_switch('fire')
		else:
			queue_free()
	else:
		anim_switch('explode')
	blast_timer -= delta

func anim_switch(new_anim):
	if($Detector/anim.current_animation != new_anim):
		$Detector/anim.play(new_anim)

func _on_anim_animation_finished(anim_name):
	if(anim_name == 'explode'):
		blast_timer = -1
		queue_free()
