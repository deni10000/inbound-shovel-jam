extends Enemy
class_name Enemy2
var attack_cooldown: float = 2
@onready var timer: Timer = %AttackTimer

static var curve: Curve2D = preload("uid://cu1fu47yxfvwy")
var step: float = 5
static var enemies_count: int
var importance: int
var peaceful_radius: int = 150
var global_dir = -1 if randi() % 2 else 1

@onready var offset: float = curve.get_closest_offset(global_position)
@onready var next_point: Vector2 = curve.sample_baked(offset)

func set_dop_rotation():
	var vec = target.global_position - global_position
	var rotation
	if vec.length() > peaceful_radius:
		rotation = vec.angle() + PI / 2
	else:
		rotation = (next_point - global_position).angle() + PI / 2
		
		
	sprite.rotation = rotation
	$CollisionShape2D.rotation = rotation + PI / 2
	%Area2D.rotation = rotation
	
func _ready() -> void:
	super()
	enemies_count += 1
	importance = enemies_count
	set_dop_rotation()


func fix_offset(offset):
	return fposmod(offset, curve.get_baked_length()) 
	
@onready var sprite = $AnimatedSprite2D
var prev = []
func apply_velocity(delta: float):
	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return
	var dist = target.global_position.distance_squared_to(global_position)
	if timer.is_stopped() and dist > peaceful_radius ** 2 :	
		shoot()
		timer.start(attack_cooldown)
	
	if next_point.distance_to(global_position) < delta * default_velocity:
		var dir = get_next_point_direction(offset, step) 
		if  get_next_point_direction(offset + dir * step, step) == dir:
			offset += dir * step
			#sprite.rotation = curve.sample_baked_with_rotation(offset).get_rotation()
			set_dop_rotation()
			#var transform: Transform2D = hp_bar.get_global_transform()
			#rotation = (target.global_position - global_position).angle() - PI / 2
			#var transform2 = hp_bar.get_global_transform()
			#hp_bar.position  -= transform2.origin - transform.origin
			#hp_bar.rotation -= transform2.get_rotation() - transform.get_rotation()
			

			
			next_point = get_point(offset)
	
	var areas = %Area2D.get_overlapping_bodies()
	for x in areas:
		if x is Enemy2:
			if x.importance < importance:
				#if x not in prev:
					#if x.global_dir == global_dir:
						#global_dir *= -1
					#else:
						#x.global_dir *= -1
						#global_dir *=  1
					
				reverse_velocity = -1
				break
	prev = areas
	
	position += reverse_velocity * delta * default_velocity * global_position.direction_to(next_point)
	reverse_velocity = 1

var reverse_velocity = 1
			

func get_point(offset):
	return curve.sample_baked(fix_offset(offset))

func get_next_point_direction2(offset, step):
	return global_dir

func get_next_point_direction(offset, step):
	var p1 = get_point(offset - step)
	var p2 = get_point(offset + step)
	var ret = 1
	if p1.distance_squared_to(target.global_position) > p2.distance_squared_to(target.global_position):
		ret = -1
	#if get_point(offset).distance_to(target.global_position) > 300:
		#ret *= -1
	return ret
