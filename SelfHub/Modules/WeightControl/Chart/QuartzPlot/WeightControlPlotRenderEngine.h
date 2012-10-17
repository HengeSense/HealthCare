//
//  WeightControlRenderInterface.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 08.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef SelfHub_WeightControlRenderInterface_h
#define SelfHub_WeightControlRenderInterface_h

#include <vector>
#include <list>

struct WeightControlDataRecord{
    float timeInterval;
    float weight;
    float trend;
    WeightControlDataRecord(){
        timeInterval = 0;
        weight = 0;
        trend = 0;
    };
    WeightControlDataRecord(const WeightControlDataRecord &obj){
        timeInterval = obj.timeInterval;
        weight = obj.weight;
        trend = obj.trend;
    };
    
    void operator=(const WeightControlDataRecord obj){
        timeInterval = obj.timeInterval;
        weight = obj.weight;
        trend = obj.weight;
    };
};

class WeightControlPlotRenderEngine{
public:
    // Initialize with frame size
    virtual void Initialize(int width, int height) = 0;
    virtual GLuint GetRenderbuffer() = 0;
    
    // Paramaters for axises. Will affect for drawing grid.
    virtual void SetYAxisParams(float _minWeight, float _maxWeight, float _weightLinesStep, float animationDuration = 0.0) = 0;
    virtual void UpdateYAxisParams(float animationDuration = 0.0) = 0;
    virtual void UpdateYAxisParamsForOffsetAndScale(float _xOffset, float _xScale, float animationDuration = 0.0) = 0;
    virtual void SetXAxisParams(float _startTimeInt, float _finishTimeInt) = 0;  // sec/px
    virtual void GetYAxisDrawParams(float &_firstGridPt, float &_firstGridWeight, float &_gridLinesStep, float &_weightLinesStep, unsigned short &_linesNum) = 0;
    virtual void GetXAxisDrawParams(float &_firstGridXPt, float &_firstGridXTimeInterval, float &_gridXLinesStep, float &_timeIntLinesStep, unsigned short &_linesXNum) = 0;
    virtual float GetXAxisVisibleRectStart() = 0;
    virtual float GetXAxisVisibleRectEnd() = 0;
    
    // Functions for graph horizontal scrolling
    virtual void SetOffsetTimeInterval(float _xOffset, float animationDuration = 0.0) = 0;
    virtual void SetOffsetPixels(float _xOffsetPx, float animationDuration = 0.0) = 0;
    virtual void SetOffsetPixelsDecelerating(float _xOffsetPx, float animationDuration) = 0;
    
    // Scale functions (this inplementation uses X-scale only)
    // Y-scale (weight range) changed only with SetYAxisParams
    virtual void SetScaleX(float _scaleX, float animationDuration = 0.0) = 0;
    virtual void SetScaleY(float _scaleY, float animationDuration = 0.0) = 0;
    virtual float getCurScaleX() = 0;
    virtual float getCurScaleY() = 0;
    virtual float getCurOffsetX() = 0;
    virtual float getCurOffsetXForScale(float _aimXScale) = 0;
    virtual float getTimeIntervalPerPixel() = 0;
    virtual float getTimeIntervalPerPixelForScale(float _aimXScale) = 0;
    virtual float getMaxOffsetPx() = 0;
    virtual bool isPlotOutOfBoundsForOffsetAndScale(float _offsetX, float _scale) = 0;
    virtual float getPlotWidthPxForScale(float _scale) = 0;
    
    // Functions for navigations in graph field
    virtual float GetXForTimeInterval(float _timeInterval) = 0;
    virtual float GetYForWeight(float _weight) = 0;
    virtual float GetWeightIntervalForYinterval(float _yInterval) = 0;
    virtual float GetYIntervalForWeightInterval(float _weightInterval) = 0;
    
    // Actions with engine's weight base
    // Base will copy from WeightControl interface when module loaded
    // and all changes will be mirrored here
    virtual void SetDataBase(std::list<WeightControlDataRecord> _base) = 0;
    virtual void ClearDataBase() = 0;
    virtual void SetDataRecord(WeightControlDataRecord _record, unsigned int _pos) = 0;
    virtual void InsertDataRecord(WeightControlDataRecord _record, unsigned int _pos) = 0;
    virtual void DeleteDataRecord(unsigned int _pos) = 0;
    virtual void SetNormalWeight(float _normWeight) = 0;
    virtual float GetNormalWeight() = 0;
    virtual void SetAimWeight(float _aimWeight) = 0;
    virtual float GetAimWeight() = 0;
    virtual void SetForecastTimeInterval(float _forecastTimeInt) = 0;
    virtual float GetForecastTimeInterval() = 0;
    
    virtual float FadeValue(float x, float limit, float dist, float y0, float y1) = 0;
    
    // Render engine
    virtual void Render() = 0;
    virtual void UpdateAnimation(float timeStep) = 0;
    
    virtual ~WeightControlPlotRenderEngine() {};
};

WeightControlPlotRenderEngine *CreateRendererForGLES1();



#endif
