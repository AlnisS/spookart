extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	var angle = time * 3
	$Ring.rotation = Vector3(sin(angle), cos(angle), sin(angle) + cos(angle))
	$Ring2.rotation = Vector3(pow(cos(angle) * 0.5 - sin(angle), 3), sin(angle) + cos(angle), sin(angle))
	$Ring3.rotation = Vector3(sin(angle) + cos(angle), sin(angle), pow(cos(angle), 3))
