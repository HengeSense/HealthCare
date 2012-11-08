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
#include <math.h>

#define DEFAULT_ANIMATION_DURATION 1.0
#define FLOAT_EPSILON 0.00001

#pragma mark - Helper structs and routines

// Look http://gizma.com/easing/ for tweening functions

enum AnimationType{
    AnimationTypeLinear = 0,
    AnimationTypeEaseIn = 1,
    AnimationTypeEaseOut = 2,
    AnimationTypeEaseInOut = 3,
    AnimationTypeSuperOut = 4,
    AnimationTypeDiscrete = 5
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
        //if(_type==AnimationTypeDiscrete && fabs(endPos-startPos)>FLOAT_EPSILON){
        //    printf("---------------------------------------------------\n");
        //};
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
        //animationCompletionPercent-=1.0;
        //curPos = -changeVal * (pow(animationCompletionPercent, 4.0) - 1.0) + startPos;
        
        //Circular
        animationCompletionPercent-=1.0;
        curPos = changeVal * sqrtf(1.0 - pow(animationCompletionPercent, 2)) + startPos;
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
    
    void SetCurStateForTimeDiscrete(float timeStep){
        elapsedTime += timeStep;
        if(elapsedTime >= duration){
            curPos = endPos;
            return;
        };

        // discrete levels
        float discrets[] = {0.1, 0.5, 1.0, 2.5, 5.0, 10.0};
        int i, startI = -1, endI = -1, levelsDiff;
        for(i=0;i<(sizeof(discrets)/sizeof(float));i++){
            if(discrets[i]==startPos) startI = i;
            if(discrets[i]==endPos) endI = i;
        };
        if(startI<0 || endI<0) return;
        
        levelsDiff = endI-startI;
        
        float animationCompletionPercent = elapsedTime / duration;
        int needSubscript = startI+(int)floorf(animationCompletionPercent * (abs(levelsDiff)+1)) * (levelsDiff<0 ? -1 : 1);
        curPos = discrets[needSubscript];
        //if(fabs(endPos-startPos)>FLOAT_EPSILON) {
            //printf("Discrete animation %.1f%%: indexes %d -> %d, currentIndex = %d (%.1f)\n", animationCompletionPercent*100.0, startI, endI, needSubscript, curPos);
        //};
        
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
            case AnimationTypeDiscrete:
                SetCurStateForTimeDiscrete(timeStep);
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
    GLuint GetRenderbuffer();
    
    void SetDrawSettings(WeightControlPlotDrawSettings _drawSettings);
    WeightControlPlotDrawSettings *GetDrawSettings();
    
    void SetYAxisParams(float _minWeight, float _maxWeight, float _weightLinesStep, float animationDuration = 0.0);
    void UpdateYAxisParams(float animationDuration = 0.0);
    void UpdateYAxisParamsForOffsetAndScale(float _xOffset, float _xScale, float animationDuration = 0.0);
    void SetXAxisParams(float _startTimeInt, float _finishTimeInt);
    void GetYAxisDrawParams(float &_firstGridPt, float &_firstGridWeight, float &_gridLinesStep, float &_weightLinesStep, unsigned short &_linesNum);
    void GetXAxisDrawParams(float &_firstGridXPt, float &_firstGridXTimeInterval, float &_gridXLinesStep, float &_timeIntLinesStep, unsigned short &_linesXNum);
    float GetXAxisVisibleRectStart();
    float GetXAxisVisibleRectEnd();
    
    void SetScaleX(float _scaleX, float animationDuration = 0.0);
    void SetTiPerPx(float _tiPerPx, float animationDuration = 0.0);
    void SetScaleY(float _scaleY, float animationDuration = 0.0);
    
    
    void SetOffsetTimeInterval(float _xOffset, float animationDuration = 0.0);
    void SetTimeIntervalInCenter(float _timeInt, float animationDuration = 0.0);
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
    void SetNormalWeight(float _normWeight);
    float GetNormalWeight();
    void SetAimWeight(float _aimWeight);
    float GetAimWeight();
    void SetForecastTimeInterval(float _forecastTimeInt);
    float GetForecastTimeInterval();
    
    float FadeValue(float x, float limit, float dist, float y0, float y1);
    
    void Render();
    void UpdateAnimation(float timeStep);
    
private:
    // OpenGL buffers
    GLuint framebuffer;
    GLuint renderbuffer;
    
    WeightControlPlotDrawSettings drawSet;
    
    
    float minX, maxX, minY, maxY;
    int viewPortWidth, viewPortHeight;
    AnimatedFloat xScale, yScale;
    
    std::list<WeightControlDataRecord> plotData;
    float aimWeight;
    float normWeight;
    float forecastTimeInt;
    
    AnimatedFloat minWeight, maxWeight, weightLinesStep;
    unsigned short numOfHorizontalGridLines;
    
    float firstGridLineX, verticalGridTimeStep;
    unsigned short numOfVerticalGridLines;
    
    AnimatedFloat xAxisOffset;
    float startTimeInt, finishTimeInt;
    
    void DrawCircle(vec2 center, float r, color circleColor, bool isFill, color fillColor);
    
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
    
    aimWeight = NAN;
    normWeight = NAN;
    forecastTimeInt = NAN;
    
    
    // Applying standart settings
    drawSet.ApplyStandartSettings();
};

GLuint WeightControlPlotRenderEngineGLES1::GetRenderbuffer(){
    return renderbuffer;
};

void WeightControlPlotRenderEngineGLES1::SetDrawSettings(WeightControlPlotDrawSettings _drawSettings){
    drawSet = _drawSettings;
};

WeightControlPlotDrawSettings *WeightControlPlotRenderEngineGLES1::GetDrawSettings(){
    return &drawSet;
};

void WeightControlPlotRenderEngineGLES1::SetYAxisParams(float _minWeight, float _maxWeight, float _weightLinesStep, float animationDuration){
    if(fabs(animationDuration)>FLOAT_EPSILON){
        minWeight.SetAnimatedValue(_minWeight, animationDuration, AnimationTypeLinear);
        maxWeight.SetAnimatedValue(_maxWeight, animationDuration, AnimationTypeLinear);
        weightLinesStep.SetAnimatedValue(_weightLinesStep, animationDuration, AnimationTypeDiscrete);
    }else{
        minWeight.SetNotAnimatedValue(_minWeight);
        maxWeight.SetNotAnimatedValue(_maxWeight);
        weightLinesStep.SetNotAnimatedValue(_weightLinesStep);
    };
};

void WeightControlPlotRenderEngineGLES1::UpdateYAxisParams(float animationDuration){
    float xOffsetPx = getCurOffsetX() / getTimeIntervalPerPixel();//(xAxisOffset.curPos * viewPortWidth * xScale.curPos) / (maxX - minX);
    UpdateYAxisParamsForOffsetAndScale(xOffsetPx, xScale.curPos, animationDuration);
};

// UpdateYAxisParams for offset 15822: minValue = 43.099, maxValue = 60.300, interval = 2.5 (from 1353930496 ti to 1354890496 ti)
// UpdateYAxisParams for offset 15821: minValue = 50.420, maxValue = 57.860, interval = 1.0 (from 1353928192 ti to 1354888192 ti)

void WeightControlPlotRenderEngineGLES1::UpdateYAxisParamsForOffsetAndScale(float _xOffset, float _xScale, float animationDuration){
    float tiPerPx = ((finishTimeInt - startTimeInt) / (viewPortWidth)) / _xScale;
    
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
    
    if(!std::isnan(forecastTimeInt) && fabs(forecastTimeInt)>0.0001 && plotData.size()>0){
        plotDataIterator = plotData.end();
        plotDataIterator--;
        lastTrend = (*plotDataIterator).trend;
        lastTimeInterval = (*plotDataIterator).timeInterval;
        float forecastWeight;
        if(testedBlockStartTimeInterval > lastTimeInterval && testedBlockStartTimeInterval <= (lastTimeInterval+forecastTimeInt)){
            forecastWeight = lastTrend - ((testedBlockStartTimeInterval - lastTimeInterval)*(lastTrend-aimWeight))/forecastTimeInt;
            maxValue = maxValue<forecastWeight ? forecastWeight : maxValue;
            minValue = minValue>forecastWeight ? forecastWeight : minValue;
        };
    };
    
    if(aimWeight!=NAN){
        maxValue = maxValue<aimWeight ? aimWeight : maxValue;
        minValue = minValue>aimWeight ? aimWeight : minValue;
    };
    if(normWeight!=NAN){
        maxValue = maxValue<normWeight ? normWeight : maxValue;
        minValue = minValue>normWeight ? normWeight : minValue;
    };
    
    
    if(fabs(maxValue-minValue)<0.00001){
        maxValue+=2.0;
        minValue-=2.0;
    }
    //printf("[%0.1f..%.1f] ", minValue, maxValue);
    
    
    float newMinWeight, newMaxWeight;
    newMinWeight = minValue;
    newMaxWeight = maxValue;
    float ySizeForHorizontalAxis = (maxY - minY) * drawSet.expandYaxisAtBottom;
    float ySizeForTop = (maxY - minY) * drawSet.expandYaxisAtTop;
    newMinWeight -= ((ySizeForHorizontalAxis * (maxValue - minValue)) / (maxY - minY));
    newMaxWeight += ((ySizeForTop * (maxValue - minValue)) / (maxY - minY));
    float diff = newMaxWeight - newMinWeight;
    
    
    float  myWeightLinesStep = 0.1;
    if(diff<=1.0) myWeightLinesStep = 0.1;
    if(diff>1.0 && diff<=4.0) myWeightLinesStep = 0.5;
    if(diff>4.0 && diff<=10.0) myWeightLinesStep = 1.0;
    if(diff>10.0 && diff<=20.0) myWeightLinesStep = 2.5;
    if(diff>20.0 && diff<=40.0) myWeightLinesStep = 5.0;
    if(diff>40) myWeightLinesStep = 10.0;
    
    
    //printf("UpdateYAxisParams for offset %.0f andScale %.1f: minValue = %.3f, maxValue = %.3f, interval = %.1f (from %.0f ti to %.0f ti)\n", _xOffset, _xScale, newMinWeight, newMaxWeight, myWeightLinesStep, testedBlockStartTimeInterval, testedBlockEndTimeInterval);
    SetYAxisParams(newMinWeight, newMaxWeight, myWeightLinesStep, animationDuration);
};

void WeightControlPlotRenderEngineGLES1::GetYAxisDrawParams(float &_firstGridPt, float &_firstGridWeight, float &_gridLinesStep, float &_weightLinesStep, unsigned short &_linesNum){
    
    _firstGridWeight = floor(minWeight.curPos / weightLinesStep.curPos) * weightLinesStep.curPos;
    _firstGridPt = GetYForWeight(_firstGridWeight);
    _gridLinesStep = GetYIntervalForWeightInterval(weightLinesStep.curPos);
    _weightLinesStep = weightLinesStep.curPos;
    _linesNum = numOfHorizontalGridLines;
};

void WeightControlPlotRenderEngineGLES1::GetXAxisDrawParams(float &_firstGridXPt, float &_firstGridXTimeInterval, float &_gridXLinesStep, float &_timeIntLinesStep, unsigned short &_linesXNum){
    
    float curTiPerPx = getTimeIntervalPerPixel();
    _firstGridXPt = minX + firstGridLineX;
    _firstGridXTimeInterval = startTimeInt + getCurOffsetX() + firstGridLineX * curTiPerPx;
    _gridXLinesStep = verticalGridTimeStep / curTiPerPx;
    _timeIntLinesStep = verticalGridTimeStep;
    _linesXNum = numOfVerticalGridLines;
};

void WeightControlPlotRenderEngineGLES1::SetXAxisParams(float _startTimeInt, float _finishTimeInt){
    startTimeInt = _startTimeInt;
    finishTimeInt = _finishTimeInt;
    
    if(startTimeInt>finishTimeInt){
        printf("OpenGL render error: wrong time intervals!\n");
        startTimeInt = _finishTimeInt;
        finishTimeInt = _startTimeInt;
    }
    
    
    float oneDay = 60.0*60.0*24.0;
    //if(fabs(startTimeInt - finishTimeInt)<oneDay){
    startTimeInt-=drawSet.xAxisExtendInterval;
    finishTimeInt+=drawSet.xAxisExtendInterval;
    //};
};

float WeightControlPlotRenderEngineGLES1::GetXAxisVisibleRectStart(){
    return startTimeInt + getCurOffsetX();
};

float WeightControlPlotRenderEngineGLES1::GetXAxisVisibleRectEnd(){
    return startTimeInt + getCurOffsetX() + viewPortWidth * getTimeIntervalPerPixel();
};

void WeightControlPlotRenderEngineGLES1::SetScaleX(float _scaleX, float animationDuration){
    if(fabs(animationDuration)>FLOAT_EPSILON){
        xScale.SetAnimatedValue(_scaleX, animationDuration, AnimationTypeLinear);
    }else{
        xScale.SetNotAnimatedValue(_scaleX);
    };
};

void WeightControlPlotRenderEngineGLES1::SetTiPerPx(float _tiPerPx, float animationDuration){
    float newXScale = (finishTimeInt - startTimeInt) / (_tiPerPx * viewPortWidth);
    SetScaleX(newXScale, animationDuration);
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
    };
};

