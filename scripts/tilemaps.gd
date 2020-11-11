extends TileMap

func _ready():
	add_group_tilemaps()

func add_group_tilemaps():
	self.add_to_group("tilemaps")
