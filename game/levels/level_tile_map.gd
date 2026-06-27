class_name LevelTileMap extends TileMapLayer

const CLIMBABLE_CUSTOM_DATA: StringName = &"climbable"
const COVERED_TILE_SEARCH_RADIUS: int = 4
const COVERED_TILE_RECT_PADDING: float = 0.1


func is_climbable_at_world_position(world_position: Vector2) -> bool:
	return _get_climbable_tile_origin_at_world_position(world_position) != Vector2i(-1, -1)


func get_climb_tile_center_at_world_position(world_position: Vector2) -> Vector2:
	var tile_origin: Vector2i = _get_climbable_tile_origin_at_world_position(world_position)
	if tile_origin == Vector2i(-1, -1):
		return world_position

	return to_global(map_to_local(tile_origin))


func _get_climbable_tile_origin_at_world_position(world_position: Vector2) -> Vector2i:
	var local_position: Vector2 = to_local(world_position)
	var map_position: Vector2i = local_to_map(local_position)

	for y_offset: int in range(-COVERED_TILE_SEARCH_RADIUS, COVERED_TILE_SEARCH_RADIUS + 1):
		for x_offset: int in range(-COVERED_TILE_SEARCH_RADIUS, COVERED_TILE_SEARCH_RADIUS + 1):
			var tile_origin: Vector2i = map_position + Vector2i(x_offset, y_offset)
			if _is_climbable_tile_covering_local_position(tile_origin, local_position):
				return tile_origin

	return Vector2i(-1, -1)


func _is_climbable_tile_covering_local_position(tile_origin: Vector2i, local_position: Vector2) -> bool:
	var tile_data: TileData = get_cell_tile_data(tile_origin)
	if tile_data == null or tile_data.get_custom_data(CLIMBABLE_CUSTOM_DATA) != true:
		return false

	var atlas_source: TileSetAtlasSource = _get_cell_atlas_source(tile_origin)
	if atlas_source == null:
		return false

	var atlas_coords: Vector2i = get_cell_atlas_coords(tile_origin)
	var atlas_tile_size: Vector2i = atlas_source.get_tile_size_in_atlas(atlas_coords)
	var base_tile_size: Vector2i = tile_set.tile_size
	var covered_size: Vector2 = Vector2(
		float(base_tile_size.x * atlas_tile_size.x),
		float(base_tile_size.y * atlas_tile_size.y)
	)
	var tile_center: Vector2 = map_to_local(tile_origin)
	var covered_rect: Rect2 = Rect2(tile_center - (covered_size * 0.5), covered_size)
	return covered_rect.grow(COVERED_TILE_RECT_PADDING).has_point(local_position)


func _get_cell_atlas_source(tile_origin: Vector2i) -> TileSetAtlasSource:
	var source_id: int = get_cell_source_id(tile_origin)
	if source_id == -1:
		return null

	return tile_set.get_source(source_id) as TileSetAtlasSource