void WeightControlPlotRenderEngineGLES1::SetTimeIntervalInCenter(float _timeInt, float animationDuration){
    float halfViewPortWidthTimeInt = getTimeIntervalPerPixel() * (viewPortWidth / 2.0);
    float _xOffsetTiPerPx = _timeInt - startTimeInt - halfViewPortWidthTimeInt;
    
    if(_xOffsetTiPerPx<0 || _timeInt>finishTimeInt){
        printf("WeightControlPlotRenderEngineGLES1::SetTimeIntervalInCenter time interval out of plot's bounds!\n");
        return;
    };
    
    SetOffsetTimeInterval(_xOffsetTiPerPx, animationDuration);
    
    
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

void WeightControlPlotRenderEngineGLES1::SetNormalWeight(float _normWeight){
    normWeight = _normWeight;
};

float WeightControlPlotRenderEngineGLES1::GetNormalWeight(){
    return normWeight;
};

void WeightControlPlotRenderEngineGLES1::SetAimWeight(float _aimWeight){
    aimWeight = _aimWeight;
};

float WeightControlPlotRenderEngineGLES1::GetAimWeight(){
    return aimWeight;
};

void WeightControlPlotRenderEngineGLES1::SetForecastTimeInterval(float _forecastTimeInt){
    forecastTimeInt = _forecastTimeInt;
};

float WeightControlPlotRenderEngineGLES1::GetForecastTimeInterval(){
    return forecastTimeInt;
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
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //glClearColor(drawSet.backgroundColor.r, drawSet.backgroundColor.g, drawSet.backgroundColor.b, drawSet.backgroundColor.a);
    //glClear(GL_COLOR_BUFFER_BIT);

    
    // Setting grid lines color
    glColor4f(drawSet.gridLinesColor.r, drawSet.gridLinesColor.g, drawSet.gridLinesColor.b, drawSet.gridLinesColor.a);
    
    int i;
    
    // Drawing horizontal grid lines
    std::vector<vec2> horizontalLinePoints;
    horizontalLinePoints.clear();
    float i_float, i_float_2;
    vec2 curPoint;
    int curPointI = 0;
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_LINE_WIDTH);
    
    glLineWidth(drawSet.gridLinesWidth);
    
    float tmp_float = minWeight.curPos / weightLinesStep.curPos;
    float startWeightPosition = floor(tmp_float) * weightLinesStep.curPos;
    numOfHorizontalGridLines = 0;
    curPoint.y = 0;
    for(i_float_2=minX; i_float_2<maxX; i_float_2+=2.0){
        curPoint.x = i_float_2;
        horizontalLinePoints.push_back(curPoint);
        curPointI++;
    };
    glVertexPointer(2, GL_FLOAT,  sizeof(vec2), &horizontalLinePoints[0].x);
    for(i_float = startWeightPosition; i_float<maxWeight.curPos; i_float+=fabs(weightLinesStep.curPos)){
        glPushMatrix();
        glTranslatef(0.0, minY + ((maxY-minY)*(i_float-minWeight.curPos))/(maxWeight.curPos - minWeight.curPos), 0.0);
        glDrawArrays(GL_POINTS, 0, curPointI);
        glPopMatrix();
        
        numOfHorizontalGridLines++;
    };
    
    
    
    // Drawing vertical grid lines
    float tiPerPx = getTimeIntervalPerPixel();
    float timeStep = 24.0*60.0*60.0;
    if(tiPerPx>=drawSet.minTiPerPxForWeekDivision && tiPerPx<drawSet.minTiPerPxForMonthDivision) timeStep*=7;
    if(tiPerPx>=drawSet.minTiPerPxForMonthDivision && tiPerPx<drawSet.minTiPerPxForYearDivision) timeStep*=31.0;
    if(tiPerPx>=drawSet.minTiPerPxForYearDivision) timeStep*=365;
    std::vector<vec2> verticalLinePoints;
    verticalLinePoints.clear();
    curPointI = 0;
    float curOffsetXti = getCurOffsetX();
    curPoint.x = 0.0;
    for(i_float_2=minY; i_float_2<maxY;i_float_2+=2.0){
        curPoint.y = i_float_2;
        verticalLinePoints.push_back(curPoint);
        curPointI++;
    };
    glVertexPointer(2, GL_FLOAT, sizeof(vec2), &verticalLinePoints[0].x);
    numOfVerticalGridLines = 0;
    for(i_float=startTimeInt; i_float<finishTimeInt; i_float+=timeStep){
        if((i_float - startTimeInt) < curOffsetXti){
            continue;
        };
        if((i_float - startTimeInt) > (curOffsetXti + viewPortWidth * tiPerPx)){
            break;
        };
        
        if(numOfVerticalGridLines==0){
            firstGridLineX = ((i_float - startTimeInt) - curOffsetXti) / tiPerPx;
            verticalGridTimeStep = timeStep;
        };

        glPushMatrix();
        glTranslatef(minX + ((i_float - startTimeInt) - curOffsetXti) / tiPerPx, 0.0, 0.0);
        glDrawArrays(GL_POINTS, 0, curPointI);
        glPopMatrix();
        
        numOfVerticalGridLines++;
    };
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_LINE_WIDTH);
    
    // Translate & scale for current view
    //glPushMatrix();
    //glScalef(xScale.curPos, yScale.curPos, 1.0);
    //glTranslatef(xAxisOffset.curPos, 0.0, 0.0);
    
    
    
    // Drawing trend and forecast lines
    glPopMatrix();
    
    std::vector<vec2> trendLine;
    trendLine.clear();
    color blackColor(0.0, 0.0, 0.0, 1.0);
    std::list<WeightControlDataRecord>::const_iterator plotDataIterator;
    glEnableClientState(GL_VERTEX_ARRAY);
    
    float curTi;
    for(plotDataIterator=plotData.begin(); plotDataIterator!=plotData.end(); plotDataIterator++){
        curTi = (*plotDataIterator).timeInterval;
        curPoint.x = (GetXForTimeInterval(curTi) + xAxisOffset.curPos) * xScale.curPos;
        curPoint.y = GetYForWeight((*plotDataIterator).trend) * yScale.curPos;
        trendLine.push_back(curPoint);
    }
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_LINE_WIDTH);
    glColor4f(drawSet.trendLineColor.r, drawSet.trendLineColor.g, drawSet.trendLineColor.b, drawSet.trendLineColor.a);
    glVertexPointer(2, GL_FLOAT, sizeof(vec2), &trendLine[0].x);
    glLineWidth(drawSet.trendLineWidth);
    glDrawArrays(GL_LINE_STRIP, 0, trendLine.size());
    
    
    if(!std::isnan(forecastTimeInt) && plotData.size()>1){
        std::vector<vec2> forecastLine;
        
        glLineWidth(drawSet.forecastLineWidth);
        glColor4f(drawSet.forecastLineColor.r, drawSet.forecastLineColor.g, drawSet.forecastLineColor.b, drawSet.forecastLineColor.a);
        
        forecastLine.clear();
        plotDataIterator = plotData.end();
        plotDataIterator--;
        float lastTrend = (*plotDataIterator).trend;
        float lastTimeInt = (*plotDataIterator).timeInterval;
        
        if((curOffsetXti + viewPortWidth * tiPerPx) >= (lastTimeInt - startTimeInt)){
            for(i_float=lastTimeInt+5*tiPerPx, i=0; i_float<=lastTimeInt+forecastTimeInt; i_float += (20*tiPerPx)){
                if((i_float - startTimeInt) < curOffsetXti){
                    continue;
                };
                if((i_float - startTimeInt) > (curOffsetXti + viewPortWidth * tiPerPx)){
                    break;
                };
                
                curPoint.x = (GetXForTimeInterval(i_float) + xAxisOffset.curPos) * xScale.curPos;
                curPoint.y = GetYForWeight(lastTrend - ((i_float-lastTimeInt)*(lastTrend-aimWeight))/forecastTimeInt) * yScale.curPos;
                forecastLine.push_back(curPoint);
                curPoint.x = (GetXForTimeInterval(i_float + 15*tiPerPx) + xAxisOffset.curPos) * xScale.curPos;
                curPoint.y = GetYForWeight(lastTrend - ((i_float + 15*tiPerPx - lastTimeInt)*(lastTrend-aimWeight))/forecastTimeInt)*yScale.curPos;
                forecastLine.push_back(curPoint);
                
                
                glVertexPointer(2, GL_FLOAT, sizeof(vec2), &forecastLine[i*2].x);
                glDrawArrays(GL_LINES, 0, 2);
                
                i++;
            };
        };
        //printf("\n\n");
    };
    
    glDisableClientState(GL_LINE_WIDTH);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    // Drawing points and weight deviation lines
    std::vector<vec2> weightDeviationLine;
    color weightPointColor;
    for(plotDataIterator=plotData.begin(),i=0; plotDataIterator!=plotData.end(); plotDataIterator++,i++){
        if(((*plotDataIterator).timeInterval - startTimeInt) < curOffsetXti){
            continue;
        };
        if(((*plotDataIterator).timeInterval - startTimeInt) > (curOffsetXti + viewPortWidth * tiPerPx)){
            break;
        };

        weightDeviationLine.clear();
        weightDeviationLine.push_back(trendLine[i]);
        curPoint.x = trendLine[i].x;
        curPoint.y = GetYForWeight((*plotDataIterator).weight) * yScale.curPos;
        weightDeviationLine.push_back(curPoint);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_LINE_WIDTH);
        //glColor4f(1.0, 0.0, 0.0, 1.0);
        glVertexPointer(2, GL_FLOAT, sizeof(vec2), &weightDeviationLine[0].x);
        if((*plotDataIterator).weight > (*plotDataIterator).trend){
           glColor4f(drawSet.positiveDeviationLineColor.r, drawSet.positiveDeviationLineColor.g, drawSet.positiveDeviationLineColor.b, drawSet.positiveDeviationLineColor.a);
            weightPointColor = drawSet.positiveDeviationPointColor;
        }else{
            glColor4f(drawSet.negativeDeviationLineColor.r, drawSet.negativeDeviationLineColor.g, drawSet.negativeDeviationLineColor.b, drawSet.negativeDeviationLineColor.a);
            weightPointColor = drawSet.negativeDeviationPointColor;
        }
        glLineWidth(drawSet.deviationLinesWidth);
        glDrawArrays(GL_LINES, 0, weightDeviationLine.size());
        glDisableClientState(GL_LINE_WIDTH);
        glDisableClientState(GL_VERTEX_ARRAY);
        
        if(tiPerPx<5800){
            weightPointColor.a = FadeValue(tiPerPx, 5000.0, 800.0, 1.0, 0.0);
            blackColor.a = weightPointColor.a;
            //printf("X = %.0f, alpha: %.2f\n", tiPerPx, weightPointColor.w);
            DrawCircle(curPoint, (maxX-minX)*0.007, blackColor, true, weightPointColor);
        };
        
    }
    
    glPopMatrix();
    
    
    // Drawing aim and normal weight
    std::vector<vec2> aimLine;
    std::vector<vec2> normLine;
    aimLine.clear();
    normLine.clear();
    vec2 curPoint2;
    curPoint.y = GetYForWeight(aimWeight);
    curPoint2.y = GetYForWeight(normWeight);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_LINE_WIDTH);
    for(i_float=minX, i=0; i_float<maxX-(maxX-minX)*0.1; i_float += 15, i++){
        curPoint.x = i_float;
        curPoint2.x = i_float;
        aimLine.push_back(curPoint);
        normLine.push_back(curPoint2);
        curPoint.x += 10;
        curPoint2.x += 10;
        aimLine.push_back(curPoint);
        normLine.push_back(curPoint2);
        
        glColor4f(drawSet.aimLineColor.r, drawSet.aimLineColor.g, drawSet.aimLineColor.b, drawSet.aimLineColor.a);
        glLineWidth(drawSet.aimLineWidth);
        glVertexPointer(2, GL_FLOAT, 0, &aimLine[i*2].x);
        glDrawArrays(GL_LINES, 0, 2);
        glColor4f(drawSet.normLineColor.r, drawSet.normLineColor.g, drawSet.normLineColor.b, drawSet.normLineColor.a);
        glLineWidth(drawSet.normLineWidth);
        glVertexPointer(2, GL_FLOAT, 0, &normLine[i*2].x);
        glDrawArrays(GL_LINES, 0, 2);
        
    }
    glDisableClientState(GL_LINE_WIDTH);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    
    
    // Drawing vertical axis
    std::vector<vec2> yAxisLines;
    yAxisLines.clear();
    
    float yAxisWidth = (maxX - minX) * drawSet.verticalAxisWidth;
    float xAxisWidth = (maxX - minX) * drawSet.horizontalAxisHeight;
    
    curPoint.x = minX;
    curPoint.y = minY + (xAxisWidth / 2.0);
    yAxisLines.push_back(curPoint);
    curPoint.x += yAxisWidth;
    yAxisLines.push_back(curPoint);
    curPoint.y = maxY;
    yAxisLines.push_back(curPoint);
    curPoint.x = minX;
    yAxisLines.push_back(curPoint);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glVertexPointer(2, GL_FLOAT, 0, &yAxisLines[0].x);
    glColor4f(drawSet.verticalAxisColor.r, drawSet.verticalAxisColor.g, drawSet.verticalAxisColor.b, drawSet.verticalAxisColor.a);
    glDrawArrays(GL_TRIANGLE_FAN, 0, yAxisLines.size());
    
    glDisableClientState(GL_VERTEX_ARRAY);
    
    
    // Drawing horizontal axis
    std::vector<vec2> xAxisLines;
    xAxisLines.clear();
    
    curPoint.x = minX;
    curPoint.y = minY;
    xAxisLines.push_back(curPoint);
    curPoint.y += xAxisWidth/2;
    xAxisLines.push_back(curPoint);
    curPoint.x = maxX;
    xAxisLines.push_back(curPoint);
    curPoint.y = minY;
    xAxisLines.push_back(curPoint);
    
    curPoint.x = minX;
    curPoint.y = minY+xAxisWidth/2;
    xAxisLines.push_back(curPoint);
    curPoint.x = maxX;
    xAxisLines.push_back(curPoint);
    curPoint.y = minY+xAxisWidth;
    xAxisLines.push_back(curPoint);
    curPoint.x = minX;
    xAxisLines.push_back(curPoint);
    
    
    // bottom x-axis
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, &xAxisLines[0].x);
    glColor4f(drawSet.horizontalAxisBottomColor.r, drawSet.horizontalAxisBottomColor.g, drawSet.horizontalAxisBottomColor.b, drawSet.horizontalAxisBottomColor.a);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glEnableClientState(GL_LINE_WIDTH);
    glLineWidth(drawSet.horizontalAxisInterLineWidth);
    glColor4f(drawSet.horizontalAxisLinesColor.r, drawSet.horizontalAxisLinesColor.g, drawSet.horizontalAxisLinesColor.b, drawSet.horizontalAxisLinesColor.a);
    glDrawArrays(GL_LINES, 4, 2);
    
    // top x-axis
    glVertexPointer(2, GL_FLOAT, 0, &xAxisLines[4].x);
    glColor4f(drawSet.horizontalAxisTopColor.r, drawSet.horizontalAxisTopColor.g, drawSet.horizontalAxisTopColor.b, FadeValue(tiPerPx, 38000, 4000, drawSet.horizontalAxisTopColor.a, 0.0));
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glEnableClientState(GL_LINE_WIDTH);
    glLineWidth(drawSet.horizontalAxisTopLineWidth);
    glColor4f(drawSet.horizontalAxisLinesColor.r, drawSet.horizontalAxisLinesColor.g, drawSet.horizontalAxisLinesColor.b, FadeValue(tiPerPx, 38000, 4000, drawSet.horizontalAxisLinesColor.a, 0.0));
    glDrawArrays(GL_LINES, 2, 2);
    
    
    
    
    
    
