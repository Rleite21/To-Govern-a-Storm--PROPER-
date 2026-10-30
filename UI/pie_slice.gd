@tool
class_name PieSlice
extends Resource

## Nome mostrado na legenda/tooltip e usado para atualizar valores por código.
@export var label: String = "Slice":
	set(v):
		label = v
		emit_changed()

@export var value: float = 1.0:
	set(v):
		value = maxf(v, 0.0)
		emit_changed()

## Alpha = 0 significa "usar a cor da palette do gráfico".
@export var color: Color = Color(0, 0, 0, 0):
	set(v):
		color = v
		emit_changed()

## Textura opcional. A cor da fatia multiplica a textura (usa branco para a textura pura).
@export var texture: Texture2D:
	set(v):
		texture = v
		emit_changed()

## Material opcional (ShaderMaterial ou CanvasItemMaterial) só para esta fatia.
@export var material: Material:
	set(v):
		material = v
		emit_changed()

## Afastamento do centro, em fração do raio (0.1 = 10%).
@export_range(0.0, 0.5, 0.01) var explode: float = 0.0:
	set(v):
		explode = v
		emit_changed()
