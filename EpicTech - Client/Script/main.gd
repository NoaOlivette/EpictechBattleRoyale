extends Node2D

onready var player:PackedScene = preload("res://Scene/Player.tscn")

func _ready():
	print(Server.playersId)
	for id in Server.playersId:
		var child = player.instance()
		
		child.name = str(id)
		child.setPlayerOwner(id)
		child.set_network_master(id)
		
		Persist.add_child(child)
		if id == Server.peerId:
			child.setCurrentCam()
		
