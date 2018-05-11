#import "Spirograph.h"

void setActive(SpirographControl *s,int index, int onoff) { s->active[index] = onoff; }
int getActive(SpirographControl *s,int index) { return s->active[index]; }

float* radiusPointer (SpirographControl *s,int index) { return &(s->radius[index]); }
float* speedPointer  (SpirographControl *s,int index) { return &(s->speed[index]); }
float* rotateXPointer(SpirographControl *s,int index) { return &(s->rotateX[index]); }
float* rotateYPointer(SpirographControl *s,int index) { return &(s->rotateY[index]); }

void resetSpirograph(SpirographControl *s) {
    for(int i=0;i<NUMGEAR;++i) {
        _Bool firstGear = (i == 0);
        
        s->active[i] = firstGear;
        s->radius[i] = firstGear ? 10 : 0;
        s->speed[i] = firstGear ? 10 : 0;
        s->currentAngleX[i] = 0;
        s->currentAngleY[i] = 0;
        s->rotateX[i] = 0;
        s->rotateY[i] = 0;
    }
}

float harmonizeValue(float input) {
    int den = 1200;
    int i = ((int)(input * 1000) / den) * den;
    return (float)i / 1000;
}

float addRadian(float angle,float amt) {
    static float pi2 = 6.283185;
    angle += amt / 20000;    // slow down rotation change
    if(angle < 0) angle += pi2; else if(angle >= pi2) angle -= pi2;
    return angle;
}

void updateRotationAngles(SpirographControl *s) {
    for(int i=0;i<NUMGEAR;++i) {
        s->currentAngleX[i] = addRadian(s->currentAngleX[i], s->rotateX[i]);
        s->currentAngleY[i] = addRadian(s->currentAngleY[i], s->rotateY[i]);
    }
}

void harmonize(SpirographControl *s,int index) {
    s->radius[index] = harmonizeValue(s->radius[index]);
    s->speed[index] = harmonizeValue(s->speed[index]);
    s->rotateX[index] = harmonizeValue(s->rotateX[index]);
    s->rotateY[index] = harmonizeValue(s->rotateY[index]);
}

