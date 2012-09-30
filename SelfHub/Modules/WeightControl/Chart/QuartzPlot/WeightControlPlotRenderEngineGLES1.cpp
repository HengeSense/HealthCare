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
#define X_AXIS_WIDTH 0.08   // in view port's height percents

#pragma mark - Helper structs and routines

// Look http://gizma.com/easing/ for tweening functions

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
        float changeVal = endPos - startPos;
        curPos = changeVal * animationCompletionPercent + startPos;
        
    };
    void SetCurStateForTimeEaseIn(float timeStep){
        elapsedTime += timeStep;
        if(elapsedTime >= duration){
            curPos = endPos;
            return;
        };
        
        float animationCompletionPercent = elapsedTime / duration;
        float changeVal = endPos - startPos;
        curPos = changeVal * powf(animationCompletionPercent, 2.0) + startPos;
    };
    void SetCurStateForTimeEaseOut(float timeStep){
        elapsedTime += timeStep;
        if(elapsedTime >= duration){
            curPos = endPos;
            return;
        };
        
        float animationCompletionPercent = elapsedTime / duration;
        float changeVal = endPos - startPos;
        
        //Quadratic
        //curPos = -changeVal * animationCompletionPercent * (animationCompletionPercent - 2.0) + startPos;
        
        //Quartic
        animationCompletionPercent-=1.0;
        curPos = -changeVal * (pow(animationCompletionPercent, 4.0) - 1.0) + startPos;
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
    };

    void SetCurStateForTimeEaseInOut(float timeStep){
        elapsedTime += timeStep;
        if(elapsedTime >= duration){
            curPos = endPos;
            return;
        };
        
        float animationCompletionPercent = elapsedTime / duration;
        float changeVal = endPos - startPos;
        
        float t = animationCompletionPercent * 2.0;
        if(t <= 1){
            curPos = changeVal / 2.0 * powf(t, 2.0) + startPos;
        }else{
            t -= 1.0;
            curPos = -changeVal/2.0*(t*(t-2.0)-1.0) + startPos;
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
    void UpdateYAxisParams(float animationDuration = 0.0);
    void UpdateYAxisParamsForOffsetAndScale(float _xOffset, float _xScale, float animationDuration = 0.0);
    void SetXAxisParams(float _startTimeInt, float _finishTimeInt);
    void GetYAxisDrawParams(float &_firstGridPt, float &_firstGridWeight, float &_gridLinesStep, float &_weightLinesStep, unsigned short &_linesNum);
    
    void SetScaleX(float _scaleX, float animationDuration = 0.0);
    void SetScaleY(float _scaleY, float animationDuration = 0.0);
    
    void SetOffsetTimeInterval(float _xOffset, float animationDuration = 0.0);
    void SetOffsetPixels(float _xOffsetPx, float animationDuration = 0.0);
    void SetOffsetPixelsDecelerating(float _xOffsetPx, float animationDuration);
    
    float getCurScaleX();
    float getCurScaleY();
    float getCurOffsetX();
    float getCurOffsetXForScale(float _aimXScale);
    float getTimeIntervalPerPixel();
    float getTimeIntervalPerPixelForScale(float _aimXScale);
    float getMaxOffsetPx();
    bool isPlotOutOfBoundsForOffsetAndScale(float _offsetX, float _scale);
    float getPlotWidthPxForScale(float _scale);
    
    float GetXForTimeInterval(float _timeInterval);
    float GetYForWeight(float _weight);
    float GetWeightIntervalForYinterval(float _yInterval);
    float GetYIntervalForWeightInterval(float _weightInterval);
    
    void SetDataBase(std::list<WeightControlDataRecord> _base);
    void ClearDataBase();
    void SetDataRecord(WeightControlDataRecord _record, unsigned int _pos);
    void InsertDataRecord(WeightControlDataRecord _record, unsigned int _pos);
    void DeleteDataRecord(unsigned int _pos);
    
    void Render();
    void UpdateAnimation(float timeStep);
    
private:
    float minX, maxX, minY, maxY;
    int viewPortWidth, viewPortHeight;
    AnimatedFloat xScale, yScale;
    
    std::list<WeightControlDataRecord> plotData;
    
    AnimatedFloat minWeight, maxWeight, weightLinesStep;
    unsigned short numOfHorizontalGridLines;
    
    AnimatedFloat xAxisOffset;
    float startTimeInt, finishTimeInt;

    GLuint framebuffer;
    GLuint renderbuffer;
    
    void DrawCircle(vec2 center, float r, vec4 circleColor, bool isFill, vec4 fillColor);
    
    float lastCircleR;
    std::vector<vec2> circleVerts;
};

WeightControlPlotRenderEngine *CreateRendererForGLES1(){
    return new WeightControlPlotRenderEngineGLES1();
}

WeightControlPlotRenderEngineGLES1::WeightControlPlotRenderEngineGLES1(){
    glGenRenderbuffersOES(1, &renderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
    
    circleVerts.clear();
    lastCircleR = 0.0;
};

void WeightControlPlotRenderEngineGLES1::Initialize(int width, int height){
    glGenFramebuffersOES(1, &framebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderbuffer);
    
    glViewport(0, 0, width, height);
    viewPortWidth = width;
    viewPortHeight = height;
    
    glMatrixMode(GL_PROJECTION);
    minX = -width/2.0;
    maxX = (float)width/2.0;
    minY = -height/2.0;
    maxY = (float)height/2.0;
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

void WeightControlPlotRenderEngineGLES1::UpdateYAxisParams(float animationDuration){
    float xOffsetPx = (xAxisOffset.curPos * viewPortWidth * xScale.curPos) / (maxX - minX);
    UpdateYAxisParamsForOffsetAndScale(xOffsetPx, xScale.curPos, animationDuration);
};


void WeightControlPlotRenderEngineGLES1::UpdateYAxisParamsForOffsetAndScale(float _xOffset, float _xScale, float animationDuration){
    //float showStartOffsetPt = (((_xScale - 1) * (maxX - minX)) / 2.0) / _xScale;
    float tiPerPx = ((finishTimeInt - startTimeInt) / (viewPortWidth)) / _xScale;
    //float pointsOffset = showStartOffsetPt - ((_xOffset * tiPerPx * (maxX - minX)) / (finishTimeInt - startTimeInt)) / _xScale;
    //printf("Offset: [Pt=%.2f, Px=%.2f, ti=%.0f] | Scale: %.4f | animDur: %.3f s | ", pointsOffset, _xOffset, _xOffset * tiPerPx, _xScale, animationDuration);
    
    
    float testedBlockStartTimeInterval = startTimeInt + tiPerPx * _xOffset;
    float testedBlockEndTimeInterval = testedBlockStartTimeInterval + (finishTimeInt-startTimeInt) / _xScale;
    //printf("testedBlockInterval: %.1f days | ", (testedBlockEndTimeInterval-testedBlockStartTimeInterval) / (60.0*60.0*24.0));
    
    std::list<WeightControlDataRecord>::const_iterator plotDataIterator;
    float minValue = MAXFLOAT, maxValue = 0.0;
    float curMinValue = MAXFLOAT, curMaxValue = 0.0;
    float curTimeInterval, curWeight, curTrend;
    bool isFirstPoint = true;
    
    plotDataIterator=plotData.begin();
    float lastTrend = (*plotDataIterator).trend;
    float lastWeight = (*plotDataIterator).weight;
    float lastTimeInterval = (*plotDataIterator).timeInterval;
    
    for(; plotDataIterator!=plotData.end(); plotDataIterator++){
        curTimeInterval = (*plotDataIterator).timeInterval;
        curTrend = (*plotDataIterator).trend;
        curWeight = (*plotDataIterator).weight;
        
        if((curTimeInterval>=testedBlockStartTimeInterval && curTimeInterval<=testedBlockEndTimeInterval)){
            if(isFirstPoint && plotDataIterator!=plotData.begin()){
                plotDataIterator--;
                
                lastTrend = (*plotDataIterator).trend;
                lastWeight = (*plotDataIterator).weight;
                lastTimeInterval = (*plotDataIterator).timeInterval;
                //plotDataIterator++;       // ! It's don't need to increment iterator, because we should review first point after intermediate point
                
                //printf("first: [w=%.3f, t=%.3f] -> ", curWeight, curTrend);
                curTrend = lastTrend + ((testedBlockStartTimeInterval-lastTimeInterval)*(curTrend-lastTrend))/(curTimeInterval-lastTimeInterval);
                curWeight = lastWeight + ((testedBlockStartTimeInterval-lastTimeInterval)*(curWeight-lastWeight))/(curTimeInterval-lastTimeInterval);
                //printf("[w=%.3f, t=%.3f] | ", curWeight, curTrend);
            }else{
                curTrend = (*plotDataIterator).trend;
                curWeight = (*plotDataIterator).weight;
            };
            
            isFirstPoint = false;
            
            
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
                if(isFirstPoint){
                    curTrend = lastTrend + ((testedBlockStartTimeInterval-lastTimeInterval)*(curTrend-lastTrend))/(curTimeInterval-lastTimeInterval);
                    curWeight = lastWeight + ((testedBlockStartTimeInterval-lastTimeInterval)*(curWeight-lastWeight))/(curTimeInterval-lastTimeInterval);
                    isFirstPoint = false;
                    if(curWeight<curTrend){
                        curMinValue = curWeight;
                        curMaxValue = curTrend;
                    }else{
                        curMinValue = curTrend;
                        curMaxValue = curWeight;
                    };
                    if(curMinValue<minValue) minValue = curMinValue;
                    if(curMaxValue>maxValue) maxValue = curMaxValue;
                    continue;
                };
                
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
            };
            
            break;
        };
        
        lastTimeInterval = curTimeInterval;
        lastTrend = curTrend;
        lastWeight = curWeight;
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
    
    float ySizeForHorizontalAxis = (maxY - minY) * X_AXIS_WIDTH;
    newMinWeight -= GetWeightIntervalForYinterval(ySizeForHorizontalAxis);
    
    
    printf("UpdateYAxisParams: minValue = %.3f, maxValue = %.3f, interval = %.1f (from %.0f ti to %.0f ti)\n", newMinWeight, newMaxWeight, myWeightLinesStep, testedBlockStartTimeInterval, testedBlockEndTimeInterval);
    SetYAxisParams(newMinWeight, newMaxWeight, myWeightLinesStep, animationDuration);
};

void WeightControlPlotRenderEngineGLES1::GetYAxisDrawParams(float &_firstGridPt, float &_firstGridWeight, float &_gridLinesStep, float &_weightLinesStep, unsigned short &_linesNum){
    
    _firstGridWeight = floor(minWeight.curPos / weightLinesStep.curPos) * weightLinesStep.curPos;
    _firstGridPt = GetYForWeight(_firstGridWeight);
    _gridLinesStep = GetYIntervalForWeightInterval(weightLinesStep.curPos);
    _weightLinesStep = weightLinesStep.curPos;
    _linesNum = numOfHorizontalGridLines;
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
    if(fabs(animationDuration)>FLOAT_EPSILON){
        xAxisOffset.SetAnimatedValue(pointsOffset, animationDuration, AnimationTypeLinear);
    }else{
        xAxisOffset.SetNotAnimatedValue(pointsOffset);
    }
};

void WeightControlPlotRenderEngineGLES1::SetOffsetPixels(float _xOffsetPx, float animationDuration){
    SetOffsetTimeInterval(_xOffsetPx * getTimeIntervalPerPixel(), animationDuration);
};

void WeightControlPlotRenderEngineGLES1::SetOffsetPixelsDecelerating(float _xOffsetPx, float animationDuration = 0.0){
    float showStartOffset = (((xScale.curPos - 1) * (maxX - minX)) / 2.0) / xScale.curPos;
    float pointsOffset = showStartOffset - (_xOffsetPx * getTimeIntervalPerPixel() * (maxX - minX)) / (finishTimeInt - startTimeInt);
    xAxisOffset.SetAnimatedValue(pointsOffset, animationDuration, AnimationTypeEaseOut);
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

float WeightControlPlotRenderEngineGLES1::getTimeIntervalPerPixel(){
    return ((finishTimeInt - startTimeInt) / (viewPortWidth)) / xScale.curPos;
};

float WeightControlPlotRenderEngineGLES1::getTimeIntervalPerPixelForScale(float _aimXScale){
    return ((finishTimeInt - startTimeInt) / (viewPortWidth)) / _aimXScale;
};

float WeightControlPlotRenderEngineGLES1::getMaxOffsetPx(){
    return (finishTimeInt-startTimeInt) / getTimeIntervalPerPixel() - viewPortWidth;
};

bool WeightControlPlotRenderEngineGLES1::isPlotOutOfBoundsForOffsetAndScale(float _offsetX, float _scale){
    float maxOffseetPx = (finishTimeInt-startTimeInt) / getTimeIntervalPerPixelForScale(_scale) - viewPortWidth;
    
    return (_offsetX<0 || _offsetX>maxOffseetPx) ? true : false;
};

float WeightControlPlotRenderEngineGLES1::getPlotWidthPxForScale(float _scale){
    return viewPortWidth * _scale;
};

float WeightControlPlotRenderEngineGLES1::GetXForTimeInterval(float _timeInterval){
    return minX + ((maxX-minX) * (_timeInterval - startTimeInt)) / (finishTimeInt - startTimeInt);
};

float WeightControlPlotRenderEngineGLES1::GetYForWeight(float _weight){
    return minY + (maxY-minY) * (_weight - minWeight.curPos) / (maxWeight.curPos - minWeight.curPos);
};

float WeightControlPlotRenderEngineGLES1::GetWeightIntervalForYinterval(float _yInterval){
    return (_yInterval * (maxWeight.curPos - minWeight.curPos)) / (maxY - minY);
};

float WeightControlPlotRenderEngineGLES1::GetYIntervalForWeightInterval(float _weightInterval){
    return (_weightInterval * (maxY - minY)) / (maxWeight.curPos - minWeight.curPos);
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

void WeightControlPlotRenderEngineGLES1::Render() {
    glClearColor(0.2f, 0.2f, 0.2f, 1.0);
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
    numOfHorizontalGridLines = 0;
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
        
        numOfHorizontalGridLines++;
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
        
        //DrawCircle(trendLine[i], 0.1, blackColor, true, redColor);
        DrawCircle(curPoint, (maxX-minX)*0.007, blackColor, true, weightPointColor);
        
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

    glDisableClientState(GL_VERTEX_ARRAY);*/
    
    // Drawing horizontal axis
    std::vector<vec2> xAxisLines;
    xAxisLines.clear();
    
    curPoint.x = minX;
    curPoint.y = minY;
    xAxisLines.push_back(curPoint);
    float xAxisWidth = (maxX - minX) * X_AXIS_WIDTH;
    curPoint.y += xAxisWidth;
    xAxisLines.push_back(curPoint);
    curPoint.x = maxX;
    xAxisLines.push_back(curPoint);
    curPoint.y = minY;
    xAxisLines.push_back(curPoint);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, &xAxisLines[0].x);
    glColor4f(0.15, 0.15, 0.15, 1);
    glDrawArrays(GL_TRIANGLE_FAN, 0, xAxisLines.size());
    
    xAxisLines[1].x = minX;
    
    glColor4f(0.0, 0.0, 0.0, 1.0);
    glEnableClientState(GL_LINE_WIDTH);
    glLineWidth(4.0);
    glDrawArrays(GL_LINES, 1, 2);
    glDisableClientState(GL_LINE_WIDTH);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    
    
};

void WeightControlPlotRenderEngineGLES1::DrawCircle(vec2 center, float r, vec4 circleColor, bool isFill, vec4 fillColor){
    unsigned int segments = 4;
    
    if(fabs(lastCircleR - r)>0.00001){  //If saved vertixes array don't match required radius - rebuild vertixes array
        circleVerts.clear();
        float float_i;
        vec2 curVert;
        for(float_i=0.0; float_i<360.0; float_i+=(360.0/segments)){
            curVert.x = r * cos(float_i*Pi/180.0);
            curVert.y = r * sin(float_i*Pi/180.0);
            circleVerts.push_back(curVert);
        };
        lastCircleR = r;
    };
    
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_LINE_WIDTH);
    glVertexPointer(2, GL_FLOAT, 0, &circleVerts[0].x);
    
    
    glPushMatrix();
    glTranslatef(center.x, center.y, 0);
    
    if(isFill){
        glColor4f(fillColor.x, fillColor.y, fillColor.z, fillColor.w);
        glLineWidth(1.0);
        glDrawArrays(GL_TRIANGLE_FAN, 0, segments);
    };
    glColor4f(circleColor.x, circleColor.y, circleColor.z, circleColor.w);
    glLineWidth(2.0);
    glDrawArrays(GL_LINE_LOOP, 0, segments);
    
    glPopMatrix();
    
    glDisableClientState(GL_LINE_WIDTH);
    glDisableClientState(GL_VERTEX_ARRAY);
};