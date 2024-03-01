extends Area3D

func _on_body_entered(body):
	if body.name=="player":
		body.position = Vector3(0,7,0)
