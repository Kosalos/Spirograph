#pragma once
#include <simd/simd.h>

#define PI2 (3.1415926 * 2.0)
#define NUMGEAR 4

struct Counter {
    int count;
};

typedef struct {
    int version;
    
    int sectionCount;     // spirograph split into this many pieces for shader
    int pointsPerSection;
    
    float currentAngleX[NUMGEAR];
    float currentAngleY[NUMGEAR];

    int   active[NUMGEAR];
    float radius[NUMGEAR];
    float speed[NUMGEAR];
    float rotateX[NUMGEAR];
    float rotateY[NUMGEAR];

} SpirographControl;

// Swift access to arrays in SpirographControl
#ifndef __METAL_VERSION__

void setActive(SpirographControl *s,int index, int onoff);
int getActive(SpirographControl *s,int index);

float* radiusPointer(SpirographControl *s,int index);
float* speedPointer(SpirographControl *s,int index);
float* rotateXPointer(SpirographControl *s,int index);
float* rotateYPointer(SpirographControl *s,int index);

void resetSpirograph(SpirographControl *s);
void updateRotationAngles(SpirographControl *s);
void harmonize(SpirographControl *s,int index);

#endif
