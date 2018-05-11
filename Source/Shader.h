#pragma once
#include <simd/simd.h>
#include <simd/base.h>
#import "Spirograph/Spirograph.h"

struct TVertex {
    vector_float3 pos;
};

typedef struct {
    matrix_float4x4 mvp;
} Uniforms;
