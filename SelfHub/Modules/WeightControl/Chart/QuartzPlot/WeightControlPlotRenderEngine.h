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

struct WeightControlDataRecord{
    float timeInterval;
    float weight;
};

class WeightControlPlotRenderEngine{
public:
    virtual void Initialize(int width, int height) = 0;
    virtual void SetDataArray(std::vector<WeightControlDataRecord> _dataArray) = 0;
    virtual void SetYAxisParams(float _minWeight, float _maxWeight, float _weightLinesStep, bool isAnimate) = 0;
    virtual void SetXAxisParams(float _timeDimension) = 0;
    
    virtual void Render() const = 0;
    virtual void UpdateAnimation(float timeStep) = 0;
    
    virtual ~WeightControlPlotRenderEngine() {};
};

WeightControlPlotRenderEngine *CreateRendererForGLES1();



#endif
