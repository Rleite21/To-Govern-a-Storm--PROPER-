class_name SectorSpecialization
extends Resource

@export var sector: Economy.Sector  # Setor especializado
@export_range(1.0, 5.0, 0.05) var prevalence: float = 2.0  # Multiplicador do tamanho potencial
