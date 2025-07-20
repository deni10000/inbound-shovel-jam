extends Area2D
class_name Projectile

@onready var shape: CollisionShape2D = %CollisionShape2D
@onready var sprite: Sprite2D = %Sprite2D

@export var radius: float = 6
var is_enemy: bool = true:
	set(val):
		is_enemy = val
		sprite.material.set("shader_param/swap_channels", not val)
var damage: int = 1
var velocity: float = 200

var direction: Vector2:
	set(val):
		direction = val.normalized()

func _ready() -> void:
	shape.shape.radius = radius
	

func _physics_process(delta: float) -> void:
	position += delta * direction * velocity

func _on_body_entered(body: Node2D) -> void:
	if (is_enemy and body is Player) or (not is_enemy and body is Enemy):
		body.apply_damage(damage)
		queue_free()
	
	if body is TileMapLayer:
		queue_free()



func _on_area_entered(area: Area2D) -> void:
	if not is_enemy:
		return
	
	if area is Parry:
		var shape1: Shape2D = shape.shape
		var shape2: Shape2D = area.collision_shape.shape
		var trans1 = shape.get_global_transform()
		var trans2 = area.collision_shape.get_global_transform()
		
		var points = shape1.collide_and_get_contacts(trans1, shape2, trans2)
		if not points:
			return
		var normal = (points[1] - points[0]).normalized()
		is_enemy = not is_enemy
		velocity += area.player.additional_projectiles_speed
		if area.player.reflection_upgrade:	
			direction = area.player.get_view_direction()
		else:
			direction = direction - 2.0 * direction.dot(normal) * normal
		area.parry_sound.play()

		#var normal = ray.get_collision_normal()
		#if normal == Vector2.ZERO:
			#return
		#is_enemy = not is_enemy
		#global_position = ray.get_collision_point() 
		#direction = direction - 2.0 * direction.dot(normal) * normal
		
