extends Enemy
class_name Enemy3

var attack_cooldown: float = 2

static  var curve: Curve2D = preload("uid://dnjkbgd3jaave")
static var curve_len: int = int(curve.get_baked_length())
var step: float = 16

@onready var offset: float = curve.get_closest_offset(global_position)
var next_point: Vector2 = Vector2.ZERO
static var points: Array[bool] = []
static var radius = 16.15

static func _static_init() -> void:
	for i in range(int(curve.get_baked_length() / radius)):
		points.append(true)

func fix_offset(offset):
	return fposmod(offset, curve.get_baked_length()) 

func get_point(offset):
	return curve.sample_baked(fix_offset(offset))

var zanyati_nomer




func _ready() -> void:
	var offset = curve.get_closest_offset(global_position)
	var near_point = int(offset / radius)
	var dir = [-1, 1]
	for i in range(len(points) / 2):
		for x in dir:
			var dop = (near_point + i * x) % len(points)
			if points[dop]:
				next_point = get_point(dop * radius)
				points[dop] = false
				zanyati_nomer = dop
				return
	
 
@onready var sprite: AnimatedSprite2D = %Texture

var prev = false
func apply_velocity(delta: float):
	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return
	if not Main.instance.in_polygon:
		if zanyati_nomer is int:
			points[zanyati_nomer] = true
			next_point = Vector2.ZERO
			zanyati_nomer = null
	var dir 
	if next_point == Vector2.ZERO:
		default_velocity = 100
		sprite.play("run_axe")
		dir = target.global_position - global_position
		
		if not get_collision_layer_value(4):
			collision_layer = 0
			collision_mask = 0
			set_collision_layer_value(4, true)
			set_collision_mask_value(1, true)
			set_collision_mask_value(4, true)
		
		sprite.scale.x = 1
		if dir.x < 0:
			sprite.scale.x = -1
		
	else:
		default_velocity = 300
		if global_position.x > 480:
			sprite.scale.x = -1
		
		if not get_collision_layer_value(5):
			collision_layer = 0
			collision_mask = 0
			set_collision_layer_value(5, true)
			set_collision_mask_value(1, true)
		
		dir = (next_point - global_position)
		if dir.length() < delta * default_velocity:
			dir = Vector2.ZERO
			if not prev:
				sprite.play("idle_shield")
				prev = true
		else:
			sprite.play("run_shield")
			prev = false
	velocity = dir.normalized() * default_velocity
	
	if velocity != Vector2.ZERO:
		%Texture.play('run')
	else:
		%Texture.play('idle')

	
func _on_tree_exiting() -> void:
	if zanyati_nomer is not int:
		return
	points[zanyati_nomer] = true
	var point = get_point(zanyati_nomer * radius)
	var mn = INF
	var mnen = null
	var enemies = get_tree().get_nodes_in_group("Enemy3")
	for x: Enemy3 in enemies:
		if x.next_point == Vector2.ZERO:
			var dst = x.global_position.distance_to(point)
			if  dst < mn:
				mn =  dst
				mnen = x
	if mnen == null:
		for x: Enemy3 in enemies:
			x.next_point = Vector2.ZERO
			x.zanyati_nomer = null
		for i in range(len(points)):
			points[i] = true
	else:
		mnen.next_point = point
		mnen.zanyati_nomer = zanyati_nomer
		points[zanyati_nomer] = false
