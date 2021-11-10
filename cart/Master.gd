extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var golf_ball_scene = preload("res://ball/GolfBall.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time = 0.0

var bounce_time = -100.0
var bounce_scale = 0.5

var balls = 1

var score = 0

var gameover = false
var gameover_time = -1.0

func _physics_process(delta):
	time += delta
	
	var bounce_progress = (time - bounce_time) / bounce_scale
	
	$BounceEffect/BounceOuter.radius = bounce_progress * 12
	$BounceEffect/BounceInner.radius = bounce_progress * 12 - 0.4
	$BounceEffect.material_override.albedo_color = Color(1.0, 1.0, 1.0, pow(1.0 - bounce_progress, 3))
	
	var target_camera = $GolfCart/TargetCamera
	if Input.is_action_pressed("camera_2"):
		target_camera = $GolfCart/TargetCamera2
	
	var view_displacement = $PlayerCamera.transform.origin - target_camera.get_global_transform().origin
	var view_distance = view_displacement.length()
	var extra_lerp = clamp((view_distance - 0.3) * 3, 0.0, 0.7)
	if Input.is_action_pressed("camera_2"):
		extra_lerp = 0.0

	
	var target_transform = target_camera.get_global_transform()
	if Input.is_action_pressed("peek"):
		target_transform.basis = target_transform.basis.rotated($GolfCart.transform.basis.y, PI * -7/8)
	
	
	$PlayerCamera.transform = $PlayerCamera.transform.interpolate_with(target_transform, 0.3 + extra_lerp)
	
	var steer_target = 0.0
	if Input.is_action_pressed("steer_left"):
		steer_target += 0.6
	if Input.is_action_pressed("steer_right"):
		steer_target -= 0.6
	$GolfCart.steering = lerp($GolfCart.steering, steer_target, 0.1)
	
	$GolfCart/Chassis/SteeringBase/SteeringWheel.rotation.y = $GolfCart.steering * 2
	
	if Input.is_action_pressed("gas"):
		$GolfCart.engine_force = 150.0
	else:
		$GolfCart.engine_force = 0.0
	
	if Input.is_action_pressed("brake"):
		$GolfCart.brake = 1.0
		$GolfCart.engine_force = -150.0
	else:
		$GolfCart.brake = 0.0
	
#	if Input.is_action_just_pressed("jump") and $GolfCart.get_global_transform().origin.y <= 1.2:
	if Input.is_action_just_pressed("jump"):
#		$GolfCart.apply_central_impulse(Vector3(0.0, 450.0, 1.0))
		$GolfCart.apply_central_impulse($GolfCart.transform.basis.y * 450)
#		$BounceEffect.transform.origin = Vector3($GolfCart.transform.origin.x, 0.17, $GolfCart.transform.origin.z)
		$BounceEffect.transform.origin = $GolfCart.transform.origin - Vector3(0, 0, 0)
		bounce_time = time
	
	var orientation: Vector3 = $GolfCart.transform.basis.y
	var correction = orientation.cross(Vector3(0.0, 1.0, 0.0))
	
	$GolfCart.add_torque(correction * 1000.0)
	$GolfCart.angular_damp = 0.2
	
	if balls < time / 10.0:
		balls += 1
		$BallSpawner.add_child(golf_ball_scene.instance())
		$BallAlarm.playing = true
	
	for golf_ball in $BallSpawner.get_children():
#		golf_ball.target = $GolfCart.transform.origin + Vector3(0, 0.17, 0)
		golf_ball.target = $GolfCart/DriverArea.get_global_transform().origin + Vector3(0, 0.17, 0)
		var nudge_away = Vector3.ZERO
		for gb2 in $BallSpawner.get_children():
			if gb2.transform.origin.is_equal_approx(golf_ball.transform.origin):
				continue
			var displacement = gb2.transform.origin - golf_ball.transform.origin
			var direction = displacement.normalized()
			var force = -direction * 4 / (displacement.length_squared())
			nudge_away += force
		golf_ball.nudge_away = nudge_away
		
		score += delta * 100 / (golf_ball.target - golf_ball.transform.origin).length()
	
	if gameover:
		$EndScreen.modulate = Color(1.0, 1.0, 1.0, clamp(time - gameover_time, 0.0, 1.0))
	
	if not gameover:
		score += delta * 20
		$ScoreLabel.text = "SCORE  " + str(round(score))


func _on_GolfCart_driver_hit():
	$EndScreen/Score.text = "SCORE  " + str(round(score))
	gameover = true
	gameover_time = time
	
#	print("driver hit")
