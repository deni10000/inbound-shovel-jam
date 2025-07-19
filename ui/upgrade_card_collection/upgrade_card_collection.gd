extends HBoxContainer
class_name UpgradeCardCollection

var upgrades

signal upgrade_choosen(upgrade: Upgrade)

func upgrade(upgrade: Upgrade):
	upgrade_choosen.emit(upgrade)

func update():
	for x in get_children():
		x.queue_free()
	
	for x in upgrades:
		var upgrade_card: UpgradeCard = preload("uid://c87vx57hldk1p").instantiate()
		upgrade_card.upgrade_choosen.connect(upgrade)
		add_child(upgrade_card)
		upgrade_card.upgrade = x
