extends Enemy

func set_hp(hp: int):
	self.hp = hp
	if hp == 0:
		self.hp = default_hp
	hp_bar.update(self.hp, default_hp)

func apply_damage(damage: int):
	super(damage)
	%AnimatedSprite2D.play("default")
