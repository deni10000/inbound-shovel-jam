extends Character
class_name Player

var invulnerability_time: float = 0.6
var attack_angle: float = deg_to_rad(50)
var attack_dration: float = 0.3
var damage: int = 1
var slow_factor: float = 0.70
var attacked_enemies: Array[Enemy]
var reflection_upgrade: bool = true

var dash_speed: float = 400
var dash_duration: float = 0.2
var dash_cooldown: float = 0.3
var can_dash: bool = true

enum State {WALK, ATTACK, PARRY, DASH}

var state = State.WALK


@onready var attack_area: Area2D = %AttackArea
@onready var parry_area: Parry = %ParryComponent
var shape = preload("uid://cruhec725kmhx")
@onready var attack_rect = %NinePatchRect
@onready var parry_rect = %NinePatchRect2
@onready var attack_shape = %CollisionShape2D
@onready var parry_shape = %CollisionShape2D2
@onready var collision_shape = $CollisionShape2D
@onready var attack_sound = %AttackSound
@onready var parry_sound = %ParrySound
@onready var additional_projectiles_speed: int = 0



func _ready() -> void:
	super()
	attack_area.body_entered.connect(handle_attack_collisions)
	var dop = SwordUpgrade.new()
	dop.dop = 25
	dop.apply_upgrade(self)
	#var dop = 50
	#shape.height += dop
	#$AttackArea/NinePatchRect.size.y += dop
	#
	#$AttackArea/CollisionShape2D.position.y -= dop / 2
	#$AttackArea/NinePatchRect.position.y = $AttackArea/CollisionShape2D.position.y + shape.height / 2 - $AttackArea/NinePatchRect.size.y + 6

func set_hp(hp):
	super.set_hp(hp)
	if hp <= 0:
		await die_animation()
		Main.instance.restart_level()

var direction_vector: Vector2 = Vector2.ZERO

var want_to_dash = false		
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func right(action = "run"):
	sprite.scale.x = 1
	sprite.play(action + "_right")
	
func right_up(action = "run"):
	sprite.scale.x = 1
	sprite.play(action + "_right_up")
	
func up(action = "run"):
	sprite.play(action + "_up")
	
func left_up(action = "run"):
	sprite.scale.x = -1
	sprite.play(action + "_right_up")
	
func left(action = "run"):
	sprite.scale.x = -1
	sprite.play(action + "_right")
	
func left_down(action = "run"):
	sprite.scale.x = -1
	sprite.play(action + "_right_down")
	
func down(action = "run"):
	sprite.play(action + "_down")
	
func right_down(action = "run"):
	sprite.scale.x = 1
	sprite.play(action + "_right_down")	

func play_direction_animation(direction: Vector2, action: String):
	last_dir = direction
	direction.y *= -1
	var angle = direction.angle()
	var angle_deg = rad_to_deg(angle)
	
	if angle_deg < 0:
		angle_deg += 360
	
	if angle_deg >= 337.5 or angle_deg < 22.5:
		right(action)
	elif angle_deg >= 22.5 and angle_deg < 67.5:
		right_up(action)
	elif angle_deg >= 67.5 and angle_deg < 112.5:
		up(action)
	elif angle_deg >= 112.5 and angle_deg < 157.5:
		left_up(action)
	elif angle_deg >= 157.5 and angle_deg < 202.5:
		left(action)
	elif angle_deg >= 202.5 and angle_deg < 247.5:
		left_down(action)
	elif angle_deg >= 247.5 and angle_deg < 292.5:
		down(action)
	elif angle_deg >= 292.5 and angle_deg < 337.5:
		right_down(action)

var last_dir = Vector2.UP
func _physics_process(delta: float) -> void:
	super(delta)
	parry_area.rotation = get_view_direction().angle() + PI/2
	
	direction_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_just_pressed("attack"):
		attack()
	if Input.is_action_just_pressed("dash"):
		want_to_dash = true
	if Input.is_action_just_released("dash"):
		want_to_dash = false
	
	if direction_vector != Vector2.ZERO and want_to_dash:
		dash()
		want_to_dash = false
	
	var action = "run"
	if direction_vector == Vector2.ZERO:
		action = "idle"
	if state == State.PARRY or state == State.ATTACK:
		var mouse_direction = get_view_direction()
		play_direction_animation(mouse_direction, action)
	else:
		if action == "idle":
			play_direction_animation(last_dir, action)
		else:
			play_direction_animation(direction_vector, action)

func apply_velocity(delta: float):
	self.velocity = default_velocity * direction_vector
	if state == State.PARRY:
		self.velocity *= slow_factor

func apply_damage(damage: int):
	if invulnerability:
		return
	set_hp(hp - damage)
	danage_sound.play()
	invulnerability = true
	await get_tree().create_timer(invulnerability_time).timeout
	invulnerability = false

func refresh_player(start_pos):
	global_position = start_pos
	rotation = 0
	modulate = Color.WHITE
	process_mode = Node.PROCESS_MODE_INHERIT
	parry_area.end_parry()
	reset_physics_interpolation()
	set_hp(default_hp)

func handle_attack_collisions(body):
	if state != State.ATTACK:
		return
	if body is Enemy:
		if body in attacked_enemies:
			return
		attacked_enemies.append(body)
		body.apply_damage(damage)
		body.push(body.global_position - global_position, body.push_speed, body.push_duration)
	

func attack():
	if state != State.WALK:
		return
	attack_sound.play()
	attack_area.visible = true
	attacked_enemies.clear()
	state = State.ATTACK
	var rotation = get_view_direction().angle() + PI / 2
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	attack_area.rotation = rotation + attack_angle
	attack_area.reset_physics_interpolation()
	tween.tween_property(attack_area, "rotation", rotation - attack_angle, attack_dration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	await get_tree().create_timer(0.1, false, true).timeout
	attack_area.visible = false
	state = State.WALK
	if parry_area.parry_promise:
		parry_area.start_parry()

func spawn_ghost():
	var ghost := sprite.duplicate()
	#ghost.texture = sprite.texturea
	#ghost.scale = sprite.scale
	#ghost.offset = sprite.offset
	#ghost.centered = sprite.centered
	#ghost.z_index = 0
	ghost.modulate = Color(1, 1, 1, 0.6)
	ghost.global_position = sprite.global_position
	Main.instance.add_child(ghost)
	
	ghost.modulate.a = 0.6
	ghost.create_tween().tween_property(ghost, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_LINEAR)
	await get_tree().create_timer(0.3, false, true).timeout
	ghost.queue_free()

var interval: float = 0.03
func spawn_ghosts(time: float):
	while time >= interval:
		time -= interval
		spawn_ghost()
		await get_tree().create_timer(interval, false, true).timeout

func dash():
	if not can_dash or state != State.WALK:
		return
	
	var dash_direction = direction_vector
	if dash_direction == Vector2.ZERO:
		return
	
	can_dash = false
	state = State.DASH
	lock_move = true
	set_collision_mask_value(4, false)
	set_collision_layer_value(1, false)
	
	invulnerability = true
	velocity = dash_direction * dash_speed
	
	spawn_ghosts(dash_duration)
	
	await get_tree().create_timer(dash_duration, false, true).timeout
	
	state = State.WALK
	velocity = Vector2.ZERO
	
	invulnerability = false
	lock_move = false
	
	set_collision_mask_value(4, true)
	set_collision_layer_value(1, true)
	
	if parry_area.parry_promise:
		parry_area.start_parry()

	
	
	await get_tree().create_timer(dash_cooldown, false, true).timeout
	can_dash = true
