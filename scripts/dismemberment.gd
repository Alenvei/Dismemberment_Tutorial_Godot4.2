extends Skeleton3D
#Use the left mouse button to dismember a limb

# Array of limb scenes and blood scene
@export var limbs : Array[PackedScene]
@export var blood : PackedScene

# Variables for joint function
@export var bias : float = 0.55
@export var damping : float = 1
@export var impulse_clamp : float = 0

# Nodes and variables for ragdoll setup
var is_simulation :bool = false
var physics_bones : Array

func _ready():
	# Array to store physical bones
	physics_bones = get_children().filter(func(i):return i as PhysicalBone3D)

	
func _physics_process(delta):
	# Function to update physical bones transform
	if !is_simulation:
		_follow_bone()

# Function to dismember bones
func dismemberment(bone):
	# Variables for dismembered limbs and bone information
	var dis_limb : RigidBody3D
	var dis_child_limb : RigidBody3D
	var bone_id = bone.get_bone_id()
	var bone_pos = get_bone_global_pose(bone_id)
	var child_bone_pos : Transform3D
	var physical_child_bone : PhysicalBone3D = null
	
	# Check if the selected bone has a child bone and save it if yes
	for child_bone in physics_bones:
		if child_bone.is_in_group("limbs") and get_bone_children(bone_id):
			if child_bone.bone_name == get_bone_name(get_bone_children(bone_id)[0]):
				physical_child_bone = child_bone
				child_bone_pos = get_bone_global_pose(physical_child_bone.get_bone_id())
				
	# Remove bones from scene
	_remove_bone([bone, physical_child_bone])
				
	# Instantiate and position dismembered limb objects
	for i in limbs:
		# Check if the bone name matches with the limb scene's name
		if bone.bone_name.find(i._bundled.names[0]) != -1:
			 # Instantiate the dismembered limb
			dis_limb = i.instantiate()
			dis_limb.set_as_top_level(true)
			dis_limb.global_transform = bone_pos 
			
			# Set position and add blood splash effect
			var blood_spash = blood.instantiate()
			blood_spash.transform.origin = bone_pos.origin
			blood_spash.emitting = true
			
			# Add blood splash and dismembered limb to the scene
			add_child(blood_spash)
			add_child(dis_limb)
			
		# Instantiate and position dismembered limb objects where the child bone is, if it exists
		if physical_child_bone:
			# Check if the child bone's name matches with the limb scene's name
			if physical_child_bone.bone_name.find(i._bundled.names[0]) != -1:
				# Create the dismembered child limb
				dis_child_limb = i.instantiate()
				dis_child_limb.set_as_top_level(true)
				dis_child_limb.global_transform = child_bone_pos

				# Add dismembered child limb to the scene
				add_child(dis_child_limb)
			
	
	# Add joint between dismembered parent and child limbs
	if physical_child_bone:
		add_joint(dis_limb, dis_child_limb)
		
	# Start simulation if the dismembered bone is the head
	if bone.bone_name.find("Head") != -1:
		physical_bones_start_simulation()
		is_simulation = true
	
# Function to create and add a pin joint between two nodes
func add_joint(node_A, node_B):
	var pin = PinJoint3D.new()
	pin.set("params/bias", bias)
	pin.set("params/damping", damping)
	pin.set("params/impulse_clamp", impulse_clamp) 
	pin.exclude_nodes_from_collision = false
	
	pin.set_node_a(node_A.get_path())
	pin.set_node_b(node_B.get_path())
	
	node_B.add_child(pin)
	pass
	
# Function to update physical bone transform
func _follow_bone():
	for bone in physics_bones:
		var bone_offest : Transform3D = bone.get("body_offset") 
		var bone_global_transform = self.global_transform * self.get_bone_global_pose(bone.get_bone_id())
		bone.global_transform = bone_global_transform * bone_offest
		
# Function to remove bones from the scene
func _remove_bone(bones:Array):
	for bone in bones :
		if bone:
			var bone_transform = get_bone_global_pose(bone.get_bone_id())
			set_bone_global_pose_override(bone.get_bone_id(), bone_transform.scaled(Vector3.ONE * 0.0001), 1.0, true)
			bone.collision_layer = 0
			bone.collision_mask = 0
			bone.get_parent().remove_child(bone) 
			bone.queue_free()
			physics_bones.erase(bone)
