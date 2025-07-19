extends Enemy
class_name Enemy2
var attack_cooldown: float = 2
@onready var timer: Timer = %AttackTimer

var curve: Curve2D = preload("uid://cu1fu47yxfvwy")
var step: float = 5
static var enemies_count: int
var importance: int
var peaceful_radius: int = 200

@onready var offset: float = curve.get_closest_offset(global_position)
@onready var next_point: Vector2 = curve.sample_baked(offset)

func _ready() -> void:
	super()
	enemies_count += 1
	importance = enemies_count

func fix_offset(offset):
	return fposmod(offset, curve.get_baked_length()) 
	


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
			#$Sprite2D.rotation = curve.sample_baked_with_rotation(offset).get_rotation()
			
			$Sprite2D.rotation = (target.global_position - global_position).angle() + PI / 2
			
			next_point = get_point(offset)
			
	for x in %Area2D.get_overlapping_bodies():
		if x is Enemy2:
			if x.importance < importance:
				reverse_velocity = -1
				break
	
	position += reverse_velocity * delta * default_velocity * global_position.direction_to(next_point)
	reverse_velocity = 1

var reverse_velocity = 1
			

func get_point(offset):
	return curve.sample_baked(fix_offset(offset))

func get_next_point_direction(offset, step):
	var p1 = get_point(offset - step)
	var p2 = get_point(offset + step)
	if p1.distance_squared_to(target.global_position) > p2.distance_squared_to(target.global_position):
		return -1
	else:
		return 1
	
