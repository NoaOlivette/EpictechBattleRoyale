extends KinematicBody2D

var playerOwner:int = 0

const speed:int = 400
var direction:Vector2 = Vector2(0, 0)
var velocity:Vector2 = Vector2(0, 0)

var bulletDamage = 50

onready var sprite:Node2D = $Sprite
onready var canon:Node2D = $Sprite/Canon
onready var cam:Camera2D = $Camera2D
onready var healthBar:TextureProgress = $CanvasLayer/HealthBar
onready var bulletSpawn:Position2D = $Sprite/Canon/BulletSpawn
onready var animationplayer:AnimationPlayer = $AnimationPlayer

onready var bullet:PackedScene = preload("res://Scene/Bullet.tscn")

func _ready():
	if not is_network_master():
		healthBar.hide()

func _process(delta):
	if self.is_network_master():
		if Input.is_action_pressed("ui_right"):
			direction = Vector2(1, 0)
		elif Input.is_action_pressed("ui_left"):
			direction = Vector2(-1, 0)
		elif Input.is_action_pressed("ui_up"):
			direction = Vector2(0, -1)
		elif Input.is_action_pressed("ui_down"):
			direction = Vector2(0, 1)
		
		canon.look_at(get_global_mouse_position())
		
		velocity = Vector2(direction.x * speed * delta, direction.y * speed * delta)
		
		move_and_collide(velocity)
		
		direction = Vector2(0, 0)
		
		rpc_unreliable("updatePuppet", self.position, canon.rotation_degrees)
		
		
		if Input.is_action_just_pressed("shoot"):
			var target = sprite.global_position.direction_to(get_global_mouse_position())
			rpc("instanceBullet", Server.peerId, bulletSpawn.global_position, target, canon.rotation_degrees)
			

remote func updatePuppet(pos:Vector2, rotation:int):
	if not self.is_network_master():
		self.position = pos
		canon.rotation_degrees = rotation
		

remotesync func instanceBullet(id:int, pos:Vector2, dir:Vector2, rot:float):
#	print("lol")
	var child = bullet.instance()
	Persist.add_child(child)
	child.setPlayerOwner(id)
	child.setBullet(pos, dir, rot)








remotesync func getHit(idShooter:int, idVictim:int):
	if idVictim == playerOwner:
		animationplayer.play("hit")
		if self.is_network_master():
			healthBar.value -= bulletDamage
			if healthBar.value <= 0:
				rpc("imDead", idShooter, idVictim)
				Server.sendKill(Server.getpseudoById(idShooter), Server.getpseudoById(idVictim))

remotesync func imDead(idShooter:int, idVictim:int):
	var playerVictim = Persist.get_node(str(idVictim))
	var playerShooter = Persist.get_node(str(idShooter))
	playerShooter.setCurrentCam()
	playerVictim.queue_free()

func _on_Hitbox_area_entered(area):
	if self.is_network_master():
		if area.is_in_group("HitItem") and area.getPlayerOwner() != Server.peerId:
			rpc("getHit", area.getPlayerOwner(), Server.peerId)
	





func setPlayerOwner(id:int):
	playerOwner = id

func getPlayerOwner() -> int:
	return playerOwner


func setCurrentCam():
	cam.current = true
	

func _on_AnimationPlayer_animation_finished(anim_name):
	animationplayer.play("RESET")























