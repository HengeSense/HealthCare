//
//  WeightControlChart.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlChart.h"
//#import "WeightControlQuartzPlot.h"

//@interface WeightControlChart ()
//
//@end

@implementation WeightControlChart

@synthesize delegate;
@synthesize addRecordView;
@synthesize weightGraph;
@synthesize plotView;
@synthesize statusBarTrendLabel, statusBarBMILabel, statusBarBMIStatusSmoothLabel;
@synthesize statusBarWeekTrendLabel, statusBarWeekTrendValueLabel;
@synthesize statusBarForecastLabel, statusBarForecastSmoothLabel, statusBarKcalDayLabel;
@synthesize statusBarAimLabel, statusBarAimValueSmoothLabel, statusBarExpectedAimLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSLog(@"Screen bounds: %.0fx%.0f", screenBounds.size.width, screenBounds.size.height);
    
    float plotHeight = plotView.frame.size.height;
    if(screenBounds.size.height/screenBounds.size.width != 1.5){
        plotHeight += (568.0-480.0);
    };
    CGRect plotFrame = CGRectMake(0, 0, plotView.frame.size.width, plotHeight);
    weightGraph = [[WeightControlQuartzPlot alloc] initWithFrame:plotFrame andDelegate:delegate];
    [plotView addSubview:weightGraph];
    
    
    addRecordView.viewControllerDelegate = self;
    [self.view addSubview:addRecordView];
    
    [self updateGraphStatusLines];
    
};

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    plotView = nil;
    statusBarTrendLabel = nil;
    statusBarBMILabel = nil;
    statusBarBMIStatusSmoothLabel = nil;
    statusBarWeekTrendLabel = nil;
    statusBarWeekTrendValueLabel = nil;
    statusBarForecastLabel = nil;
    statusBarForecastSmoothLabel = nil;
    statusBarKcalDayLabel = nil;
    statusBarAimLabel = nil;
    statusBarAimValueSmoothLabel = nil;
    statusBarExpectedAimLabel = nil;
}

-(void)dealloc{
    [plotView release];

    [statusBarTrendLabel release];
    [statusBarBMILabel release];
    [statusBarBMIStatusSmoothLabel release];
    [statusBarWeekTrendLabel release];
    [statusBarWeekTrendValueLabel release];
    [statusBarForecastLabel release];
    [statusBarForecastSmoothLabel release];
    [statusBarKcalDayLabel release];
    [statusBarAimLabel release];
    [statusBarAimValueSmoothLabel release];
    [statusBarExpectedAimLabel release];
    
    [super dealloc];
};


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
    [weightGraph redrawPlot];
    [self updateGraphStatusLines];
    [weightGraph.glContentView setRedrawOpenGLPaused:NO];
    
};

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [weightGraph.glContentView setRedrawOpenGLPaused:YES];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //NSLog(@"LAYOUTING...");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pressDefault{
    //[weightGraph testPixel];
    
    [delegate fillTestData:50];
    [weightGraph redrawPlot];
};

- (float)getTodaysWeightState{
    NSNumber *weightFromAntropometry = [delegate.delegate getValueForName:@"weight" fromModuleWithID:@"selfhub.antropometry"];
    NSDate *lastRecordDate = [[delegate.weightData lastObject] objectForKey:@"date"];
    if(lastRecordDate==nil){
        if(weightFromAntropometry==nil){
            return 75.0;
        }else{
            return [weightFromAntropometry floatValue];
        };
    }else{
        NSNumber *lastRecordWeight = [[delegate.weightData lastObject] objectForKey:@"weight"];
        return [lastRecordWeight floatValue];
    };

};

- (IBAction)pressNewRecordButton:(id)sender{
    //if(weightGraph.glContentView !=nil){
    //    [weightGraph.glContentView _testHorizontalLinesAnimating];
    //    return;
    //}
    
    addRecordView.curWeight = [self getTodaysWeightState];
    //NSLog(@"getTodayWeight: %.2f kg", addRecordView.curWeight);
    addRecordView.datePicker.date = [NSDate date];
    
    [addRecordView showView];
}


- (IBAction)pressScaleButton:(id)sender{
    NSLog(@"WeightControlChart: scaleButtonPressed - tag = %d", [sender tag]);
};

