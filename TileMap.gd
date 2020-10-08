extends Node2D

onready var cell 
onready var tile_id
onready var tilemap = $Tilemap
onready var crackmap = $CrackMap
onready var effects = load("res://scenes/Effects.tscn")

onready var parent = get_parent()
onready var character = parent.get_node("Character")



func _ready():
	set_process(true)


func _process(delta):
	pass


func _on_Character_collided(collision):
	
	if collision.collider is TileMap:
		
		var tiles = collision.collider
		
		var tile_pos = collision.collider.world_to_map(character.position)
		tile_pos -= collision.normal 
		var tile = collision.collider.get_cellv(tile_pos)
		
		var right = tile_pos + Vector2(1,0)
		var left = tile_pos + Vector2(-1,0)
		var up = tile_pos + Vector2(0,-1)
		var down = tile_pos + Vector2(0,1)

		#BREAK CHAIN
		if tile == 0:
			break_chain(tile_pos, 0.05, tiles, tile)

		#CRACK BLOCK 1
		if tile == 1:	
			crack_tile(tile_pos, tile, 0.1)
		
		#BREAKABLE PLATAFORM
		if tile == 2:
			break_plataform(tile_pos, 0.1, tiles, tile)
		
		#UNBREAKABLE TILE
		if tile == 3:
			pass
		
		if tile == 4:	
			crack_tile(tile_pos, tile, 0.1)
		
		
		#BREACK INSTANTLY
func break_plataform(tile_position, time, tiles, tile_type):
	
	
	var r = tile_position + Vector2(1,0)
	var l = tile_position + Vector2(-1,0)
	var u = tile_position + Vector2(0,-1)
	var d = tile_position + Vector2(0,1)
	
	if crackmap.get_cellv(tile_position) == -1:
		
		#INSTANCE OF BLOCK EFFECTS


		crackmap.set_cellv(tile_position, 1)
		
		if crackmap.get_cellv(r) == -1:
			if tiles.get_cellv(r) == tile_type:
				break_plataform(r, 0.1, tiles, tile_type)
		if crackmap.get_cellv(l) == -1:
			if tiles.get_cellv(l) == tile_type:	
				break_plataform(l, 0.1, tiles, tile_type)
		if crackmap.get_cellv(d) == -1:
			if tiles.get_cellv(d) == tile_type:
				break_plataform(d, 0.1, tiles, tile_type)
		if crackmap.get_cellv(u) == -1:
			if tiles.get_cellv(u) == tile_type:
				break_plataform(u, 0.1, tiles, tile_type)
		
		
		yield(get_tree().create_timer(time), "timeout")
		crackmap.set_cellv(tile_position, 3)
		yield(get_tree().create_timer(time), "timeout")
		crackmap.set_cellv(tile_position, -1)
		tilemap.set_cellv(tile_position, -1)
	
		
	#BREAKING BLOCK CHAIN
func break_chain(tile_position, time, tiles, tile_type):
	if crackmap.get_cellv(tile_position) == -1:

		var r = tile_position + Vector2(1,0)
		var l = tile_position + Vector2(-1,0)
		var u = tile_position + Vector2(0,-1)
		var d = tile_position + Vector2(0,1)

		crackmap.set_cellv(tile_position, 0)
		yield(get_tree().create_timer(time), "timeout")
		
		#DOMINO EFFECT
		if tiles.get_cellv(d) == tile_type:
			break_chain(d, time, tiles, tile_type)
		if tiles.get_cellv(u) == tile_type:
			break_chain(u, time, tiles, tile_type)
		if tiles.get_cellv(l) == tile_type:
			break_chain(l, time, tiles, tile_type)
		if tiles.get_cellv(r) == tile_type:
			break_chain(r, time, tiles, tile_type)

		crackmap.set_cellv(tile_position, 1)
		yield(get_tree().create_timer(time), "timeout")
		crackmap.set_cellv(tile_position, 2)
		yield(get_tree().create_timer(time), "timeout")
		crackmap.set_cellv(tile_position, 3)
		yield(get_tree().create_timer(time), "timeout")
		crackmap.set_cellv(tile_position, -1)
		tilemap.set_cellv(tile_position, -1)
		
	
	#CRACKING TILES	
func crack_tile(tile_position, tile, time):
	
	var breakable = false if tile == 1 else true
	
	if tilemap.get_cellv(tile_position) == -1:
		crackmap.set_cellv(tile_position, -1)
		
	elif crackmap.get_cellv(tile_position) == -1:
		crackmap.set_cellv(tile_position, 0)
		yield(get_tree().create_timer(time), "timeout")
		crackmap.set_cellv(tile_position, 1)
		yield(get_tree().create_timer(time), "timeout")
		crackmap.set_cellv(tile_position, 2)
		yield(get_tree().create_timer(time), "timeout")
		crackmap.set_cellv(tile_position, 3)
		yield(get_tree().create_timer(time), "timeout")
		if breakable == false:
			crackmap.set_cellv(tile_position, -1)
			tilemap.set_cellv(tile_position, 4)
		if breakable == true:
			crackmap.set_cellv(tile_position, -1)
			tilemap.set_cellv(tile_position, -1)

	#NOT AFFECTED
func unbreakable_tile(tile_position):
	crackmap.set_cellv(tile_position, 0)
	
	
