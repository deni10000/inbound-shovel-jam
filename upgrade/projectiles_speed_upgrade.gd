extends Upgrade
class_name ProjectilesSpeedUpgrade

@export var speed: int

func apply_upgrade(player: Player):
	player.additional_projectiles_speed += speed
