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

#define DEFAULT_ANIMATION_DURATION 1.0
#define FLOAT_EPSILON 0.00001

#pragma mark - Helper structs and routines

enum AnimationType{
    AnimationTypeLinear = 0,
    AnimationTypeEaseIn = 1,
    AnimationTypeEaseOut = 2,
    AnimationTypeEaseInOut = 3,
    AnimationTypeSuperOut = 4
};

struct AnimatedFloat {
    float startPos;
    float endPos;
    float curPos;
    AnimationType type;
    
    float elapsedTime;
    float duration;
    
    void SetNotAnimatedValue(float value) {
        type = AnimationTypeLinear;
        startPos = endPos = curPos = value;
        elapsedTime = duration = 0.0;
    };
    void SetAnimatedValue(float value, float animationDuration, AnimationType _type){
        type = _type;
        startPos = curPos;
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
        elapsedTime += timeStep;
        if(elapsedTime >= duration){
            curPos = endPos;
            return;
        };
        
        float animationCompletionPercent = elapsedTime / duration;
        animationCompletionPercent *= animationCompletionPercent;
        curPos = animationCompletionPercent * endPos + (1-animationCompletionPercent)*startPos;
    };
    void SetCurStateForTimeEaseOut(float timeStep){
        elapsedTime += timeStep;
        if(elapsedTime >= duration){
            curPos = endPos;
            return;
        };
        
        float delta = curPos;
        float animationCompletionPercent = elapsedTime / duration;
        float middlePos = (startPos + endPos) / 2;
        
        float t = animationCompletionPercent * 2.0;
        if(t <= 1){
            //t *= t;
            curPos = t * middlePos + (1-t) * startPos;
        }else{
            t -= 1.0;
            t *= t;
            curPos = t * endPos + (1-t)*middlePos;
        };
        delta -= curPos;
        printf("Completion percent %.0f: %.2f\n", animationCompletionPercent*100.0, delta);
    };
    void SetCurStateForTimeSuperOut(float timeStep){
        elapsedTime += timeStep;
        if(elapsedTime >= duration){
            curPos = endPos;
            return;
        };
        
        float animationCompletionPercent = elapsedTime / duration;
        float middlePos = (startPos + endPos) / 2;
        
        float t = animationCompletionPercent * 2.0;
        if(t <= 1){
            curPos = animationCompletionPercent * endPos + (1-animationCompletionPercent)*startPos;
        }else{
            animationCompletionPercent = pow(animationCompletionPercent, 5.0);
            curPos = animationCompletionPercent * endPos + (1-animationCompletionPercent)*middlePos;
        };
        printf("%.2f, ", curPos);
    };

    void SetCurStateForTimeEaseInOut(float timeStep){
        elapsedTime += timeStep;
        if(elapsedTime >= duration){
            curPos = endPos;
            return;
        };
        
        float animationCompletionPercent = elapsedTime / duration;
        float middlePos = (startPos + endPos) / 2;
        
        float t = animationCompletionPercent * 2.0;
        if(t <= 1){
            curPos = t * t * middlePos + (1-animationCompletionPercent)*startPos;
        }else{
            t -= 1.0;
            curPos = t * t * endPos + (1-animationCompletionPercent)*middlePos;
        };

    };
    
