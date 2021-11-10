extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time = 0.0

var bounce_time = -100.0
var bounce_scale = 0.5

func _physics_process(delta):
	time += delta
	
	var bounce_progress = (time - bounce_time) / bounce_scale
	
	$BounceEffect/BounceOuter.radius = bounce_progress * 8
	$BounceEffect/BounceInner.radius = bounce_progress * 8 - 0.2
	$BounceEffect.material_override.albedo_color = Color(1.0, 1.0, 1.0, pow(1.0 - bounce_progress, 3))
	
	var view_displacement = $PlayerCamera.transform.origin - $GolfCart/TargetCamera.get_global_transform().origin
	var view_distance = view_displacement.length()
	var extra_lerp = clamp((view_distance - 0.3) * 3, 0.0, 0.7)
#	var extra_lerp = 0.2
#	print(extra_lerp)
#	print(view_distance)
	
	$PlayerCamera.transform = $PlayerCamera.transform.interpolate_with($GolfCart/TargetCamera.get_global_transform(), 0.3 + extra_lerp)
	
	var steer_target = 0.0
	if Input.is_action_pressed("steer_left"):
		steer_target += 0.6
	if Input.is_action_pressed("steer_right"):
		steer_target -= 0.6
	$GolfCart.steering = lerp($GolfCart.steering, steer_target, 0.1)
	
	$GolfCart/Chassis/SteeringBase/SteeringWheel.rotation.y = $GolfCart.steering * 2
	print($GolfCart.steering)
	
	if Input.is_action_pressed("gas"):
		$GolfCart.engine_force = 150.0
	else:
		$GolfCart.engine_force = 0.0
	
	if Input.is_action_pressed("brake"):
		$GolfCart.brake = 1.0
		$GolfCart.engine_force = -150.0
	else:
		$GolfCart.brake = 0.0
	
#	print($GolfCart.get_global_transform().origin.y)
	
	if Input.is_action_just_pressed("jump") and $GolfCart.get_global_transform().origin.y <= 1.2:
		$GolfCart.apply_central_impulse(Vector3(0.0, 450.0, 1.0))
		$BounceEffect.transform.origin = Vector3($GolfCart.transform.origin.x, 0.17, $GolfCart.transform.origin.z)
		bounce_time = time
	
	var orientation: Vector3 = $GolfCart.transform.basis.y
	var correction = orientation.cross(Vector3(0.0, 1.0, 0.0))
	
	$GolfCart.add_torque(correction * 1000.0)
	$GolfCart.angular_damp = 0.2
	
#	print($GolfCart.engine_force)
	
#	$GolfCart.engine_force = 0.0
#	print(lerp($GolfCart.steering, steer_target, 0.1))
#	$GolfCart.steering = 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
