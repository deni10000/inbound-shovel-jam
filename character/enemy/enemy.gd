extends Character
class_name Enemy

var target: Node2D
@export var repelled: bool = true
@export var push_speed = 700
@export var push_duration = 0.2
@export var push_player_speed = 700
@export var push_player_duration = 0.2
@export var damage: int = 1

	
	
func set_hp(hp: int):
	super(hp)
	if hp <= 0:
		await die_animation()
		queue_free()
	
func apply_damage(damage: int):
	set_hp(hp - damage)

func shoot(type = 1):
	if not is_instance_valid(target):
		return
	var projectile: Projectile
	if type == 1:
		projectile = preload("uid://bjxnf8xnxjbfj").instantiate()
	projectile.damage = damage
	projectile.direction = target.global_position - global_position
	projectile.global_position = global_position
	projectiles.add_child(projectile)

func handle_collision():
	if not repelled:
		return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var object = collision.get_collider()
		if object is Player:
			if object.hp > damage:
				push(global_position - object.global_position, push_speed, push_duration)
				object.push(object.global_position - global_position, push_speed, push_duration)
			object.apply_damage(damage)
			return

	
