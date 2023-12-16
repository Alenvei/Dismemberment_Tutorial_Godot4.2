extends Camera3D

const ray_length = 100
var mouse_pos : Vector2
var from :Vector3
var to : Vector3
var space : PhysicsDirectSpaceState3D
var query : PhysicsRayQueryParameters3D
@onready var mannequin = $"../mannequin/mannequin/Armature/Skeleton3D"

	
func camera_raycast():
	mouse_pos = get_viewport().get_mouse_position()
	from = project_ray_origin(mouse_pos) 
	to = from + project_ray_normal(mouse_pos) * ray_length
	space = get_world_3d().direct_space_state
	
	query = PhysicsRayQueryParameters3D.create(from,to,1)
	
	return space.intersect_ray(query)
	
	
func _process(delta):
	#Use the left mouse button to dismember a limb
	if Input.is_action_just_pressed("left_mb"):
		var raycast = camera_raycast()
		if not raycast.is_empty():
			if raycast.collider.is_in_group("limbs"):
				raycast.collider.get_parent().dismemberment(raycast.collider)
				
