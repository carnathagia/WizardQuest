extends CharacterBody3D

@export var WALK_SPEED: float = 1.7
@export var RUN_SPEED: float = 4.0
@export var MOUSE_SENSITIVITY: float = 0.5
@export var MAX_X_ROTATION: float = 1.0
@export var ROTATION_SPEED: float = 10.0
@export var AIM_ROTATION_SPEED: float = 20.0
@export var fireball_scene: PackedScene

@onready var camera_mount: Node3D = $CameraMount
@onready var model: Node3D = $model
@onready var animation_player: AnimationPlayer = $model/AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var aiming: bool
var aiming_transition: bool
var aiming_rotation: Basis

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if self.aiming_transition:
		return
	if event is InputEventMouseMotion:
		var x_rotation: float = deg_to_rad(event.relative.y * MOUSE_SENSITIVITY)
		var y_rotation: float = deg_to_rad(event.relative.x * MOUSE_SENSITIVITY)

		# Handle aiming rotation
		if self.aiming and not self.aiming_transition:
			self.camera_mount.rotate_x(x_rotation)
			self.rotate_y(-y_rotation)
			if self.camera_mount.rotation.x > MAX_X_ROTATION:
				self.camera_mount.rotation.x = MAX_X_ROTATION
			elif self.camera_mount.rotation.x < -MAX_X_ROTATION:
				self.camera_mount.rotation.x = -MAX_X_ROTATION
				
		# Handle free look camera rotation
		else:
			self.camera_mount.rotate_x(x_rotation)
			self.rotate_y(-y_rotation)
			self.model.rotate_y(y_rotation)
			if self.camera_mount.rotation.x > MAX_X_ROTATION:
				self.camera_mount.rotation.x = MAX_X_ROTATION
			elif self.camera_mount.rotation.x < -MAX_X_ROTATION:
				self.camera_mount.rotation.x = -MAX_X_ROTATION


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("aim"):
		self.aiming = true
		self.aiming_transition = true
		self.aiming_rotation = self.global_transform.basis
	elif Input.is_action_just_released("aim"):
		self.aiming = false
		self.aiming_transition = false
		
	if self.aiming_transition:
		self.camera_mount.global_transform.basis = self.camera_mount.global_transform.basis.slerp(self.aiming_rotation, self.AIM_ROTATION_SPEED * delta)
		self.model.global_transform.basis = self.model.global_transform.basis.slerp(self.aiming_rotation, self.AIM_ROTATION_SPEED * delta)
		if self.camera_mount.global_transform.basis.is_equal_approx(self.aiming_rotation):
			self.aiming_transition = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		self.aiming = false
		self.aiming_transition = false
		self.velocity.y -= gravity * delta

	var is_casting: bool = Input.is_action_just_pressed("cast")
	if is_casting:
		if self.animation_player.current_animation != "Spellcast_Shoot":
			self.animation_player.play("Spellcast_Shoot")
		self._shoot_fireball()
	if self.aiming:
		self.velocity.x = 0
		self.velocity.z = 0
		if self.animation_player.current_animation != "Spellcasting" and self.animation_player.current_animation != "Spellcast_Shoot":
			self.animation_player.play("Spellcasting")
	else:
		var is_running: bool = Input.is_action_pressed("run")
		var speed: float = self.RUN_SPEED if is_running else self.WALK_SPEED

		var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
		var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction and not self.aiming:
			if is_running:
				if self.animation_player.current_animation != "Running_A":
					self.animation_player.play("Running_A")
			else:
				if self.animation_player.current_animation != "Walking_A":
					self.animation_player.play("Walking_A")

			# Rotate model smoothly towards movement direction
			var target_transform: Transform3D = model.global_transform.looking_at(global_transform.origin + direction, Vector3.UP)
			self.model.global_transform.basis = model.global_transform.basis.slerp(target_transform.basis, self.ROTATION_SPEED * delta)

			self.velocity.x = -direction.x * speed
			self.velocity.z = -direction.z * speed
		else:
			if self.animation_player.current_animation != "Idle":
				self.animation_player.play("Idle")
			self.velocity.x = move_toward(velocity.x, 0, speed)
			self.velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _shoot_fireball() -> void:
	var fireball_instance = fireball_scene.instantiate()  # Instantiate the fireball scene
	get_parent().add_child(fireball_instance)  # Add the fireball to the scene tree
	
	# Set the fireball's initial position and direction
	fireball_instance.global_transform.origin = self.global_transform.origin + self.camera_mount.global_transform.basis.z * 2
	var direction = -self.camera_mount.global_transform.basis.z  # Direction to move fireball in
	fireball_instance.set("direction", direction.normalized() * fireball_speed)
