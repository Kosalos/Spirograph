#include <metal_stdlib>
#include <simd/simd.h>
#import "Shader.h"

using namespace metal;

struct Transfer {
    float4 position [[position]];
    float pointsize [[point_size]];
    float4 color;
};

vertex Transfer texturedVertexShader
(
 constant TVertex *data[[ buffer(0) ]],
 constant Uniforms &uniforms[[ buffer(1) ]],
 unsigned int vid [[ vertex_id ]])
{
    TVertex in = data[vid];
    Transfer out;
    
    out.pointsize = 1;
    out.position = uniforms.mvp * float4(in.pos, 1.0);
    
    float cr = float(vid & 1023) / 1024;
    float cg = float(vid & 511) / 511;
    float cb = float(vid & 255) / 255;
    
    out.color = float4(cr,cg,cb,1);
    return out;
}

fragment float4 texturedFragmentShader
(
 Transfer in [[stage_in]])
{
    return in.color;
}
