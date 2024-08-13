extends RayCast3D

signal new_pickupable(pickupable: RigidBody3D)
signal no_pickupable

var pickupable: PhysicsBody3D


func _ready():
	pass


func _process(delta):
	if self.is_colliding():
		var body: PhysicsBody3D = self.get_collider()
		if body == self.pickupable:
			return
		else:
			self.pickupable = body
			new_pickupable.emit(self.pickupable)
	else:
		if self.pickupable:
			self.pickupable = null
			no_pickupable.emit()
		return
