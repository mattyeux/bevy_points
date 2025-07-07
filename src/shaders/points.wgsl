#import bevy_sprite::mesh2d_bindings::mesh
#import bevy_sprite::mesh2d_view_bindings::view,
#import bevy_sprite::mesh2d_view_bindings::globals,
#import bevy_sprite::mesh2d_functions::{get_world_from_local, mesh2d_position_local_to_clip, mesh2d_position_local_to_world},


struct PointMaterial {
    point_size: f32,
    opacity: f32,
    color: vec4<f32>,
};

@group(2) @binding(0)
var<uniform> material: PointMaterial;

struct Vertex {
    @builtin(instance_index) instance_index: u32,
    @location(0) position: vec3<f32>,
    @location(1) uv: vec2<f32>,
#ifdef VERTEX_COLORS
    @location(2) color: vec4<f32>,
#endif
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) uv: vec2<f32>,
    @location(1) ndc_center: vec2<f32>,
#ifdef VERTEX_COLORS
    @location(2) color: vec4<f32>,
#endif
};

@vertex
fn vertex(vertex: Vertex) -> VertexOutput {
    var out: VertexOutput;
    let uv = vertex.uv;
    let delta: vec2<f32> = (uv - vec2<f32>(0.5, 0.5)) * material.point_size;
    let world = mesh2d_position_local_to_world(get_world_from_local(vertex.instance_index), vec4<f32>(vertex.position, 1.0));
#ifdef POINT_SIZE_PERSPECTIVE
    var view_position: vec4<f32> = view.view_from_world * world;
    view_position = vec4<f32>(view_position.xy - delta.xy, view_position.zw);
    let clip_position = view.clip_from_view * view_position;
#else
    var clip_position = view.clip_from_world * world;
    let r: f32 = view.viewport.z / view.viewport.w;
    let s: f32 = max(view.viewport.z, view.viewport.w);
    let w: f32 = clip_position.w / s;
    clip_position = vec4<f32>(clip_position.xy - delta * vec2(1.0, r) * w, clip_position.zw);
#endif
    out.clip_position = clip_position;
    out.uv = uv;
    out.ndc_center = clip_position.xy / clip_position.w;
#ifdef VERTEX_COLORS
    out.color = vertex.color;
#endif
    return out;
}

struct FragmentInput {
    @location(0) uv: vec2<f32>,
    @location(1) ndc_center: vec2<f32>,
#ifdef VERTEX_COLORS
    @location(2) color: vec4<f32>,
#endif
};

@fragment
fn fragment(input: FragmentInput) -> @location(0) vec4<f32> {
#ifdef POINT_SHAPE_CIRCLE
    let frag_ndc = input.position.xy / input.position.w;
    // let d: f32 = distance(input.uv, vec2<f32>(0.5, 0.5));
    let d: f32 = distance(input.ndc_center, frag_ndc;
    if d > 0.5 {
        discard;
    }
#endif
#ifdef VERTEX_COLORS
    return material.color * input.color * vec4(1.0, 1.0, 1.0, material.opacity);
#else
    return material.color * vec4(1.0, 1.0, 1.0, material.opacity);
#endif
}
