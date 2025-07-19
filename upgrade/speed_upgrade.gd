extends Upgrade
class_name SpeedUpgrade

@export var speed: float

func apply_upgrade(player: Player):
	player.default_velocity += speed
