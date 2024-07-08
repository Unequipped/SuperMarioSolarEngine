class_name Spin
extends PlayerState
## Spinning for the first time.

## How much the spin sends you upwards when airborne.
@export var spin_power: float = 6

## Whether the spin action was performed while airborne or not.
var is_airspin: bool
## Whether the initial spin action has finished or not.
var finished_init: bool

var nearby_entities: Array = []


func _on_enter(_handover):
	is_airspin = movement.can_air_action()

	actor.spin_hitbox.monitoring = true

	if is_airspin:
		movement.air_spun = true
		actor.vel.y = -spin_power

		if InputManager.get_x_dir() == -sign(actor.vel.x):
			actor.vel.x = 0

	movement.activate_freefall_timer()
	movement.consume_coyote_timer()


func _first_tick():
	# Gravity needs to be applied when a grounded spin is buffered.
	# (Pressing the spin actions while being a few units from the ground.)
	if not is_airspin:
		movement.apply_gravity()


func _subsequent_ticks():
	movement.apply_gravity()


func _physics_tick():
	is_airspin = movement.can_air_action()

	if is_airspin:
		movement.move_x("air", false)
	else:
		movement.move_x("ground", false)

	if not actor.doll.is_playing():
		finished_init = true


func _on_exit():
	actor.spin_hitbox.monitoring = false

	if not is_airspin:
		movement.activate_grounded_spin_timer()

	if actor.is_on_floor():
		movement.update_direction(sign(movement.get_input_x()))

	nearby_entities.clear()
	finished_init = false


func _trans_rules():
	if is_airspin:
		return _air_rules()

	return _ground_rules()


func _air_rules() -> Variant:
	if actor.is_on_floor():
		return &"Idle"

	if finished_init and movement.can_air_action():
		if input.buffered_input(&"spin"):
			return &"Twirl"

		if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
			if Input.is_action_pressed(&"down"):
				return [&"FaceplantDive", actor.vel.x]

			return [&"Dive", false]

	if movement.finished_freefall_timer():
		return &"Freefall"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		if not finished_init:
			return &"HomingGroundPound"

		return &"GroundPound"

	if finished_init and actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		return [&"Walljump", -movement.facing_direction]

	if finished_init and movement.can_init_wallslide():
		return &"Wallslide"

	return &""


func _ground_rules() -> Variant:
	if actor.is_on_floor():
		if not actor.doll.is_playing():
			return &"Idle"

		if input.buffered_input(&"jump"):
			return &"Spinjump"

	return &""


func _on_spin_hitbox_body_entered(body):
	if body not in nearby_entities:
		nearby_entities.append(body)

		body.health_module.damage(actor, HealthModule.DamageType.STRIKE, 1)
