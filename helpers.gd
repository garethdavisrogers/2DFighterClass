extends Node

##change speed functions
func accelerate(s, ms):
	if(s < ms):
		return lerp(s, ms, 0.1)
	return ms

func decelerate(s):
	if(s > 0):
		return lerp(s, 0, 0.2)
	return 0