/*    xAxisLines[1].x = minX;
    
    glColor4f(0.0, 0.0, 0.0, FadeValue(tiPerPx, 38000, 5000, 1.0, 0.0));
    glLineWidth(2.0);
    glDrawArrays(GL_LINES, 1, 2);
    glLineWidth(2.0);
    glColor4f(0.0, 0.0, 0.0, 1.0);
    glDrawArrays(GL_LINES, 4, 2);*/
    glDisableClientState(GL_LINE_WIDTH);
    glDisableClientState(GL_VERTEX_ARRAY);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_BLEND);
    
    
};

void WeightControlPlotRenderEngineGLES1::DrawCircle(vec2 center, float r, color circleColor, bool isFill, color fillColor){
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
        //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        glColor4f(fillColor.r, fillColor.g, fillColor.b, fillColor.a);
        //glLineWidth(1.0);
        glDrawArrays(GL_TRIANGLE_FAN, 0, segments);
        
        //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    };
    glColor4f(circleColor.r, circleColor.g, circleColor.b, circleColor.a);
    glLineWidth(2.0);
    glDrawArrays(GL_LINE_LOOP, 0, segments);
    
    glPopMatrix();
    
    glDisableClientState(GL_LINE_WIDTH);
    glDisableClientState(GL_VERTEX_ARRAY);
};

float WeightControlPlotRenderEngineGLES1::FadeValue(float x, float limit, float dist, float y0, float y1){
    if(x<=limit) return y0;
    if(x>limit+dist) return y1;
    
    return ((x-limit)*(y1-y0) + dist*y0) / dist;
};