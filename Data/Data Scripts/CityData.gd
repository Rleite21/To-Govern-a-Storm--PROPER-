extends Resource
class_name CityData

@export var city_name: String  # Nome da cidade
@export_multiline var description: String  # Texto de apresentação
@export var province_name: String  # Província a que pertence
@export var population: int  # População total
@export var specializations: Array[SectorSpecialization] = []  # Setores especializados e prevalence
@export var density: CityDensity.Level = CityDensity.Level.RURAL  # Nível de urbanização
@export_flags("Cosmopolitan", "Militant", "Rebellious", "Secular", "Intellectual", "Modernist", "Provincial", "Rugged", "Traditional", "Nostalgic", "Clerical", "Communitarian", "Deeply Traditional", "Austere", "Frontier Minded", "Progressive", "Patriotic") var society: int = 0  # Cultural stance (flags)
@export var traits: Array[CityTrait.Type] = []  # Traços (suitability dos setores)
