extends Node2D

func _ready():
	pass # Replace with function body.

func _on_Area2D_area_entered(area):
	if(area.is_in_group('players') and area.is_in_group('power_up_col')):
		queue_free()
