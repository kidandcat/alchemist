extends Node2D


func play():
	$Particles2D.emitting = true
	$AnimationPlayer.play("play")


func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.seek(0, true)
