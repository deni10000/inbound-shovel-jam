extends Enemy

func apply_velocity(delta: float):
	if is_instance_valid(target):
		velocity = (target.position - position).normalized() * default_velocity
		%Texture.scale.x = 1
		if velocity.x < 0:
			%Texture.scale.x = -1
