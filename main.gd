extends Node2D
class_name Main
var time_between_enemies = 0.1

static var instance: Main

@onready var spawners = %Spawners
@onready var player = %Player
@onready var enemies = %Enemies:
	set(val):
		enemies = val
		enemies.child_exiting_tree.connect(on_enemy_exit)
@onready var projectiles = %Projectiles
var current_level = -1
var version = 0

#enemy count point timer
var levels = [
	[[2, 4, 0, 0]],

	[[1, 30, 0, 2],
	[1, 30, 1, 3],
	[1, 40, 3, 4],
	[1, 40, 2, 1]],
	
	[[1, 30, 0, 0],
	[1, 30, 1, 0],
	[1, 30, 2, 0],
	[1, 30, 3, 7],
	[2, 1, 0, 0],
	[2, 1, 1, 0],
	[2, 1, 2, 0],
	[2, 1, 3, 5],
	[1, 100, 0, 0]]
]

var hp_upgrade = preload("uid://jiykpj8ec5dr")
var speed_upgrade = preload("uid://bv0j08pcb7lkh")
var invulnerability_time_upgrade = preload("uid://bna0rmrri56hy")
var upgrades = [[hp_upgrade, speed_upgrade, invulnerability_time_upgrade]]
var wave_ended = true

func _init() -> void:
	instance = self
	

func launch_wave(wave: Array, is_last = false):
	var local_version = version
	var enemy_scene: PackedScene = load("res://character/enemy/enemy_%s/enemy_%s.tscn" % [wave[0], wave[0]])
	var pos = spawners.get_child(wave[2]).position
	for i in range(wave[1]):
		if version != local_version:
			return
		var enemy: Enemy = enemy_scene.instantiate()
		enemy.target = player
		enemy.position = pos
		enemy.projectiles = projectiles
		enemies.call_deferred("add_child", enemy)
		if i == wave[1] - 1 and is_last:
			wave_ended = true
		await get_tree().create_timer(time_between_enemies).timeout

@onready var upgrade_card_collection: UpgradeCardCollection = %UpgradeCardCollection

func load_resources(path: String) -> Array:
	var result = []
	var dir = DirAccess.open(path)
	if dir == null:
		return result

	for file_name in dir.get_files():
		var full_path = path.path_join(file_name)
		full_path = full_path.trim_suffix('.remap')
		var res = load(full_path)
		if res:
			result.append(res)

	return result



var all_upgrades = load_resources("res://resources//upgrade")
func choose_upgrade():
	#upgrade_card_collection.upgrades = upgrades[current_level]
	all_upgrades.shuffle()
	upgrade_card_collection.upgrades = all_upgrades.slice(0, 3)
	
	
	upgrade_card_collection.update()
	upgrade_card_collection.visible = true
	get_tree().paused = true
	var upgrade: Upgrade = await upgrade_card_collection.upgrade_choosen
	upgrade.level += 1
	upgrade.apply_upgrade(player)
	if upgrade.level == 3:
		all_upgrades.erase(upgrade)
	
	get_tree().paused = false
	upgrade_card_collection.visible = false

func on_level_finished():
	await  choose_upgrade()
	current_level += 1
	start_level(levels[current_level])

func clear_map():
	for enemy in enemies.get_children():
		enemy.queue_free()
	for projectile in projectiles.get_children():
		projectile.queue_free()

func on_enemy_exit(node: Node):	
	if enemies.get_child_count() == 1 and wave_ended:
		on_level_finished()

#enemy count point timer
func start_level(level: Array):
	player.refresh_player(start_pos)
	version += 1
	var local_version = version
	wave_ended = false
	
	clear_map()
	
	for i in range(len(level)):
		var wave = level[i]
		if version != local_version:
			return
		launch_wave(wave, i == len(level) - 1)
		await get_tree().create_timer(wave[3]).timeout

var start_pos = Vector2(480, 270)
func restart_level():
	if current_level >= 0:
		start_level(levels[current_level])
	else:
		player.refresh_player(start_pos)

func end_tutorial():
	%Tutorial.queue_free()
	current_level = 0
	restart_level()
	

func _ready() -> void:
	enemies.child_exiting_tree.connect(on_enemy_exit)
	player.refresh_player(start_pos)
	#while true:
		#await choose_upgrade()
