extends Spatial


var target = Vector3.ZERO
var nudge_away = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	var golf_ball_direction = target - get_global_transform().origin + Vector3(0.0, 0.4, 0.0)
	var golf_ball_movement = golf_ball_direction.normalized() * delta * 2
	transform.origin += golf_ball_movement
	transform.origin += nudge_away * delta
	
	$Visual.rotate_y(delta * PI / 2)
	
	
	var angle = time * 3
	$Ring.rotation = Vector3(sin(angle), cos(angle), sin(angle) + cos(angle))
	$Ring2.rotation = Vector3(pow(cos(angle) * 0.5 - sin(angle), 3), sin(angle) + cos(angle), sin(angle))
	$Ring3.rotation = Vector3(sin(angle) + cos(angle), sin(angle), pow(cos(angle), 3))
