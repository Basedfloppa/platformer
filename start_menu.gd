extends Control

var test_lvl = "res://Test_lvl.tscn"

func _on_test_level_btn_pressed():
	get_tree().change_scene_to_file(test_lvl)

func _on_exit_btn_pressed():
	get_tree().quit() 
