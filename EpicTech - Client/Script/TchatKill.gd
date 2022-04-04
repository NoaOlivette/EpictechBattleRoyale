extends HBoxContainer

onready var shooter:Label = $Shooter
onready var victim:Label = $Victim

func setShooter(pseudo:String):
	shooter.text = pseudo

func setVictim(pseudo:String):
	victim.text = pseudo

