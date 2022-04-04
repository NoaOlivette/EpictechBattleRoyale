extends Area2D

onready var sprite:Sprite = $Sprite

var direction:Vector2 = Vector2(0, 0)
const speed:int = 1000

var playerOwner:int = 0

func _process(delta):
	var velocity = Vector2(direction.x * speed * delta, direction.y * speed * delta)
	self.position += velocity

func setBullet(pos:Vector2, dir:Vector2, rot:float):
	self.position = pos
	direction = dir
	self.rotation_degrees = rot - 90

func setPlayerOwner(id:int):
	playerOwner = id

func getPlayerOwner() -> int:
	return playerOwner

func _on_Timer_timeout():
	self.queue_free()


func _on_Bullet_area_entered(area):
	if area.get_parent().is_in_group("Player") and area.get_parent().has_method("getPlayerOwner") and playerOwner != area.get_parent().getPlayerOwner():
		queue_free()
