extends Node3D

const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")

@export var enemy_scene: PackedScene = preload("res://scenes/rogue.tscn")
@export var magic_potion_scene: PackedScene = preload("res://scenes/magic_potion.tscn")
@export var health_potion_scene: PackedScene = preload("res://scenes/health_potion.tscn")
@export var chest_scene: PackedScene = preload("res://scenes/secret_chest.tscn")
@export var spawn_area_size: Vector3 = Vector3(513, 0, 513)
@export var spawn_interval: float = 1.0
@export var max_enemies: int = 25


@onready var terrain = $HTerrain
@onready var enemy_count: int = 0
@onready var potion_scenes: Array[PackedScene] = [magic_potion_scene, health_potion_scene]
@onready var music_player: AudioStreamPlayer = $MusicPlayer


func _ready() -> void:
	pass

func _on_player_tutorial_over():
	var enemy_timer = Timer.new()
	enemy_timer.wait_time = spawn_interval
	enemy_timer.autostart = true
	enemy_timer.one_shot = false
	enemy_timer.connect("timeout", _on_enemy_timer_timeout)
	add_child(enemy_timer)
	
	var potion_timer = Timer.new()
	potion_timer.wait_time = spawn_interval
	potion_timer.autostart = true
	potion_timer.one_shot = false
	potion_timer.connect("timeout", _on_potion_timer_timeout)
	add_child(potion_timer)
	
	var chest: StaticBody3D = chest_scene.instantiate()
	var random_position = _get_random_spawn_position()
	add_child(chest)
	chest.global_position = random_position + Vector3(0.0, -1.0, 0.0)
	
	self.music_player.play()


func _on_enemy_timer_timeout() -> void:
	if self.enemy_count < self.max_enemies:
		_spawn_enemy()


func _on_potion_timer_timeout() -> void:
	var index: int = randi_range(1, len(self.potion_scenes)) -1
	var _random_potion_scene: PackedScene = self.potion_scenes[index]
	_spawn_potion(_random_potion_scene)


func _spawn_enemy() -> void:
	var enemy: Node3D = enemy_scene.instantiate()
	var random_position = _get_random_spawn_position()
	add_child(enemy)
	self.enemy_count += 1
	enemy.global_position = random_position
	enemy.connect("died", _on_enemy_died)


func _spawn_potion(scene: PackedScene) -> void:
	var potion: RigidBody3D = scene.instantiate()
	var random_position = _get_random_spawn_position()
	random_position = random_position + Vector3(0, 0.2, 0)
	add_child(potion)
	potion.global_position = random_position


func _on_enemy_died() -> void:
	self.enemy_count -= 1


func _get_random_spawn_position() -> Vector3:
	var random_x = randf_range(0, spawn_area_size.x)
	var random_z = randf_range(0, spawn_area_size.z)
	var terrain_data: HTerrainData = terrain.get_data()
	var height = terrain_data.get_height_at(random_x, random_z)

	return Vector3(random_x, height + 1, random_z) 


func _on_nature_spawner_ready():
	var nature_spawner: Node = $NatureSpawner
	nature_spawner.spawn()
