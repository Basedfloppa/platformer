extends StaticBody3D

func _on_area_3d_body_entered(body):
	if body.name=="player":
		body.double_jump += 1
