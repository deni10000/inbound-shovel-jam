extends Upgrade
class_name DamageUpgrade

@export var add_damage: int

func apply_upgrade(player: Player):
	player.damage += add_damage
