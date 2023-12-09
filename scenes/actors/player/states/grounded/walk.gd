class_name Walk
extends PlayerState
## Moving left and right on the ground.


func _cycle_tick():
	actor.vel.x = move_toward(actor.vel.x, movement.max_speed * movement.facing_direction, 1)

	movement.move_x("ground", true)

	movement.activate_coyote_timer()


func _tell_switch():
	if Input.is_action_just_pressed(&"jump"):
		return &"DummyJump"

	if (input.buffered_input(&"spin") and movement.can_spin()):
		return &"Spin"

	if Input.is_action_just_pressed(&"dive"):
		return &"AirborneDive"

	if input_direction != 0:
		if abs(actor.vel.x) >= movement.max_speed and input_direction != movement.facing_direction:
			return &"TurnSkid"
	else:
		if abs(actor.vel.x) >= movement.max_speed:
			return &"StopSkid"
		else:
			return &"Idle"

	if Input.is_action_pressed(&"down"):
		return &"Crouch"

	if InputManager.get_x() != 0 and actor.is_on_wall():
		if actor.push_ray.is_colliding():
			return &"Push"
		else:
			return &"DryPush"

	return &""