extends VehicleBody

signal driver_hit

func _on_DriverArea_area_entered(area):
	emit_signal("driver_hit")
