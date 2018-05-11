#include <metal_stdlib>
#include <simd/simd.h>
#include "Source/Shader.h"

using namespace metal;

float3 rotatePos(float3 old, float2 angle) {
    float3 pos = old;
    
    float qt = pos.x;  // X rotation
    pos.x = pos.x * cos(angle.x) - pos.y * sin(angle.x);
    pos.y = qt * sin(angle.x) + pos.y * cos(angle.x);
    
    qt = pos.x;      // Y rotation
    pos.x = pos.x * cos(angle.y) - pos.z * sin(angle.y);
    pos.z = qt * sin(angle.y) + pos.z * cos(angle.y);
    
    return pos;
}

float addRadian(float angle,float amt) {
    float pi2 = 6.283185;
    
    angle += amt / 30;
    if(angle < 0) angle += pi2; else if(angle >= pi2) angle -= pi2;
    return angle;
}

kernel void calcSpirographShader
(
 device TVertex *vertices           [[ buffer(0) ]],
 constant SpirographControl &ctrl   [[ buffer(1) ]],
 uint p [[thread_position_in_grid]])
{
    if(p >= uint(ctrl.sectionCount)) return;
    
    int vIndex = int(p) * ctrl.pointsPerSection;    // head of our section of vertex storage
    
    float angle[NUMGEAR] = { 0 };
    
    for(int i=0;i<vIndex;++i) {     // advance angles to our section
        for(int j=0;j<NUMGEAR;++j) {
            angle[j] = addRadian(angle[j],ctrl.speed[j]);
        }
    }
    
    for(int i=0;i<ctrl.pointsPerSection;++i) {
        device TVertex &tv = vertices[vIndex++];
        tv.pos = float3();
        
        for(int j=0;j<NUMGEAR;++j) {
            if(ctrl.active[j]) {
                float cc = cos(angle[j]) * ctrl.radius[j];
                float ss = sin(angle[j]) * ctrl.radius[j];
                angle[j] = addRadian(angle[j],ctrl.speed[j]);
                
                float3 pt = float3(cc,ss,0);
                float2 rot = float2(ctrl.currentAngleX[j],ctrl.currentAngleY[j]);
                tv.pos += rotatePos(pt,rot);
            }
        }
    }
}
