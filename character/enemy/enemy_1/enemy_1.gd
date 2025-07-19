extends Enemy

func apply_velocity(delta: float):
	if is_instance_valid(target):
		velocity = (target.position - position).normalized() * default_velocity
