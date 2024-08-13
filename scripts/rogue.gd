extends CharacterBody3D
class_name Rogue

var display_name: String = "Rogue"

@onready var player: Node3D = self.get_parent().get_node("Player")
@onready var model: Node3D = $model
@onready var animation_player: AnimationPlayer = $model/AnimationPlayer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var aimed_at_particles: GPUParticles3D = $AimedAtParticles
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var MAX_HEALTH: float = 30.0
@export var WALK_SPEED: float = 3.0
@export var RUN_SPEED: float = 7.0

@export var draw_dagger = preload("res://audio/draw_dagger.wav")
@export var dagger_attack = preload("res://audio/dagger_attack.wav")

signal died

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var health: int

var speed: float
var melee_range: float = 3.0
var player_detected: bool = false
var patrol_direction: Vector3 = Vector3.ZERO
var damage: float = 10.0
var state: String

func _ready() -> void:
	self.health = self.MAX_HEALTH
	self.aimed_at_particles.hide()


func _process(delta: float) -> void:
	if self.health <= 0 or self.global_position.y < 0:
		self.died.emit()
		self.queue_free()


func take_damage(amount: float) -> void:
	self.health -= amount


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if self.player_detected:
		var distance_to_player: float = self.global_position.distance_to(player.global_position)
		if distance_to_player <= self.melee_range:
			if state != "attacking":
				state = "attacking"
				start_attack()
		else:
			if state != "attacking":
				state = "running"
				move_towards_player()
	else:
		state = "patrolling"
		self.patrol()
	
	move_and_slide()

func start_attack():
	self.velocity = Vector3.ZERO
	self.animation_player.play("1H_Melee_Attack_Stab")
	self.audio_player.stream = self.dagger_attack
	self.audio_player.play()
	self.animation_player.connect("animation_finished", _on_attack_animation_finished)

func _on_attack_animation_finished(animation_name: String):
	if animation_name == "1H_Melee_Attack_Stab":
		player.take_enemy_damage(self.damage)
		self.state = ""
		self.animation_player.disconnect("animation_finished", _on_attack_animation_finished)

func move_towards_player():
	self.animation_player.play("Running_A")
	self.speed = RUN_SPEED
	var direction = (self.player.global_position - self.global_position).normalized()
	self.velocity.x = direction.x * self.speed
	self.velocity.z = direction.z * self.speed
	
	var target_position = player.global_position
	self.look_at(target_position, Vector3.UP)
	

func patrol() -> void:
	if self.patrol_direction == Vector3.ZERO:
		self.animation_player.play("Idle")
		self.velocity.x = 0
		self.velocity.z = 0
	else:
		self.animation_player.play("Walking_A")
		self.speed = WALK_SPEED
		self.velocity.x = self.patrol_direction.x * self.speed
		self.velocity.z = self.patrol_direction.z * self.speed
		var target_position = self.patrol_direction + self.global_position
		self.look_at(target_position, Vector3.UP)


func _on_aggro_range_body_entered(body):
	if body == player:
		self.player_detected = true
		self.audio_player.stream = self.draw_dagger
		self.audio_player.play()


func _on_aggro_range_body_exited(body):
	if body == player:
		self.player_detected = false


func _on_patrol_timer_timeout():
	var angle: float = randf_range(0, TAU)
	self.patrol_direction = Vector3(cos(angle), 0, sin(angle)).normalized()


func on_aimed():
	self.aimed_at_particles.show()


func un_aimed():
	self.aimed_at_particles.hide()
