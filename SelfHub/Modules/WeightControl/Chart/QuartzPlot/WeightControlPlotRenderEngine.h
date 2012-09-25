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
    
    // Paramaters for axises. Will affect for drawing grid.
    virtual void SetYAxisParams(float _minWeight, float _maxWeight, float _weightLinesStep, float animationDuration = 0.0) = 0;
    virtual void UpdateYAxisParamsForOffsetAndScale(float _xOffset, float _xScale, float animationDuration = 0.0) = 0;
    virtual void SetXAxisParams(float _startTimeInt, float _finishTimeInt) = 0;  // sec/px
    
    // Functions for graph horizontal scrolling
    virtual void SetOffsetTimeInterval(float _xOffset, float animationDuration = 0.0) = 0;
    virtual void SetOffsetPixels(float _xOffsetPx, float animationDuration = 0.0) = 0;
    virtual void SmoothPanFinish(float finishVelocity) = 0;
    
    // Scale functions (this inplementation uses X-scale only)
    // Y-scale (weight range) changed only with SetYAxisParams
    virtual void SetScaleX(float _scaleX, float animationDuration = 0.0) = 0;
    virtual void SetScaleY(float _scaleY, float animationDuration = 0.0) = 0;
    virtual float getCurScaleX() = 0;
    virtual float getCurScaleY() = 0;
    virtual float getCurOffsetX() = 0;
    virtual float getCurOffsetXForScale(float _aimXScale) = 0;
    virtual float getTimeIntervalPerPixel() const = 0;
    virtual float getTimeIntervalPerPixelForScale(float _aimXScale) = 0;
    
    // Functions for navigations in graph field
    virtual float GetXForTimeInterval(float _timeInterval) const = 0;
    virtual float GetYForWeight(float _weight) const = 0;
    
    // Actions with engine's weight base
    // Base will copy from WeightControl interface when module loaded
    // and all changes will be mirrored here
    virtual void SetDataBase(std::list<WeightControlDataRecord> _base) = 0;
    virtual void ClearDataBase() = 0;
    virtual void SetDataRecord(WeightControlDataRecord _record, unsigned int _pos) = 0;
    virtual void InsertDataRecord(WeightControlDataRecord _record, unsigned int _pos) = 0;
    virtual void DeleteDataRecord(unsigned int _pos) = 0;
    
    
    // Render engine
    virtual void Render() const = 0;
    virtual void UpdateAnimation(float timeStep) = 0;
    
    virtual ~WeightControlPlotRenderEngine() {};
};

WeightControlPlotRenderEngine *CreateRendererForGLES1();



#endif
