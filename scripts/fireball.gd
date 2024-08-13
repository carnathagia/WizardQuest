extends Area3D
class_name Fireball

@export var SPEED: float = 35.0
@export var LIFETIME: float = 3.0
@export var DAMAGE: int = 20

var direction: Vector3
var target: CharacterBody3D
var cast_sound = preload("res://audio/fireball_cast.wav")
var hit_sound = preload("res://audio/fireball_hit.wav")

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready():
	if self.target:
		self.target.connect("died", _clear_target)
	self.audio_player.stream = cast_sound
	self.audio_player.play()
	


func _clear_target() -> void:
	self.target = null


func _process(delta: float) -> void:
	self.LIFETIME -= delta
	if self.LIFETIME <= 0:
		self.queue_free()


func _physics_process(delta: float) -> void:
	if self.target and is_instance_valid(self.target):
		var direction = (self.target.global_position - self.global_position).normalized()
		self.global_position += direction * self.SPEED * delta
	else:
		self.queue_free()


func _on_body_entered(body: Node3D):
	if body != self.target:
		return
		
	if body.has_method("take_damage"):
		self.audio_player.stream = self.hit_sound
		self.audio_player.play()
		body.take_damage(self.DAMAGE)
		await self.audio_player.finished
		self.queue_free()
