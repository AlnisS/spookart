extends Spatial

var golf_ball_scene = preload("res://ball/GolfBall.tscn")

func _ready():
	$PlayButton.grab_focus()
	get_tree().paused = true

var time = 0.0

var bounce_time = -100.0
var bounce_scale = 0.5

var balls = 1

var score = 0

var charge = 100.0

var gameover = false
var gameover_time = -1.0


func _physics_process(delta):
	time += delta
	
	if $Music.get_playback_position() > 177.8:
		$Music.seek(11.1)
	
	var bounce_progress = (time - bounce_time) / bounce_scale
	
	# TODO convert this to use signals
	$BounceEffect/BounceOuter.radius = bounce_progress * 12
	$BounceEffect/BounceInner.radius = bounce_progress * 12 - 0.4
	$BounceEffect.material_override.albedo_color = \
			Color(1.0, 1.0, 1.0, pow(1.0 - bounce_progress, 3))
	
	var target_camera = ($GolfCart/TargetCamera2 if Input.is_action_pressed("camera_2")
			else $GolfCart/TargetCamera)
	
	var view_displacement = ($PlayerCamera.transform.origin
			- target_camera.get_global_transform().origin)
	var extra_lerp = (0.0 if Input.is_action_pressed("camera_2")
			else clamp((view_displacement.length() - 0.3) * 3, 0.0, 0.7))
	
	var target_transform = target_camera.get_global_transform()
	if Input.is_action_pressed("peek"):
		target_transform.basis = target_transform.basis.rotated(
				$GolfCart.transform.basis.y, PI * -7/8)
	
	
	$PlayerCamera.transform = $PlayerCamera.transform.interpolate_with(
			target_transform, 0.3 + extra_lerp)
	
	var steer_target = 0.0
	if Input.is_action_pressed("steer_left"):
		steer_target += 0.6
	if Input.is_action_pressed("steer_right"):
		steer_target -= 0.6
	$GolfCart.steering = lerp($GolfCart.steering, steer_target, 0.1)
	
	$GolfCart/Chassis/SteeringBase/SteeringWheel.rotation.y = $GolfCart.steering * 2
	
	$GolfCart.engine_force = 0.0
	
	if Input.is_action_pressed("gas") and charge > 0:
		charge -= 1.5 * delta
		$GolfCart.engine_force = 150.0
	
	if Input.is_action_pressed("brake") and charge > 0:
		charge -= 1.5 * delta
		$GolfCart.engine_force = -150.0
	
	$GolfCart.brake = 1.0 if Input.is_action_pressed("brake") else 0.0
	
	if Input.is_action_just_pressed("jump") and charge > 10:
		charge -= 10
		$GolfCart.apply_central_impulse($GolfCart.transform.basis.y * 450)
		$BounceEffect.transform.origin = $GolfCart.transform.origin
		bounce_time = time
	
	if Input.is_action_just_pressed("dash") and charge > 10:
		charge -= 10
		$GolfCart.apply_central_impulse($GolfCart.transform.basis.x * -450)
		# TODO dash effect visual
	
	if Input.is_action_just_pressed("freeze") and charge > 10:
		charge -= 10
		for golf_ball in $BallSpawner.get_children():
			golf_ball.freeze()
	
	var orientation: Vector3 = $GolfCart.transform.basis.y
	var correction = orientation.cross(Vector3(0.0, 1.0, 0.0))
	
	$GolfCart.add_torque(correction * 1000.0)
	$GolfCart.angular_damp = 0.2
	
	if balls < time / 10.0:
		balls += 1
		var new_golf_ball = golf_ball_scene.instance()
		$BallSpawner.add_child(new_golf_ball)
		var location = $GolfCart.get_global_transform().origin
		location.y = 0
		new_golf_ball.transform.origin = location.normalized() * 60
	
	for golf_ball in $BallSpawner.get_children():
		golf_ball.target = ($GolfCart/DriverArea.get_global_transform().origin
				+ Vector3(0, 0.17, 0))
		var nudge_away = Vector3.ZERO
		for gb2 in $BallSpawner.get_children():
			if gb2.transform.origin.is_equal_approx(golf_ball.transform.origin):
				continue
			var displacement = gb2.transform.origin - golf_ball.transform.origin
			var direction = displacement.normalized()
			var repulsion_force = -direction * 4 / (displacement.length_squared())
			nudge_away += repulsion_force
		golf_ball.nudge_away = nudge_away
		
		score += delta * 100 / (golf_ball.target - golf_ball.transform.origin).length()
	
	if gameover:
		$EndScreen.show()
		$EndScreen.modulate = Color(1.0, 1.0, 1.0, clamp(time - gameover_time, 0.0, 1.0))
	
	if not gameover:
		score += delta * 20
		$ScoreLabel.text = "SCORE  " + str(round(score))
		$ChargeBar.value = charge
	
	if $GolfCart.get_global_transform().origin.y < -1 and not gameover:
		_on_GolfCart_driver_hit()


func _on_GolfCart_driver_hit():
	if gameover:
		return
	
	$EndScreen/Score.text = "SCORE  " + str(round(score))
	gameover = true
	gameover_time = time


func _on_PlayButton_pressed():
	$BounceEffect.show()
	$ScoreLabel.show()
	$ChargeBar.show()
	$ChargeLabel.show()
	$PlayButton.hide()
	$GameTitleLabel.hide()
	$InstructionsButton.hide()
	$InstructionsPopup.hide()
	$CreditsButton.hide()
	$CreditsPopup.hide()
	get_tree().paused = false


func _on_InstructionsButton_pressed():
	$InstructionsPopup.popup_centered()


func _on_CreditsButton_pressed():
	$CreditsPopup.popup_centered()
