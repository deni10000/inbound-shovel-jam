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
var fear = false


@onready var offset: float = curve.get_closest_offset(global_position)
@onready var next_point: Vector2 = curve.sample_baked(offset)

func set_dop_rotation():
	var vec = target.global_position - global_position
	var rotation
	if not fear:
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
	var areas = %Area2D.get_overlapping_bodies()
	var mult = 1
	for x in areas:
		if x is Enemy2:
			if x.importance < importance:
				mult = 0
			if x.fear:
				mult = 1
				break
	
	if dist <= peaceful_radius ** 2:
		fear = true
		global_dir = get_next_point_direction(offset, step)
	else:
		fear = false
	
	if timer.is_stopped() and not fear :	
		shoot()
		timer.start(attack_cooldown)
	
	var dist_to_point = next_point.distance_to(global_position)
	
	if  dist_to_point < delta * default_velocity:
		offset += global_dir * step
		set_dop_rotation()
		next_point = get_point(offset)
	
	if fear:
		mult = 1
	
	
	if dist_to_point >= next_point.distance_to(global_position):
		position += mult * delta * default_velocity * global_position.direction_to(next_point)

			

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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy2:
		if importance > body.importance:
			return
		if fear:
			body.global_dir = global_dir
		elif body.fear:
			global_dir = body.global_dir
		#if global_dir == body.global_dir:
			#if randi() % 2:
				#global_dir *= -1
			#else:
				#body.global_dir *= -1
		if global_dir != body.global_dir:
			global_dir *= -1
			body.global_dir *= - 1
		
