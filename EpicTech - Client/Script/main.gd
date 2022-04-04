extends Node2D

onready var player:PackedScene = preload("res://Scene/Player.tscn")

onready var spectateLabel:Label = $CanvasLayer/Spectate

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
		

func setSpectate(pseudo:String):
	spectateLabel.text = "Spectate : " + pseudo
	spectateLabel.show()
