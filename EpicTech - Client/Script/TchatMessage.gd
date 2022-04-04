extends Control

onready var sender:Label = $Sender
onready var message:Label = $Message

func setSender(pseudo:String):
	sender.text = pseudo

func setMessage(msg:String):
	message.text = msg

