extends Node

const SERVER_PORT:int = 10567
const MAX_PLAYERS:int = 6
const testIP:String = "127.0.0.1"

var peer:NetworkedMultiplayerENet = null
var peerId:int
var peerPseudo:String

var playersId:Array = []
var playersPseudo:Array = []

signal client_connected
signal player_disconnected
signal new_player_connected

signal receive_message
signal receive_kill
signal change_scene


func createClient(ipAdress:String):
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ipAdress, SERVER_PORT)
	get_tree().network_peer = peer
	print("Try to connect on port ", SERVER_PORT, " with ", testIP, " server ip.")

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	

func sendMessage(pseudo:String, msg:String):
	rpc_id(1, "clientMessage", pseudo, msg)

remote func receiveMessage(pseudo:String, msg:String):
	emit_signal("receive_message", pseudo, msg)



func sendKill(shooter:String, victim:String):
	rpc_id(1, "clientKill", shooter, victim)

remote func receiveKill(shooter:String, victim:String):
	emit_signal("receive_kill", shooter, victim)



func changeScene(path:String):
	rpc_id(1, "changeScene", path)

remote func receiveChangeScene(path:String):
	emit_signal("change_scene", path)







func getpseudoById(id:int):
	var index = playersId.find(id)
	return playersPseudo[index]


func updateMyPseudo(pseudo:String):
	peerPseudo = pseudo
	rpc_id(1, "donePlayerPseudo", peerId, pseudo)

remote func updatePlayerPseudo(id:int, pseudo:String):
	playersId.append(id)
	playersPseudo.append(0)
	
	var index = playersId.find(id)
	playersPseudo[index] = pseudo
	emit_signal("new_player_connected", pseudo)
	print("PlayersPseudo : ", playersPseudo)

func removePlayer(id:int):
	var index = playersId.find(id)
	if index != -1:
		playersId.remove(index)
		playersPseudo.remove(index)

remote func imConnected(ids:Array, pseudos:Array):
	playersId = ids
	playersPseudo = pseudos
	
	emit_signal("client_connected")
	
	print("I'm connected.")
	print("PlayersId : ", playersId)

remote func newPlayerConnected(id:int):
	if id != get_tree().get_network_unique_id():
		playersId.append(id)
		playersPseudo.append(str(id))
		print("New player *", id,"* connected.")
		print("PlayersId : ", playersId)
		

func _player_disconnected(id:int):
	removePlayer(id)
	emit_signal("player_disconnected", id)
	print("Player *", id, "* disconnected :(")
	print("PlayersId : ", playersId)
	print("PlayersPseudo : ", playersPseudo)

func _connected_ok():
	peerId = get_tree().get_network_unique_id()
	print("Conection to server succesfully!")

func _connected_fail():
	print("Connection fail")

func _server_disconnected():
	print("Server disconnected")
	
