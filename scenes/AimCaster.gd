extends RayCast3D


signal new_aimable(aimable: CharacterBody3D)
signal no_aimable()

var aimable: CharacterBody3D


func _ready():
	pass


func _process(delta):
	if self.is_colliding():
		var body: CharacterBody3D = self.get_collider()
		if body == self.aimable:
			return
		else:
			self.aimable = body
			new_aimable.emit(self.aimable)
	else:
		if self.aimable:
			self.aimable = null
			no_aimable.emit()
		return
