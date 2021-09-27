extends Node2D

onready var prevCoins = Config.coins
onready var gameUI = get_tree().root.get_node("Game/CanvasLayer/GameUI")

func _ready():
	Config.connect("coins", self, "update_coins")
	
func update_coins():
	print("prev coins ", prevCoins, "  Config.coins: ", Config.coins)
	if prevCoins != Config.coins:
		play()

func play():
	$Particles2D.emitting = true
	$AnimationPlayer.play("play")

func _on_AnimationPlayer_animation_finished(anim_name):
	var coins = gameUI.coinSprite
	$Tween.interpolate_property($Sprite, "global_position", $Sprite.global_position, coins.global_position, 1,Tween.EASE_OUT,Tween.EASE_IN)
	$Tween.interpolate_property($Sprite, "scale", Vector2(1,1), Vector2(0,0), 1,Tween.EASE_OUT,Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	$AnimationPlayer.seek(0, true)
	$Sprite.position = Vector2(0,0)
	gameUI.update_coins()
	
