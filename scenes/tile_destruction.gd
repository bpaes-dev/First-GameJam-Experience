extends Node2D

var cell
var tile_id
var colider



onready var parent = get_parent()
onready var tilemap = parent.get_parent()


func _ready():
	tilemap = tilemap.get_node("TileMap")
	colider = parent.get_node("shape")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
