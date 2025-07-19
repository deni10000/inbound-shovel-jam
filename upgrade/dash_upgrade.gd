extends Upgrade
class_name DashUpgrade

@export var add_velocity: int

func apply_upgrade(player: Player):
	player.dash_speed += add_velocity
