class_name LevelTileMap extends Node2D

class ClimbTileEntry:
	var tile_origin: Vector2i
	var covered_rect: Rect2
	var center: Vector2

const CLIMBABLE_CUSTOM_DATA: StringName = &"climbable"
const COVERED_TILE_RECT_PADDING: float = 0.1

@export var tile_map_layers: Array[TileMapLayer]

var _climb_cache: Dictionary[TileMapLayer, Dictionary] = {}


func _ready() -> void:
	rebuild_climb_cache()


func rebuild_climb_cache() -> void:
	_climb_cache.clear()

	for tile_map_layer: TileMapLayer in tile_map_layers:
		if tile_map_layer == null:
			continue

		var layer_cache: Dictionary[Vector2i, Array] = {}
		for tile_origin: Vector2i in tile_map_layer.get_used_cells():
			var climb_entry: ClimbTileEntry = _build_climb_tile_entry(tile_map_layer, tile_origin)
			if climb_entry != null:
				_store_climb_entry(tile_map_layer, layer_cache, climb_entry)

		_climb_cache[tile_map_layer] = layer_cache


func is_climbable_at_world_position(world_position: Vector2) -> bool:
	for tile_map_layer: TileMapLayer in tile_map_layers:
		if tile_map_layer == null:
			continue
		if _get_cached_climb_entry_at_world_position(tile_map_layer, world_position) != null:
			return true

	return false


func get_climb_tile_center_at_world_position(world_position: Vector2) -> Vector2:
	for tile_map_layer: TileMapLayer in tile_map_layers:
		if tile_map_layer == null:
			continue

		var climb_entry: ClimbTileEntry = _get_cached_climb_entry_at_world_position(tile_map_layer, world_position)
		if climb_entry != null:
			return tile_map_layer.to_global(climb_entry.center)

	return world_position


func _build_climb_tile_entry(tile_map_layer: TileMapLayer, tile_origin: Vector2i) -> ClimbTileEntry:
	var tile_data: TileData = tile_map_layer.get_cell_tile_data(tile_origin)
	if tile_data == null or tile_data.get_custom_data(CLIMBABLE_CUSTOM_DATA) != true:
		return null

	var atlas_source: TileSetAtlasSource = _get_cell_atlas_source(tile_map_layer, tile_origin)
	if atlas_source == null:
		return null

	var atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(tile_origin)
	var atlas_tile_size: Vector2i = atlas_source.get_tile_size_in_atlas(atlas_coords)
	var base_tile_size: Vector2i = tile_map_layer.tile_set.tile_size
	var covered_size: Vector2 = Vector2(
		float(base_tile_size.x * atlas_tile_size.x),
		float(base_tile_size.y * atlas_tile_size.y)
	)
	var tile_center: Vector2 = tile_map_layer.map_to_local(tile_origin)

	var climb_entry: ClimbTileEntry = ClimbTileEntry.new()
	climb_entry.tile_origin = tile_origin
	climb_entry.covered_rect = Rect2(tile_center - (covered_size * 0.5), covered_size).grow(COVERED_TILE_RECT_PADDING)
	climb_entry.center = tile_center
	return climb_entry


func _store_climb_entry(
	tile_map_layer: TileMapLayer,
	layer_cache: Dictionary[Vector2i, Array],
	climb_entry: ClimbTileEntry
) -> void:
	var bucket_min: Vector2i = tile_map_layer.local_to_map(climb_entry.covered_rect.position)
	var bucket_max: Vector2i = tile_map_layer.local_to_map(climb_entry.covered_rect.end)

	for y: int in range(bucket_min.y, bucket_max.y + 1):
		for x: int in range(bucket_min.x, bucket_max.x + 1):
			var bucket_position: Vector2i = Vector2i(x, y)
			if not layer_cache.has(bucket_position):
				layer_cache[bucket_position] = []

			layer_cache[bucket_position].append(climb_entry)


func _get_cached_climb_entry_at_world_position(
	tile_map_layer: TileMapLayer,
	world_position: Vector2
) -> ClimbTileEntry:
	var layer_cache: Dictionary = _climb_cache.get(tile_map_layer, {})
	if layer_cache.is_empty():
		return null

	var local_position: Vector2 = tile_map_layer.to_local(world_position)
	var map_position: Vector2i = tile_map_layer.local_to_map(local_position)
	var climb_entries: Array = layer_cache.get(map_position, [])
	for climb_entry: ClimbTileEntry in climb_entries:
		if climb_entry.covered_rect.has_point(local_position):
			return climb_entry

	return null


func _get_cell_atlas_source(tile_map_layer: TileMapLayer, tile_origin: Vector2i) -> TileSetAtlasSource:
	if tile_map_layer.tile_set == null:
		return null

	var source_id: int = tile_map_layer.get_cell_source_id(tile_origin)
	if source_id == -1:
		return null

	return tile_map_layer.tile_set.get_source(source_id) as TileSetAtlasSource
