extends Upgrade
class_name SwordUpgrade

@export var dop: int

func apply_upgrade(player: Player):
	player.shape.height += dop
	player.attack_rect.size.y += dop
	
	player.attack_shape.position.y -= dop / 2
	player.attack_rect.position.y = player.attack_shape.position.y + player.shape.height / 2 -  player.attack_rect.size.y + 6
	
	player.parry_rect.size.y += dop
	player.parry_rect.get_parent().position.x = player.parry_shape.position.x + player.shape.height / 2 - player.parry_rect.size.y / 2 + 3
	player.parry_rect.position = -player.parry_rect.size / 2
