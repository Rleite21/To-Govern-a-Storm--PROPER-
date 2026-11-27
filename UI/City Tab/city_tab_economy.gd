class_name CityTabEconomy
extends Control

signal closed

# Confirma o caminho e a capitalização (tscn/ui vs tscn/UI) com o ficheiro real
const PIE_SCENE: PackedScene = preload("res://tscn/ui/Pie_Chart.tscn")

# Cor fixa por dono, igual em todos os setores
const OWNER_COLORS := {
	OwnershipEnums.Owner.PEASANTS: Color("8c6d46"),
	OwnershipEnums.Owner.WORKING_CLASS: Color("c0392b"),
	OwnershipEnums.Owner.MIDDLE_CLASS: Color("3498db"),
	OwnershipEnums.Owner.INDUSTRIALISTS: Color("7f8c8d"),
	OwnershipEnums.Owner.ARISTOCRATS: Color("8e44ad"),
	OwnershipEnums.Owner.PUBLIC_COMPANIES: Color("27ae60"),
}

var _city: City
var _ownership_chart: PieChart
var _ownership_title: Label
var _ownership_list: VBoxContainer

@onready var close_button: Button = %CloseButton
@onready var sectors_chart: PieChart = %SectorsChart
@onready var ownership_container: VBoxContainer = %Ownership


func setup(city: City) -> void:
	_city = city


func _ready() -> void:
	close_button.pressed.connect(func(): closed.emit())
	sectors_chart.slice_clicked.connect(_on_sector_clicked)
	_build_ownership_ui()

	if _city == null:
		return

	if _city.economy == null or _city.economy.sectors.is_empty():
		_city.initialize()

	fill_sectors(_city, sectors_chart)
	_show_ownership(_largest_sector())


# Preenche o gráfico dos setores (o key de cada fatia é o Economy.Sector)
static func fill_sectors(city: City, chart: PieChart) -> void:
	if chart == null or city.economy == null:
		return

	var values: Dictionary = {}
	for type in city.economy.sectors:
		var sector: EconomySector = city.economy.sectors[type]
		values[type] = sector.size

	chart.set_values_by_key(values, Economy.display_name, true)


# Limpa o gráfico dos setores
static func clear(chart: PieChart) -> void:
	if chart != null:
		chart.set_values_by_key({}, Economy.display_name)


# Cria uma só vez o título, o gráfico e a lista de ownership dentro do container
func _build_ownership_ui() -> void:
	for child in ownership_container.get_children():
		child.queue_free()

	_ownership_title = Label.new()
	ownership_container.add_child(_ownership_title)

	_ownership_chart = PIE_SCENE.instantiate() as PieChart
	_ownership_chart.custom_minimum_size = Vector2(0, 220)
	_ownership_chart.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ownership_container.add_child(_ownership_chart)

	_ownership_list = VBoxContainer.new()
	ownership_container.add_child(_ownership_list)


# Clique numa fatia (ou na legenda) do gráfico de setores
func _on_sector_clicked(slice: PieSlice, _index: int) -> void:
	_show_ownership(slice.key as Economy.Sector)


# Mostra a ownership de um setor no gráfico e na lista
func _show_ownership(sector_type: int) -> void:
	if _city == null or sector_type < 0:
		return

	var sector: EconomySector = _city.economy.get_sector(sector_type as Economy.Sector)
	if sector == null or sector.ownership.is_empty():
		_ownership_title.text = "Ownership: sem dados"
		_ownership_chart.set_values_by_key({}, OwnershipEnums.display_name)
		_clear_list()
		return

	_ownership_title.text = "Ownership: %s" % Economy.display_name(sector_type as Economy.Sector)

	var values: Dictionary = {}
	for owner in sector.ownership:
		values[owner] = sector.ownership[owner]

	_ownership_chart.set_values_by_key(values, OwnershipEnums.display_name, true)

	# Cores fixas por dono
	for owner in values:
		var slice := _ownership_chart.get_slice_by_key(owner)
		if slice != null:
			slice.color = OWNER_COLORS.get(owner, Color.WHITE)

	_fill_list(sector)


# Lista com o nome e a percentagem de cada dono, do maior para o menor
func _fill_list(sector: EconomySector) -> void:
	_clear_list()

	var owners: Array = sector.ownership.keys()
	owners.sort_custom(func(a, b): return sector.ownership[a] > sector.ownership[b])

	for owner in owners:
		var row := HBoxContainer.new()

		var name_label := Label.new()
		name_label.text = OwnershipEnums.display_name(owner)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		var pct_label := Label.new()
		pct_label.text = "%.1f%%" % (sector.ownership[owner] * 100.0)
		row.add_child(pct_label)

		_ownership_list.add_child(row)


func _clear_list() -> void:
	for child in _ownership_list.get_children():
		child.queue_free()


# Setor com maior tamanho (usado como seleção inicial; -1 se não houver setores)
func _largest_sector() -> int:
	var best := -1
	var best_size := -1.0
	for type in _city.economy.sectors:
		var s: EconomySector = _city.economy.sectors[type]
		if s.size > best_size:
			best_size = s.size
			best = type
	return best
