class_name Push
extends PlayerState
## Walking against a solid body while the ray_shape is colliding.


func _on_enter(_handover):
	movement.consume_consec_timer()


func _tell_switch():
	if not InputManager.is_moving_x():
		return &"Idle"
	elif InputManager.get_x_dir() == -movement.facing_direction or movement.check_space_ahead():
		return &"Walk"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if input.buffered_input(&"jump"):
		return &"DummyJump"

	if Input.is_action_pressed(&"down"):
		return &"Crouch"

	return &""
