extends Node
class_name NatureSpawner

const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")

@export var spawn_area_size: Vector3 = Vector3(513, 0, 513)

@onready var terrain = %HTerrain

var tree_1_scene: PackedScene = preload("res://scenes/nature/tree_1.tscn")
var tree_2_scene: PackedScene = preload("res://scenes/nature/tree_2.tscn")
var tree_3_scene: PackedScene = preload("res://scenes/nature/tree_3.tscn")
var tree_4_scene: PackedScene = preload("res://scenes/nature/tree_4.tscn")

var grass_1_scene: PackedScene = preload("res://scenes/nature/grass_1.tscn")
var grass_2_scene: PackedScene = preload("res://scenes/nature/grass_2.tscn")

var trees: Array[PackedScene] = [tree_1_scene, tree_2_scene, tree_3_scene, tree_4_scene]
var grasses: Array[PackedScene] = [grass_1_scene, grass_2_scene]


func spawn():
	# place random grass
	for i in 1000:
		var position = self._get_random_spawn_position()
		var index: int = randi_range(1, len(self.grasses)) - 1
		var _random_grass_scene: PackedScene = self.grasses[index]
		var grass = _random_grass_scene.instantiate()
		add_child(grass)
		grass.global_position = position
	
	# place random tress
	for i in 200:
		var position = self._get_random_spawn_position()
		var index: int = randi_range(1, len(self.trees)) - 1
		var _random_tree_scene: PackedScene = self.trees[index]
		var tree = _random_tree_scene.instantiate()
		add_child(tree)
		tree.global_position = position


func _get_random_spawn_position() -> Vector3:
	var random_x = randf_range(0, spawn_area_size.x)
	var random_z = randf_range(0, spawn_area_size.z)
	var terrain_data: HTerrainData = terrain.get_data()
	var height = terrain_data.get_height_at(random_x, random_z)

	return Vector3(random_x, height, random_z) 
