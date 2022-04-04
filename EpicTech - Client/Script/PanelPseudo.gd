extends Control

onready var labelPseudo:Label = $LabelPseudo

func setPseudo(pseudo:String):
	labelPseudo.text = pseudo