    void UpdateAnimation(float timeStep){
        switch (type) {
            case AnimationTypeLinear:
                SetCurStateForTimeLinear(timeStep);
                break;
            case AnimationTypeEaseIn:
                SetCurStateForTimeEaseIn(timeStep);
                break;
            case AnimationTypeEaseOut:
                SetCurStateForTimeEaseOut(timeStep);
                break;
            case AnimationTypeEaseInOut:
                SetCurStateForTimeEaseInOut(timeStep);
                break;
            case AnimationTypeSuperOut:
                SetCurStateForTimeSuperOut(timeStep);
                break;
                
                
            default:
                SetCurStateForTimeLinear(timeStep);
                break;
        };
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
    
    void SetYAxisParams(float _minWeight, float _maxWeight, float _weightLinesStep, float animationDuration = 0.0);
    void UpdateYAxisParamsForOffsetAndScale(float _xOffset, float _xScale, float animationDuration = 0.0);
    void SetXAxisParams(float _startTimeInt, float _finishTimeInt);
    
    void SetScaleX(float _scaleX, float animationDuration = 0.0);
    void SetScaleY(float _scaleY, float animationDuration = 0.0);
    
    void SetOffsetTimeInterval(float _xOffset, float animationDuration = 0.0);
    void SetOffsetPixels(float _xOffsetPx, float animationDuration = 0.0);
    void SmoothPanFinish(float finishVelocity);
    
    float getCurScaleX();
    float getCurScaleY();
    float getCurOffsetX();
    float getCurOffsetXForScale(float _aimXScale);
    float getTimeIntervalPerPixel() const;
    float getTimeIntervalPerPixelForScale(float _aimXScale);
    
    float GetXForTimeInterval(float _timeInterval) const;
    float GetYForWeight(float _weight) const;
    
    void SetDataBase(std::list<WeightControlDataRecord> _base);
    void ClearDataBase();
    void SetDataRecord(WeightControlDataRecord _record, unsigned int _pos);
    void InsertDataRecord(WeightControlDataRecord _record, unsigned int _pos);
    void DeleteDataRecord(unsigned int _pos);
    
    void Render() const;
    void UpdateAnimation(float timeStep);
    
private:
    float minX, maxX, minY, maxY;
    int viewPortWidth, viewPortHeight;
    AnimatedFloat xScale, yScale;
    
    std::list<WeightControlDataRecord> plotData;
    
    AnimatedFloat minWeight, maxWeight, weightLinesStep;
    
    AnimatedFloat xAxisOffset;
    float startTimeInt, finishTimeInt;

    GLuint framebuffer;
    GLuint renderbuffer;
    
    void DrawCircle(vec2 center, float r, unsigned int segments, vec4 circleColor, bool isFill, vec4 fillColor) const;
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
    viewPortWidth = width;
    viewPortHeight = height;
    
    glMatrixMode(GL_PROJECTION);
    minX = -10.0;
    maxX = 10.0;
    minY = -10.0;
    maxY = 10.0;
    glOrthof(minX, maxX, minY, maxY, -1.0, +1.0);
    
    xScale.SetNotAnimatedValue(1.0);
    yScale.SetNotAnimatedValue(1.0);
    xAxisOffset.SetNotAnimatedValue(0.0);
};

void WeightControlPlotRenderEngineGLES1::SetYAxisParams(float _minWeight, float _maxWeight, float _weightLinesStep, float animationDuration){
    if(fabs(animationDuration)>FLOAT_EPSILON){
        minWeight.SetAnimatedValue(_minWeight, animationDuration, AnimationTypeLinear);
        maxWeight.SetAnimatedValue(_maxWeight, animationDuration, AnimationTypeLinear);
        weightLinesStep.SetNotAnimatedValue(_weightLinesStep);
    }else{
        minWeight.SetNotAnimatedValue(_minWeight);
        maxWeight.SetNotAnimatedValue(_maxWeight);
        weightLinesStep.SetNotAnimatedValue(_weightLinesStep);
    };
};

void WeightControlPlotRenderEngineGLES1::UpdateYAxisParamsForOffsetAndScale(float _xOffset, float _xScale, float animationDuration){
    float showStartOffsetPt = (((_xScale - 1) * (maxX - minX)) / 2.0) / _xScale;
    float tiPerPx = ((finishTimeInt - startTimeInt) / (viewPortWidth)) / _xScale;
    float pointsOffset = showStartOffsetPt - ((_xOffset * tiPerPx * (maxX - minX)) / (finishTimeInt - startTimeInt)) / _xScale;
    //printf("Offset: [Pt=%.2f, Px=%.2f, ti=%.0f] | Scale: %.4f | animDur: %.3f s | ", pointsOffset, _xOffset, _xOffset * tiPerPx, _xScale, animationDuration);
    
    
    float testedBlockStartTimeInterval = startTimeInt + tiPerPx * _xOffset;
    float testedBlockEndTimeInterval = testedBlockStartTimeInterval + (finishTimeInt-startTimeInt) / _xScale;
    //printf("testedBlockInterval: %.1f days | ", (testedBlockEndTimeInterval-testedBlockStartTimeInterval) / (60.0*60.0*24.0));
    
    std::list<WeightControlDataRecord>::const_iterator plotDataIterator;
    float minValue = MAXFLOAT, maxValue = 0.0;
    float curMinValue = MAXFLOAT, curMaxValue = 0.0;
    float curTimeInterval, curWeight, curTrend;
    bool isFirstPoint = true;
    for(plotDataIterator=plotData.begin(); plotDataIterator!=plotData.end(); plotDataIterator++){
        curTimeInterval = (*plotDataIterator).timeInterval;
        curTrend = (*plotDataIterator).trend;
        curWeight = (*plotDataIterator).weight;
        
        if(curTimeInterval>=testedBlockStartTimeInterval && curTimeInterval<=testedBlockEndTimeInterval){            
            if(isFirstPoint && plotDataIterator!=plotData.begin()){
                plotDataIterator--;
                float lastTrend = (*plotDataIterator).trend;
                float lastWeight = (*plotDataIterator).weight;
                float lastTimeInterval = (*plotDataIterator).timeInterval;
                //plotDataIterator++;       // ! It's don't need to increment iterator, because we should review first point after intermediate point
                
                //printf("first: [w=%.3f, t=%.3f] -> ", curWeight, curTrend);
                curTrend = lastTrend + ((testedBlockStartTimeInterval-lastTimeInterval)*(curTrend-lastTrend))/(curTimeInterval-lastTimeInterval);
                curWeight = lastWeight + ((testedBlockStartTimeInterval-lastTimeInterval)*(curWeight-lastWeight))/(curTimeInterval-lastTimeInterval);
                //printf("[w=%.3f, t=%.3f] | ", curWeight, curTrend);
                
                isFirstPoint = false;
            }else{
                curTrend = (*plotDataIterator).trend;
                curWeight = (*plotDataIterator).weight;
            };
            
            
            if(curWeight<curTrend){
                curMinValue = curWeight;
                curMaxValue = curTrend;
            }else{
                curMinValue = curTrend;
                curMaxValue = curWeight;
            };
            if(curMinValue<minValue) minValue = curMinValue;
            if(curMaxValue>maxValue) maxValue = curMaxValue;
        };
        
        if(curTimeInterval>testedBlockEndTimeInterval){
            //is last point
            if(plotDataIterator!=plotData.begin()){
                plotDataIterator--;
                float lastTrend = (*plotDataIterator).trend;
                float lastWeight = (*plotDataIterator).weight;
                float lastTimeInterval = (*plotDataIterator).timeInterval;
                plotDataIterator++;
                
                //printf("last: [w=%.3f, t=%.3f] -> ", curWeight, curTrend);
                curTrend = lastTrend + ((testedBlockEndTimeInterval-lastTimeInterval)*(curTrend-lastTrend))/(curTimeInterval-lastTimeInterval);
                curWeight = lastWeight + ((testedBlockEndTimeInterval-lastTimeInterval)*(curWeight-lastWeight))/(curTimeInterval-lastTimeInterval);
                //printf("[w=%.3f, t=%.3f] | ", curWeight, curTrend);
                
                if(curWeight<curTrend){
                    curMinValue = curWeight;
                    curMaxValue = curTrend;
                }else{
                    curMinValue = curTrend;
                    curMaxValue = curWeight;
                };
                if(curMinValue<minValue) minValue = curMinValue;
                if(curMaxValue>maxValue) maxValue = curMaxValue;
                
            }
            
            break;
        };
    };
    
    float diff = maxValue - minValue;
    
    //float extensionWeightRange = (maxValue - minValue)*0.3;
    //minValue -= extensionWeightRange;
    //maxValue += extensionWeightRange;
    
    float newMinWeight, newMaxWeight;
    
    float  myWeightLinesStep = .1;
    if(diff>1.0 && diff<=4.0) myWeightLinesStep = 0.5;
    if(diff>4.0 && diff<=10.0) myWeightLinesStep = 1.0;
    if(diff>10.0 && diff<=20.0) myWeightLinesStep = 2.5;
    if(diff>20.0 && diff<=40.0) myWeightLinesStep = 5.0;
    if(diff>40) myWeightLinesStep = 10.0;
    
    
    newMinWeight = minValue; //(fabs(minWeight.curPos-minValue) > diff*0.1) ? minValue : minWeight.curPos;
    newMaxWeight = maxValue; //(fabs(maxValue-maxWeight.curPos) > diff*0.1) ? maxValue : maxWeight.curPos;
    
    
    //printf("UpdateYAxisParams: minValue = %.3f, maxValue = %.3f, interval = %.1f (from %.0f ti to %.0f ti)\n", newMinWeight, newMaxWeight, myWeightLinesStep, testedBlockStartTimeInterval, testedBlockEndTimeInterval);
    SetYAxisParams(newMinWeight, newMaxWeight, myWeightLinesStep, animationDuration);
};

void WeightControlPlotRenderEngineGLES1::SetXAxisParams(float _startTimeInt, float _finishTimeInt){
    startTimeInt = _startTimeInt;
    finishTimeInt = _finishTimeInt;
};

void WeightControlPlotRenderEngineGLES1::SetScaleX(float _scaleX, float animationDuration){
    if(fabs(animationDuration)>FLOAT_EPSILON){
        xScale.SetAnimatedValue(_scaleX, animationDuration, AnimationTypeLinear);
    }else{
        xScale.SetNotAnimatedValue(_scaleX);
    }
    
    //printf("Time interval per pixel for current scale: %.0f\n", getTimeIntervalPerPixelForScale(_scaleX));
};

void WeightControlPlotRenderEngineGLES1::SetScaleY(float _scaleY, float animationDuration){
    if(fabs(animationDuration)>FLOAT_EPSILON){
        yScale.SetAnimatedValue(_scaleY, animationDuration, AnimationTypeLinear);
    }else{
        yScale.SetNotAnimatedValue(_scaleY);
    }
};

void WeightControlPlotRenderEngineGLES1::SetOffsetTimeInterval(float _xOffset, float animationDuration){
    float showStartOffset = (((xScale.curPos - 1) * (maxX - minX)) / 2.0) / xScale.curPos;
    float pointsOffset = showStartOffset - (_xOffset * (maxX - minX)) / (finishTimeInt - startTimeInt);
    //pointsOffset = 10;
    if(fabs(animationDuration)>FLOAT_EPSILON){
        xAxisOffset.SetAnimatedValue(pointsOffset, animationDuration, AnimationTypeLinear);
    }else{
        xAxisOffset.SetNotAnimatedValue(pointsOffset);
    }
};

void WeightControlPlotRenderEngineGLES1::SetOffsetPixels(float _xOffsetPx, float animationDuration){
    SetOffsetTimeInterval(_xOffsetPx * getTimeIntervalPerPixel(), animationDuration);
};

void WeightControlPlotRenderEngineGLES1::SmoothPanFinish(float finishVelocity){
    float smoothPanFinishTime = 1.0;
    float _xOffset = (finishVelocity / 4.0) * smoothPanFinishTime * getTimeIntervalPerPixel();
    float showStartOffset = (((xScale.curPos - 1) * (maxX - minX)) / 2.0) / xScale.curPos;
    float pointsOffset = showStartOffset - (_xOffset * (maxX - minX)) / (finishTimeInt - startTimeInt);
    
    printf("WeightControlPlotRenderEngineGLES1::SmoothPanFinish: pointsOffset = %.0f, xAxisOffset.curPos = %.0f\n", pointsOffset, xAxisOffset.curPos);
    xAxisOffset.SetAnimatedValue(xAxisOffset.curPos - pointsOffset, smoothPanFinishTime, AnimationTypeEaseOut);
};

float WeightControlPlotRenderEngineGLES1::getCurScaleX(){
    return xScale.curPos;
};

float WeightControlPlotRenderEngineGLES1::getCurScaleY(){
    return yScale.curPos;
};

float WeightControlPlotRenderEngineGLES1::getCurOffsetX(){
    float showStartOffset = (((xScale.curPos - 1) * (maxX - minX)) / 2.0) / xScale.curPos;
    float curOffsetTimeInt = ((showStartOffset - xAxisOffset.curPos) * (finishTimeInt - startTimeInt)) / (maxX - minX);
    
    return curOffsetTimeInt;
};

float WeightControlPlotRenderEngineGLES1::getCurOffsetXForScale(float _aimXScale){
    float showStartOffset = (((_aimXScale - 1) * (maxX - minX)) / 2.0) / _aimXScale;
    float curOffsetTimeInt = ((showStartOffset - xAxisOffset.curPos) * (finishTimeInt - startTimeInt)) / (maxX - minX);
    
    return curOffsetTimeInt;
};

float WeightControlPlotRenderEngineGLES1::getTimeIntervalPerPixel() const{
    return ((finishTimeInt - startTimeInt) / (viewPortWidth)) / xScale.curPos;
};

float WeightControlPlotRenderEngineGLES1::getTimeIntervalPerPixelForScale(float _aimXScale){
    return ((finishTimeInt - startTimeInt) / (viewPortWidth)) / _aimXScale;
};

float WeightControlPlotRenderEngineGLES1::GetXForTimeInterval(float _timeInterval) const{
    return minX + ((maxX-minX) * (_timeInterval - startTimeInt)) / (finishTimeInt - startTimeInt);
};

float WeightControlPlotRenderEngineGLES1::GetYForWeight(float _weight) const{
    return minY + (maxY-minY) * (_weight - minWeight.curPos) / (maxWeight.curPos - minWeight.curPos);
};
 
void WeightControlPlotRenderEngineGLES1::SetDataBase(std::list<WeightControlDataRecord> _base){
    plotData.clear();
    plotData = _base;
};
void WeightControlPlotRenderEngineGLES1::ClearDataBase(){
    plotData.clear();
};
void WeightControlPlotRenderEngineGLES1::SetDataRecord(WeightControlDataRecord _record, unsigned int _pos){
    if(_pos>=plotData.size()){
        printf("WeightControlPlotRenderEngineGLES1::SetDataRecord -  position (%d) is greater than vector's size", _pos);
        return;
    };
    
    std::list<WeightControlDataRecord>::iterator it1;
    advance(it1, _pos);
    plotData.erase(it1);
    plotData.insert(it1, _record);
};
void WeightControlPlotRenderEngineGLES1::InsertDataRecord(WeightControlDataRecord _record, unsigned int _pos){
    std::list<WeightControlDataRecord>::iterator it1;
    advance(it1, _pos);
    plotData.insert(it1, _record);
};
void WeightControlPlotRenderEngineGLES1::DeleteDataRecord(unsigned int _pos){
    std::list<WeightControlDataRecord>::iterator it1;
    advance(it1, _pos);
    plotData.erase(it1);
};


void WeightControlPlotRenderEngineGLES1::UpdateAnimation(float timeStep){
    //Animate min weight parameter
    minWeight.UpdateAnimation(timeStep);
    maxWeight.UpdateAnimation(timeStep);
    weightLinesStep.UpdateAnimation(timeStep);
    
    xScale.UpdateAnimation(timeStep);
    yScale.UpdateAnimation(timeStep);
    
    xAxisOffset.UpdateAnimation(timeStep);
};

void WeightControlPlotRenderEngineGLES1::Render() const {
    glClearColor(1.0f, 1.0f, 1.0f, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    glPushMatrix();
    glScalef(xScale.curPos, yScale.curPos, 1.0);
    glTranslatef(xAxisOffset.curPos, 0.0, 0.0);
    
    // Setting grid lines color
    GLfloat colors[][4] = { {0.5, 0.5, 0.5, 0.5}, {0.5, 0.5, 0.5, 0.5} };
    glColorPointer(4, GL_FLOAT, 4*sizeof(GLfloat), &colors[0]);
    
    //GLfloat pointSizes[2] = { 3.0, 3.0 };
    //glPointSizePointerOES(GL_FLOAT, sizeof(GLfloat), &pointSizes[0]);
    
    
    // Drawing horizontal grid lines
    std::vector<vec2> horizontalLines;
    horizontalLines.clear();
    float i_float;
    vec2 curPoint;
    int curPointI = 0;
    glLineWidth(1.0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    float tmp_float = minWeight.curPos / weightLinesStep.curPos;
    float startWeightPosition = floor(tmp_float) * weightLinesStep.curPos;
    for(i_float = startWeightPosition; i_float<maxWeight.curPos; i_float+=fabs(weightLinesStep.curPos)){
        curPoint.x = minX;
        curPoint.y = minY + ((maxY-minY)*(i_float-minWeight.curPos))/(maxWeight.curPos - minWeight.curPos);
        horizontalLines.push_back(curPoint);
        //std::cout<<"["<<curPoint.x<<", "<<curPoint.y<<"] -> ";
        curPoint.x = maxX;
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
    
    
    // Drawing vertical grid lines
    float xDimension = (maxX-minX) / (finishTimeInt - startTimeInt);
    float tiPerPx = getTimeIntervalPerPixel();
    float timeStep = 24.0*60.0*60.0;
    if(tiPerPx>=1000.0 && tiPerPx<4000.0) timeStep*=7;
    if(tiPerPx>=4000.0 ) timeStep*=30.5;
    std::vector<vec2> verticalLines;
    verticalLines.clear();
    curPointI = 0;
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    for(i_float=startTimeInt; i_float<finishTimeInt; i_float+=timeStep){
        curPoint.x = minX + xDimension * (i_float-startTimeInt);
        curPoint.y = maxY;
        verticalLines.push_back(curPoint);
        //std::cout<<"["<<curPoint.x<<", "<<curPoint.y<<"] -> ";
        curPoint.y = minY;
        verticalLines.push_back(curPoint);
        //std::cout<<"["<<curPoint.x<<", "<<curPoint.y<<"] ->\n";
        
        glVertexPointer(2, GL_FLOAT, sizeof(vec2), &verticalLines[curPointI].x);
        glDrawArrays(GL_LINES, 0, 2);
        curPointI+=2;
    };
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    
    
    // Drawing trend line
    glPopMatrix();
    
    std::vector<vec2> trendLine;
    trendLine.clear();
    vec4 blackColor(0.0, 0.0, 0.0, 1.0);
    vec4 redColor(1.0, 0.0, 0.0, 1.0);
    vec4 greenColor(0.0, 1.0, 0.0, 1.0);
    std::list<WeightControlDataRecord>::const_iterator plotDataIterator;
    glEnableClientState(GL_VERTEX_ARRAY);
    
    for(plotDataIterator=plotData.begin(); plotDataIterator!=plotData.end(); plotDataIterator++){
        curPoint.x = (GetXForTimeInterval((*plotDataIterator).timeInterval) + xAxisOffset.curPos) *xScale.curPos;
        curPoint.y = GetYForWeight((*plotDataIterator).trend) * yScale.curPos;
        trendLine.push_back(curPoint);
    }
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_LINE_WIDTH);
    glColor4f(1.0, 0.0, 0.0, 1.0);
    glVertexPointer(2, GL_FLOAT, sizeof(vec2), &trendLine[0].x);
    glColor4f(1.0, 0.0, 0.0, 1.0);
    glLineWidth(4.0);
    glDrawArrays(GL_LINE_STRIP, 0, trendLine.size());
    glDisableClientState(GL_LINE_WIDTH);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    // Drawing points and weight deviation lines
    int i;
    std::vector<vec2> weightDeviationLine;
    vec4 weightPointColor;
    for(plotDataIterator=plotData.begin(),i=0; plotDataIterator!=plotData.end(); plotDataIterator++,i++){
        weightDeviationLine.clear();
        weightDeviationLine.push_back(trendLine[i]);
        curPoint.x = trendLine[i].x;
        curPoint.y = GetYForWeight((*plotDataIterator).weight) * yScale.curPos;
        weightDeviationLine.push_back(curPoint);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_LINE_WIDTH);
        glColor4f(1.0, 0.0, 0.0, 1.0);
        glVertexPointer(2, GL_FLOAT, sizeof(vec2), &weightDeviationLine[0].x);
        if((*plotDataIterator).weight > (*plotDataIterator).trend){
           glColor4f(1.0, 0.0, 0.0, 1.0);
            weightPointColor = redColor;
        }else{
            glColor4f(0.0, 1.0, 0.0, 1.0);
            weightPointColor = greenColor;
        }
        glLineWidth(2.0);
        glDrawArrays(GL_LINES, 0, weightDeviationLine.size());
        glDisableClientState(GL_LINE_WIDTH);
        glDisableClientState(GL_VERTEX_ARRAY);
        
        DrawCircle(trendLine[i], 0.1, 32, blackColor, true, redColor);
        DrawCircle(curPoint, 0.1, 32, blackColor, true, weightPointColor);
        
    }
    
    glPopMatrix();
    
    
    /*
    // Drawing vertical axis
    std::vector<vec2> yAxisLines;
    yAxisLines.clear();

    curPoint.x = minX;
    curPoint.y = minY;
    yAxisLines.push_back(curPoint);
    float yAxisWidth = (maxX - minX) * 0.1;
    curPoint.x += yAxisWidth;
    yAxisLines.push_back(curPoint);
    curPoint.y = maxY;
    yAxisLines.push_back(curPoint);
    curPoint.x = minX;
    yAxisLines.push_back(curPoint);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, &yAxisLines[0].x);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_TRIANGLE_FAN, 0, yAxisLines.size());
    
    glColor4f(0.0, 0.0, 0.0, 1.0);
    glEnableClientState(GL_LINE_WIDTH);
    glLineWidth(4.0);
    glDrawArrays(GL_LINES, 1, 2);
    glDisableClientState(GL_LINE_WIDTH);

    glDisableClientState(GL_VERTEX_ARRAY);
    
    // Drawing horizontal axis
    std::vector<vec2> xAxisLines;
    xAxisLines.clear();
    
    curPoint.x = minX;
    curPoint.y = minY;
    xAxisLines.push_back(curPoint);
    float xAxisWidth = yAxisWidth;
    curPoint.y += xAxisWidth;
    xAxisLines.push_back(curPoint);
    curPoint.x = maxX;
    xAxisLines.push_back(curPoint);
    curPoint.y = minY;
    xAxisLines.push_back(curPoint);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, &xAxisLines[0].x);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_TRIANGLE_FAN, 0, xAxisLines.size());
    
    xAxisLines[1].x = minX + yAxisWidth;
    
    glColor4f(0.0, 0.0, 0.0, 1.0);
    glEnableClientState(GL_LINE_WIDTH);
    glLineWidth(4.0);
    glDrawArrays(GL_LINES, 1, 2);
    glDisableClientState(GL_LINE_WIDTH);
    
    glDisableClientState(GL_VERTEX_ARRAY);
     */
    
    
};

void WeightControlPlotRenderEngineGLES1::DrawCircle(vec2 center, float r, unsigned int segments, vec4 circleColor, bool isFill, vec4 fillColor) const{
    std::vector<vec2> verts;
    verts.clear();
    float float_i;
    vec2 curVert;
    for(float_i=0.0; float_i<360.0; float_i+=(360.0/segments)){
        curVert.x = center.x + r * cos(float_i*Pi/180.0);
        curVert.y = center.y + r * sin(float_i*Pi/180.0);
        verts.push_back(curVert);
    };
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_LINE_WIDTH);
    glVertexPointer(2, GL_FLOAT, 0, &verts[0].x);
    
    if(isFill){
        glColor4f(fillColor.x, fillColor.y, fillColor.z, fillColor.w);
        glLineWidth(1.0);
        glDrawArrays(GL_TRIANGLE_FAN, 0, segments);
    };
    
    glColor4f(circleColor.x, circleColor.y, circleColor.z, circleColor.w);
    glLineWidth(2.0);
    
    glDrawArrays(GL_LINE_LOOP, 0, segments);
    
    glDisableClientState(GL_LINE_WIDTH);
    glDisableClientState(GL_VERTEX_ARRAY);
};