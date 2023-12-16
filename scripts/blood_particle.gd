extends GPUParticles3D

@onready var blood_spot = $blood_spot

func _process(delta):
	if blood_spot.emitting:
		if not blood_spot.emitting:
			self.queue_free()
	pass

