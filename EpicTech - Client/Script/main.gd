extends Node2D

onready var player:PackedScene = preload("res://Scene/Player.tscn")

onready var spectateLabel:Label = $CanvasLayer/Spectate
onready var placeLabel:Label = $CanvasLayer/Place

var isSpectate:bool = false
var PlayersAlive:Array

func _ready():
	print(Server.playersId)
	PlayersAlive = Server.playersId
	for id in Server.playersId:
		var child = player.instance()
		
		child.name = str(id)
		child.setPlayerOwner(id)
		child.set_network_master(id)
		
		Persist.add_child(child)
		if id == Server.peerId:
			child.setCurrentCam()
		

func playerDead(id:int):
	PlayersAlive.erase(id)
	if isSpectate == false and PlayersAlive.size() == 1:
		spectateLabel.text = "Victoire Royale"
		placeLabel.text = "#1"

func setSpectate(pseudo:String):
	spectateLabel.text = "Spectate : " + pseudo
	placeLabel.text = "#" + str(PlayersAlive.size())
	spectateLabel.show()
	placeLabel.show()
	isSpectate = true
	
