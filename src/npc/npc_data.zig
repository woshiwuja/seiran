const position = struct { x: f32, y: f32, z: f32 };
const npc_type = enum { player, non_player };
const npc_stats = struct {
    hp: i32,
    speed: f32,
};
const npc_order = enum { walking, running, standing };
const ncp_data = struct { type: npc_type, position: position, stats: npc_stats, order: npc_order };
