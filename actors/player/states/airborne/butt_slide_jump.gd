class_name ButtSlideJump
extends Jump


func _physics_tick():
	movement.move_x(0.1, true)

	if movement.can_release_jump(applied_variation, min_jump_power):
		applied_variation = true
		actor.vel.y *= 0.5


func _trans_rules():
	if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
		if Input.is_action_pressed(&"down"):
			return [&"FaceplantDive", actor.vel.x]
		else:
			return [&"Dive", false]

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		return [&"Walljump", -movement.facing_direction]

	if movement.can_init_wallslide():
		return &"Wallslide"

	if actor.is_on_floor() and movement.is_slide_slope():
		return &"ButtSlide"

	return &""
