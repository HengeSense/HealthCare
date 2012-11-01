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
#include "Vector.hpp"

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

struct WeightControlPlotDrawSettings{
    // color settings
    color backgroundColor;
    color gridLinesColor;
    color verticalAxisColor;
    color horizontalAxisTopColor;
    color horizontalAxisBottomColor;
    color horizontalAxisLinesColor;
    color verticalAxisLabelsColor;
    color horizontalAxisLabelsColor;
    color trendLineColor;
    color forecastLineColor;
    color positiveDeviationLineColor;
    color positiveDeviationPointColor;
    color negativeDeviationLineColor;
    color negativeDeviationPointColor;
    color aimLineColor;
    color aimLabelColor;
    color normLineColor;
    color normLabelColor;
    
    // line width settings
    float gridLinesWidth;
    float trendLineWidth;
    float forecastLineWidth;
    float deviationLinesWidth;
    float aimLineWidth;
    float normLineWidth;
    float horizontalAxisInterLineWidth;
    float horizontalAxisTopLineWidth;
    
    // zones sizes in view port's width/height percents
    float verticalAxisWidth;
    float horizontalAxisHeight;
    
    // X-labeling behaviour settings
    float minTiPerPx;
    float maxTiPerPx;
    float minTiPerPxForWeekDivision;
    float minTiPerPxForMonthDivision;
    float minTiPerPxForYearDivision;
    
    // Y-labeling behaviour settings
    float expandYaxisAtTop; // in percents view ports's height
    float expandYaxisAtBottom; // in percents
    
    // Other settings
    float xAxisExtendInterval;
    
    void ApplyStandartSettings(){
        backgroundColor.set(0.2f, 0.2f, 0.2f, 0.0);
        gridLinesColor.set(0.5, 0.5, 0.5, 0.5);
        verticalAxisColor.set(0.0, 0.0, 0.0, 0.3);
        horizontalAxisTopColor.set(0.15, 0.15, 0.15, 0.9);
        horizontalAxisBottomColor.set(0.15, 0.15, 0.15, 0.9);
        horizontalAxisLinesColor.set(0.0, 0.0, 0.0, 1.0);
        verticalAxisLabelsColor.set(0.5, 0.5, 0.5, 1.0);
        horizontalAxisLabelsColor.set(0.5, 0.5, 0.5, 1.0);
        trendLineColor.set(1.0, 0.0, 0.0, 0.7);
        forecastLineColor.set(1.0, 0.0, 0.0, 0.7);
        positiveDeviationLineColor.set(1.0, 0.0, 0.0, 0.5);
        positiveDeviationPointColor.set(1.0, 0.0, 0.0, 1.0);
        negativeDeviationLineColor.set(0.0, 1.0, 0.0, 0.5);
        negativeDeviationPointColor.set(0.0, 1.0, 0.0, 1.0);
        aimLineColor.set(0.0, 1.0, 0.0, 1.0);
        aimLabelColor.set(0.0, 1.0, 0.0, 0.8);
        normLineColor.set(0.0, 0.0, 1.0, 1.0);
        normLabelColor.set(0.0, 0.0, 1.0, 0.8);
        
        gridLinesWidth = 1.0;
        trendLineWidth = 4.0;
        forecastLineWidth = 2.0;
        deviationLinesWidth = 1.0;
        aimLineWidth = 2.0;
        normLineWidth = 2.0;
        horizontalAxisInterLineWidth = 1.0;
        horizontalAxisTopLineWidth = 2.0;
        
        verticalAxisWidth = 0.1;
        horizontalAxisHeight = 0.12;
        
        minTiPerPx = 150.0;
        maxTiPerPx = 400000.0;
        minTiPerPxForWeekDivision = 1700.0;
        minTiPerPxForMonthDivision = 6000.0;
        minTiPerPxForYearDivision = 40000.0;
        
        expandYaxisAtTop = 0.05;
        expandYaxisAtBottom = 0.15;
        
        xAxisExtendInterval = 3*30*60*60*24;

    }
};

class WeightControlPlotRenderEngine{
public:
    // Initialize with frame size
    virtual void Initialize(int width, int height) = 0;
    virtual GLuint GetRenderbuffer() = 0;
    
    // draw settings
    virtual void SetDrawSettings(WeightControlPlotDrawSettings _drawSettings) = 0;
    virtual WeightControlPlotDrawSettings *GetDrawSettings() = 0;
    
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
    virtual void SetTimeIntervalInCenter(float _timeInt, float animationDuration = 0.0) = 0;
    virtual void SetOffsetPixels(float _xOffsetPx, float animationDuration = 0.0) = 0;
    virtual void SetOffsetPixelsDecelerating(float _xOffsetPx, float animationDuration) = 0;
    
    // Scale functions (this inplementation uses X-scale only)
    // Y-scale (weight range) changed only with SetYAxisParams
    virtual void SetScaleX(float _scaleX, float animationDuration = 0.0) = 0;
    virtual void SetTiPerPx(float _tiPerPx, float animationDuration = 0.0) = 0;
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
