extends Control

var state:bool = false

onready var msgEdit:LineEdit = $Message
onready var vBox:VBoxContainer = $VBoxContainer
onready var timer:Timer = $Timer

onready var tchatMsg:PackedScene = preload("res://Scene/TchatMessage.tscn")
onready var tchatkill:PackedScene = preload("res://Scene/TchatKill.tscn")

func _ready():
	Server.connect("receive_message", self, "receiveMessage")
	Server.connect("receive_kill", self, "receiveKill")
	
	msgEdit.hide()
	


func _process(delta):
	if Server.peer != null:
		if Input.is_action_just_pressed("enter"):
			if state == false:
				msgEdit.show()
				msgEdit.grab_focus()
				state = true
			else:
				sendMessage()
				msgEdit.hide()
				state = false
	

func checkOnlySpace(msg:String):
	for i in msg:
		if i != ' ':
			return false
	return true

func receiveMessage(sender:String, msg:String):
	if vBox.get_child_count() > 10:
		vBox.get_children()[0].queue_free()
	var child = tchatMsg.instance()
	vBox.add_child(child)
	child.setSender(sender + ": ")
	child.setMessage(msg)
	if sender == Server.peerPseudo:
		child.modulate = "c800edff"

func receiveKill(shooter:String, victim:String):
	vBox.show()
	timer.stop()
	
	if vBox.get_child_count() > 10:
		vBox.get_children()[0].queue_free()
	var child = tchatkill.instance()
	
	vBox.add_child(child)
	child.setShooter(shooter)
	child.setVictim(victim)
	
	startTimer()

func sendMessage():
	if msgEdit.text.length() > 0 and checkOnlySpace(msgEdit.text) == false:
		Server.sendMessage(Server.peerPseudo, msgEdit.text)
		msgEdit.text = ""



func startTimer():
	timer.start()

func _on_Timer_timeout():
	vBox.hide()
