extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
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
#	print($GolfCart.engine_force)
	
#	$GolfCart.engine_force = 0.0
#	print(lerp($GolfCart.steering, steer_target, 0.1))
#	$GolfCart.steering = 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