- (float)getRecordValueAtTimeInterval:(NSTimeInterval)needInterval forKey:(NSString *)key{
    float needWeight = 0.0;
    NSDictionary *oneRecord = nil;
    NSUInteger i;
    NSTimeInterval testedTimeInt;
    float w1, w2;
    for(i=0;i<[delegate.weightData count]-1;i++){
        oneRecord = [delegate.weightData objectAtIndex:i];
        testedTimeInt = [[oneRecord objectForKey:@"date"] timeIntervalSince1970];
        NSDictionary *nextRecord = [delegate.weightData objectAtIndex:i+1];
        NSTimeInterval nextTimeInt = [[nextRecord objectForKey:@"date"] timeIntervalSince1970];
        if(needInterval>=testedTimeInt && needInterval<=nextTimeInt){
            if(i<[delegate.weightData count]-1){
                w1 = [[oneRecord objectForKey:key] floatValue];
                w2 = [[nextRecord objectForKey:key] floatValue];
                needWeight = w1 + (((needInterval - testedTimeInt) * (w2 - w1)) / (nextTimeInt - testedTimeInt));
                break;
            };
        };
    };
    
    return needWeight;
};


- (void)updateGraphStatusLines{
    float BMI = [delegate getBMI];
    float normWeight = (delegate.normalWeight==nil ? 0.0 : [delegate.normalWeight floatValue]);
    float aimWeight = (delegate.aimWeight==nil ? 0.0 : [delegate.aimWeight floatValue]);
    
    //Calcing week tendention
    float weekTrend = NAN;
    float endTrend = NAN;
    if([delegate.weightData count]>0){
        NSTimeInterval startTimeInterval = [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
        NSTimeInterval lastTimeInterval = [[[delegate.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
        NSTimeInterval curTimeInterval = lastTimeInterval - 60*60*24*7;
        if(curTimeInterval<startTimeInterval) curTimeInterval = startTimeInterval;
        float startTrend = [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
        endTrend = [self getRecordValueAtTimeInterval:lastTimeInterval forKey:@"trend"];
        weekTrend = (endTrend - startTrend) / 1.0;
    };
    
    float weekForecast = [delegate getForecastTrendForWeek];
    float weekForecastCalories = weekForecast * 1100.0;
    
    NSTimeInterval timeToAim = [delegate getTimeIntervalToAim];
    NSString *achieveAimDateStr = @"unknown";
    if(!isnan(timeToAim)){
        NSDate *achieveDate = [NSDate dateWithTimeInterval:timeToAim sinceDate:[[delegate.weightData lastObject] objectForKey:@"date"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"dd.MM.YYYY";
        achieveAimDateStr = [dateFormat stringFromDate:achieveDate];
        [dateFormat release];
    };
    
    NSString *statusStrForBMI = @"unknown";
    WeightControlChartSmoothLabelColor labelColor = WeightControlChartSmoothLabelColorRed;
    if(BMI>0.0 && BMI<15.0){
        statusStrForBMI = @"exhaustion";
        labelColor = WeightControlChartSmoothLabelColorRed;
    }else if(BMI>=15.0 && BMI<16.0){
        statusStrForBMI = @"sev.underweight";
        labelColor = WeightControlChartSmoothLabelColorRed;
    }else if(BMI>=16.0 && BMI<18.5){
        statusStrForBMI = @"underweight";
        labelColor = WeightControlChartSmoothLabelColorYellow;
    }else if(BMI>=18.5 && BMI<25.0){
        statusStrForBMI = @"normal";
        labelColor = WeightControlChartSmoothLabelColorGreen;
    }else if(BMI>=25.0 && BMI<30.0){
        statusStrForBMI = @"overweight";
        labelColor = WeightControlChartSmoothLabelColorYellow;
    }else if(BMI>=30.0 && BMI<35.0){
        statusStrForBMI = @"obese cl.I";
        labelColor = WeightControlChartSmoothLabelColorYellow;
    }else if(BMI>=35.0 && BMI<40.0){
        statusStrForBMI = @"obese cl.II";
        labelColor = WeightControlChartSmoothLabelColorRed;
    }else if(BMI>=40){
        statusStrForBMI = @"obese cl.III";
        labelColor = WeightControlChartSmoothLabelColorRed;
    };
    
    
    
    statusBarTrendLabel.text = isnan(endTrend) ? @"Trend: unknown" : [NSString stringWithFormat:@"Trend: %.1f kg", endTrend];
    statusBarBMILabel.text = isnan(BMI) ? @"BMI: 0.0" : [NSString stringWithFormat:@"BMI: %.1f", BMI];
    [statusBarBMIStatusSmoothLabel setText:statusStrForBMI];
    [statusBarBMIStatusSmoothLabel setColor:labelColor];
    
    statusBarWeekTrendValueLabel.text = isnan(weekTrend) ? @"unknown" : [NSString stringWithFormat:@"%.1f kg", weekTrend];
    
    if(isnan(weekForecast)){
        [statusBarForecastSmoothLabel setText:@"unknown"];
        [statusBarForecastSmoothLabel setColor:WeightControlChartSmoothLabelColorRed];
        statusBarKcalDayLabel.text = @"(0.0 kg/week)";
    }else{
        [statusBarForecastSmoothLabel setText:[NSString stringWithFormat:@"%@%.1f kg/week", (weekForecast<0 ? @"" : @"+"), weekForecast]];
        [statusBarForecastSmoothLabel setColor:(weekForecast<0 ? WeightControlChartSmoothLabelColorGreen : WeightControlChartSmoothLabelColorRed)];
        statusBarKcalDayLabel.text = [NSString stringWithFormat:@"(%@%.1f kcal/week)", (weekForecast<0 ? @"" : @"+"), weekForecastCalories];
    };
    
    if(isnan(aimWeight)){
        [statusBarAimValueSmoothLabel setText:@"no aim"];
        [statusBarAimValueSmoothLabel setColor:WeightControlChartSmoothLabelColorRed];
    }else{
        [statusBarAimValueSmoothLabel setText:[NSString stringWithFormat:@"%.1f kg", aimWeight]];
        [statusBarAimValueSmoothLabel setColor:WeightControlChartSmoothLabelColorGreen];
    };
    
    if(isnan(timeToAim)){
        statusBarExpectedAimLabel.text = @"Expected: unknown";
    }else{
        statusBarExpectedAimLabel.text = [NSString stringWithFormat:@"Expected: %@", achieveAimDateStr];
    };
    
    
    
    //float deltaWeight;
    //if([delegate.weightData count]>0 && fabs(normWeight)>0.0001){
    //    [[[delegate.weightData lastObject] objectForKey:@"weight"] floatValue];
    //    deltaWeight = [[[delegate.weightData lastObject] objectForKey:@"weight"] floatValue] - normWeight;
    //}else{
    //    deltaWeight = 0.0;
    //};
    //NSTimeInterval timeToAim = [delegate getTimeIntervalToAim];
    //NSString *forecastStr = isnan(timeToAim) ? @"unknown" : [NSString stringWithFormat:@"%d", (NSUInteger)(timeToAim/(60*60*24))];
    
    //topGraphStatus.text = [NSString stringWithFormat:@"BMI = %.1f, normal weight = %.1f kg (%@%.1f kg)", BMI, normWeight, (deltaWeight<0.0 ? @"-" : @"+"), fabs(deltaWeight)];
    //bottomGraphStatus.text = [NSString stringWithFormat:@"Aim: %.1f kg, days to achieve aim: %@", aimWeight, forecastStr];
    
};


#pragma mark - Add Record delegate

- (void)pressAddRecord:(NSDictionary *)newRecord{
    NSComparisonResult compRes;
    int i;
    for(i=[delegate.weightData count]-1;i>=0;i--){
        NSDictionary *oneRec = [delegate.weightData objectAtIndex:i];
        compRes = [delegate compareDateByDays:[newRecord objectForKey:@"date"] WithDate:[oneRec objectForKey:@"date"]];
        if(compRes==NSOrderedSame){
            [delegate.weightData removeObject:oneRec];  
            i--;
            break;
        };
        if(compRes==NSOrderedDescending){
            break;
        };
    };

    if([delegate compareDateByDays:[newRecord objectForKey:@"date"] WithDate:[NSDate date]] == NSOrderedSame){   //Setting weight in antropometry module
        [delegate.delegate setValue:[newRecord objectForKey:@"weight"] forName:@"weight" forModuleWithID:@"selfhub.antropometry"];
    }

    
    [delegate.weightData insertObject:newRecord atIndex:i+1];
    [delegate updateTrendsFromIndex:i+1];
    [delegate saveModuleData];
    
    [self updateGraphStatusLines];
    [weightGraph redrawPlot];
};

- (void)pressCancelRecord{
    
};


@end
