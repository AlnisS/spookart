extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time = 0.0

var bounce_time = -100.0
var bounce_scale = 1.0

func _physics_process(delta):
	time += delta
	
	var bounce_progress = (time - bounce_time) / bounce_scale
	
	$BounceEffect/BounceOuter.radius = bounce_progress * 6
	$BounceEffect/BounceInner.radius = bounce_progress * 6 - 0.2
	$BounceEffect.material_override.albedo_color = Color(1.0, 1.0, 1.0, 1.0 - bounce_progress)
	
	$PlayerCamera.transform = $PlayerCamera.transform.interpolate_with($GolfCart/TargetCamera.get_global_transform(), 0.2)
	var steer_target = 0.0
	if Input.is_action_pressed("steer_left"):
		steer_target += 0.5
	if Input.is_action_pressed("steer_right"):
		steer_target -= 0.5
	$GolfCart.steering = lerp($GolfCart.steering, steer_target, 0.1)
	
	if Input.is_action_pressed("gas"):
		$GolfCart.engine_force = 100.0
	else:
		$GolfCart.engine_force = 0.0
	
	if Input.is_action_pressed("brake"):
		$GolfCart.brake = 1.0
		$GolfCart.engine_force = -100.0
	else:
		$GolfCart.brake = 0.0
	
#	print($GolfCart.get_global_transform().origin.y)
	
	if Input.is_action_just_pressed("jump") and $GolfCart.get_global_transform().origin.y <= 1.2:
		$GolfCart.apply_central_impulse(Vector3(0.0, 400.0, 1.0))
		$BounceEffect.transform.origin = Vector3($GolfCart.transform.origin.x, 0.17, $GolfCart.transform.origin.z)
		bounce_time = time
		
#	print($GolfCart.engine_force)
	
#	$GolfCart.engine_force = 0.0
#	print(lerp($GolfCart.steering, steer_target, 0.1))
#	$GolfCart.steering = 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
