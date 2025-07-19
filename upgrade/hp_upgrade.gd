extends Upgrade
class_name HpUpgrade

@export var hp: int

func apply_upgrade(player: Player):
	player.default_hp += hp
