extends MarginContainer

onready var name_label: Label = find_node("Name")
onready var background: PanelContainer = find_node("Background")
onready var picture: TextureRect = find_node("Picture")
onready var amount_bar: ProgressBar = find_node("AmountBar")
onready var amount_label: Label = find_node("AmountLabel")


func init(data: Dictionary) -> void:
	name_label.text = data[EnemyManager.NAME]
	var rarity = data[EnemyManager.RARITY]
	background.self_modulate = Global.COLORS[rarity]
	amount_bar.max_value = data[EnemyManager.SPAWNED]
	amount_bar.value = data[EnemyManager.DESTROYED]
	amount_label.text = "%d/%d" % [data[EnemyManager.DESTROYED], data[EnemyManager.SPAWNED]]
	
	# define texture position in atlas by its index
	var atlas_width = 5
	var texture_size = picture.texture.region.size
	var index = data[EnemyManager.FRAME]
	var row = index / atlas_width
	var column = index % atlas_width
	var texture_position = Vector2(column, row) * texture_size
	picture.texture.region.position = texture_position
