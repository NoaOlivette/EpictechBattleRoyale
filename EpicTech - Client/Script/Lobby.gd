extends Control

onready var ipEdit:LineEdit = $IpEdit
onready var startButton:Button = $StartButton
onready var pseudoEdit:LineEdit = $PseudoEdit
onready var connectButton:Button = $ConnectButton
onready var hBox:HBoxContainer = $HBoxContainer
onready var vBox1:VBoxContainer = $HBoxContainer/VBoxContainer1
onready var vBox2:VBoxContainer = $HBoxContainer/VBoxContainer2

onready var panelPseudo:PackedScene = preload("res://Scene/PanelPseudo.tscn")

func _ready():
	Server.connect("client_connected", self, "clientConnected")
	Server.connect("new_player_connected", self, "addPlayer")
	Server.connect("player_disconnected", self, "removePlayer")
	Server.connect("change_scene", self, "changeScene")
	
	startButton.hide()

func _process(delta):
	if vBox1.get_child_count() > 0:
		vBox1.get_children()[0].modulate = "fdff00"
		if vBox1.get_children()[0].name == str(Server.peerId):
			startButton.show()
			
	


func removePlayer(id:int):
	for panel in vBox1.get_children():
		if panel.name == str(id):
			panel.queue_free()
	for panel in vBox2.get_children():
		if panel.name == str(id):
			panel.queue_free()
	
	
	

func addPlayer(pseudo:String):
	var child = panelPseudo.instance()
	if vBox1.get_child_count() < 10:
		vBox1.add_child(child)
	else:
		vBox2.add_child(child)
	child.setPseudo(pseudo)
	var index = Server.playersPseudo.find(pseudo)
	child.name = str(Server.playersId[index])
	print("add :*", pseudo, "*")
	


func displayAllPseudo():
	print("Server.playersPseudo = ", Server.playersPseudo.size())
	for pseudo in Server.playersPseudo:
		if pseudo != str(Server.peerId):
			addPlayer(pseudo)

func clientConnected():
	if checkPseudoIstaken() == false:
		Server.updateMyPseudo(pseudoEdit.text)
		displayAllPseudo()
	else:
		Server.peer = null
		Server.peerId = -1

func checkPseudoOnlySpace():
	var text = pseudoEdit.text
	for i in text:
		if i != ' ':
			return false
	return true

func checkPseudoIstaken():
	if pseudoEdit.text.length() < 3 or pseudoEdit.text.length() > 12  or checkPseudoOnlySpace():
		retryConnection()
		return true
		
	for pseudo in Server.playersPseudo:
		if pseudoEdit.text == pseudo :
			retryConnection()
			return true
			
	return false

func retryConnection():
	connectButton.show()
	pseudoEdit.text = ""
	ipEdit.editable = true
	pseudoEdit.editable = true
	startButton.hide()

func _on_ConnectButton_pressed():
	Server.createClient(ipEdit.text)
	connectButton.hide()
	ipEdit.editable = false
	pseudoEdit.editable = false

func changeScene(path:String):
	get_tree().change_scene(path)


func _on_StartButton_pressed():
	Server.changeScene("res://Scene/main.tscn")
