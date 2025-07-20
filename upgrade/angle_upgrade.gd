extends Upgrade
class_name AngleUpgrade

@export var add_angle: float

func apply_upgrade(player: Player):
	player.attack_angle += add_angle
	
