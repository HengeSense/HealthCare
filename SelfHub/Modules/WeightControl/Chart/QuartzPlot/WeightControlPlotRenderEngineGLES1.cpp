//
//  WeightControlPlotRenderInterface.cpp
//  SelfHub
//
//  Created by Eugine Korobovsky on 08.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
#include <math.h>
#include "WeightControlPlotRenderEngine.h"
#include "Vector.hpp"

#define DEFAULT_ANIMATION_DURATION 2.5

#pragma mark - Helper structs and routines

struct AnimatedFloat {
    float startPos;
    float endPos;
    float curPos;
    
    float elapsedTime;
    float duration;
    
    void SetNotAnimatedValue(float value) {
        startPos = endPos = curPos = value;
        elapsedTime = duration = 0.0;
    };
    void SetAnimatedValue(float value, float animationDuration){
        startPos = endPos;
        endPos = value;
        elapsedTime = 0.0;
        duration = animationDuration;
    };
    void SetCurStateForTimeLinear(float timeStep){
        elapsedTime += timeStep;
        if(elapsedTime >= duration){
            curPos = endPos;
            return;
        };
        
        float animationCompletionPercent = elapsedTime / duration;
        curPos = animationCompletionPercent * endPos + (1-animationCompletionPercent)*startPos;
        
    };
    void SetCurStateForTimeEaseIn(float timeStep){
        
    };
    void SetCurStateForTimeEaseOut(float timeStep){
        
    };
    void SetCurStateForTimeEaseInOut(float timeStep){
        
    };
    bool isAnimationFinished(){
        return fabs(curPos-endPos)<0.00001 ? true : false;
    };
};


#pragma mark - Main Render Engine Realization (via OpenGL ES 1.1)

class WeightControlPlotRenderEngineGLES1 : public WeightControlPlotRenderEngine {
public:
    WeightControlPlotRenderEngineGLES1();
    void Initialize(int width, int height);
    
    void SetDataArray(std::vector<WeightControlDataRecord> _dataArray);
    void SetYAxisParams(float _minWeight, float _maxWeight, float _weightLinesStep, bool isAnimate);
    void SetXAxisParams(float _timeDimension);
    
    void Render() const;
    void UpdateAnimation(float timeStep);
    
private:
    std::vector<WeightControlDataRecord> plotData;
    AnimatedFloat minWeight, maxWeight, weightLinesStep;
    float timeDimension;
    
    GLuint framebuffer;
    GLuint renderbuffer;
};

WeightControlPlotRenderEngine *CreateRendererForGLES1(){
    return new WeightControlPlotRenderEngineGLES1();
}

WeightControlPlotRenderEngineGLES1::WeightControlPlotRenderEngineGLES1(){
    glGenRenderbuffersOES(1, &renderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
};

void WeightControlPlotRenderEngineGLES1::Initialize(int width, int height){
    glGenFramebuffersOES(1, &framebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderbuffer);
    
    glViewport(0, 0, width, height);
    
    glMatrixMode(GL_PROJECTION);
    glOrthof(-10.0, +10.0, -10.0, +10.0, -1.0, +1.0);
    
};

void WeightControlPlotRenderEngineGLES1::SetDataArray(std::vector<WeightControlDataRecord> _dataArray){
    plotData.clear();
    plotData = _dataArray;
};

void WeightControlPlotRenderEngineGLES1::SetYAxisParams(float _minWeight, float _maxWeight, float _weightLinesStep, bool isAnimate){
    if(isAnimate){
        minWeight.SetAnimatedValue(_minWeight, DEFAULT_ANIMATION_DURATION);
        maxWeight.SetAnimatedValue(_maxWeight, DEFAULT_ANIMATION_DURATION);
        weightLinesStep.SetAnimatedValue(_weightLinesStep, DEFAULT_ANIMATION_DURATION);
    }else{
        minWeight.SetNotAnimatedValue(_minWeight);
        maxWeight.SetNotAnimatedValue(_maxWeight);
        weightLinesStep.SetNotAnimatedValue(_weightLinesStep);
    };
};

void WeightControlPlotRenderEngineGLES1::SetXAxisParams(float _timeDimension){
    timeDimension = _timeDimension;
};

void WeightControlPlotRenderEngineGLES1::UpdateAnimation(float timeStep){
    //Animate min weight parameter
    minWeight.SetCurStateForTimeLinear(timeStep);
    maxWeight.SetCurStateForTimeLinear(timeStep);
    weightLinesStep.SetCurStateForTimeLinear(timeStep);
};

void WeightControlPlotRenderEngineGLES1::Render() const {
    glClearColor(1.0f, 1.0f, 1.0f, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    //Setting horizontal lines color
    GLfloat colors[][4] = { {0, 0, 0, 1}, {0, 0, 0, 1} };
    glColorPointer(4, GL_FLOAT, 4*sizeof(GLfloat), &colors[0]);
    
    //std::cout<<"**********************************\n";
    std::vector<vec2> horizontalLines;
    horizontalLines.clear();
    float i_float;
    vec2 curPoint;
    int curPointI = 0;
    for(i_float = minWeight.curPos; i_float<maxWeight.curPos; i_float+=weightLinesStep.curPos){
        curPoint.x = -10.0;
        curPoint.y = -10.0 + (20.0*(i_float-minWeight.curPos))/(maxWeight.curPos - minWeight.curPos);
        horizontalLines.push_back(curPoint);
        //std::cout<<"["<<curPoint.x<<", "<<curPoint.y<<"] -> ";
        curPoint.x = +10.0;
        horizontalLines.push_back(curPoint);
        //std::cout<<"["<<curPoint.x<<", "<<curPoint.y<<"]\n";
        
        glVertexPointer(2, GL_FLOAT,  sizeof(vec2), &horizontalLines[curPointI].x);
        glDrawArrays(GL_LINES, 0, 2);
        //horizontalLines.pop_back();
        //horizontalLines.pop_back();
        curPointI+=2;
    };
    
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);

};