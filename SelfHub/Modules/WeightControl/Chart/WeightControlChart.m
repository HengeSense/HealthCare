//
//  WeightControlChart.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlChart.h"
#import "Flurry.h"
//#import "WeightControlQuartzPlot.h"

//@interface WeightControlChart ()
//
//@end

@implementation WeightControlChart

@synthesize delegate;
@synthesize addRecordView;
@synthesize weightGraph;
@synthesize plotView;
@synthesize statusBarTrendLabel, statusBarTrendValueLabel, statusBarBMILabel, statusBarBMIStatusSmoothLabel;
@synthesize statusBarWeekTrendLabel, statusBarWeekTrendValueLabel;
@synthesize statusBarForecastLabel, statusBarForecastSmoothLabel, statusBarKcalDayLabel;
@synthesize statusBarAimLabel, statusBarAimValueSmoothLabel, statusBarExpectedAimLabel, statusBarExpectedAimValueLabel;


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
    //NSLog(@"Screen bounds: %.0fx%.0f", screenBounds.size.width, screenBounds.size.height);
    
    float plotHeight = plotView.frame.size.height;
    if(screenBounds.size.height/screenBounds.size.width != 1.5){
        plotHeight += (568.0-480.0);
    };
    CGRect plotFrame = CGRectMake(0, 0, plotView.frame.size.width, plotHeight);
    weightGraph = [[WeightControlQuartzPlot alloc] initWithFrame:plotFrame andDelegate:delegate];
    [plotView addSubview:weightGraph];
    [weightGraph showLastDays];
    
    
    addRecordView.viewControllerDelegate = self;
    [self.view addSubview:addRecordView];
    
    
    UILabel *cancelLabel = [[UILabel alloc] initWithFrame:addRecordView.cancelButton.bounds];
    cancelLabel.backgroundColor = [UIColor clearColor];
    cancelLabel.textAlignment = NSTextAlignmentCenter;
    cancelLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    cancelLabel.shadowColor = [UIColor blackColor];
    cancelLabel.shadowOffset = CGSizeMake(0, 0.5);
    cancelLabel.textColor = [UIColor colorWithRed:121.0/255.0 green:119.0/255.0 blue:128.0/255.0 alpha:1.0];
    cancelLabel.highlightedTextColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:0.35];
    cancelLabel.text = NSLocalizedString(@"Cancel", @"");
    [addRecordView.cancelButton addSubview:cancelLabel];
    [cancelLabel release];
    
    UILabel *continueLabel = [[UILabel alloc] initWithFrame:addRecordView.okButton.bounds];
    continueLabel.backgroundColor = [UIColor clearColor];
    continueLabel.textAlignment = NSTextAlignmentCenter;
    continueLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    continueLabel.shadowColor = [UIColor blackColor];
    continueLabel.shadowOffset = CGSizeMake(0, 0.5);
    continueLabel.textColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:1.0];
    continueLabel.highlightedTextColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:0.35];
    continueLabel.text = NSLocalizedString(@"Continue", @"");
    [addRecordView.okButton addSubview:continueLabel];
    [continueLabel release];
    
    [self updateGraphStatusLines];
    
};

-(void)dealloc{
    [plotView release];

    [statusBarTrendLabel release];
    [statusBarTrendValueLabel release];
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
    [statusBarExpectedAimValueLabel release];
    
    [super dealloc];
};

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
    [weightGraph redrawPlot];
    [self updateGraphStatusLines];
    [weightGraph.glContentView setRedrawOpenGLPaused:NO];
    
    //[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
};

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [weightGraph.glContentView setRedrawOpenGLPaused:YES];
    
    //[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //NSLog(@"LAYOUTING...");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [weightGraph.glContentView reallocCache];
};

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
    //[sender release];
    //[sender release];
    //[NSException raise:NSInvalidArgumentException format:@"It's my message!"];
    
    addRecordView.curWeight = [self getTodaysWeightState];
    addRecordView.datePicker.date = [NSDate date];
    
    MainInformation *antropometryController = (MainInformation *)[delegate.delegate getViewControllerForModuleWithID:@"selfhub.antropometry"];
    if(antropometryController!=nil){
        addRecordView.rulerScrollView.minWeightKg = [antropometryController getMinWeightKg];
        addRecordView.rulerScrollView.maxWeightKg = [antropometryController getMaxWeightKg];
        addRecordView.rulerScrollView.stepWeightKg = [antropometryController getWeightPickerStep];
        addRecordView.rulerScrollView.weightFactor = [antropometryController getWeightFactor];
    }else{
        addRecordView.rulerScrollView.minWeightKg = 30.0;
        addRecordView.rulerScrollView.maxWeightKg = 300.0;
        addRecordView.rulerScrollView.stepWeightKg = 0.1;
        addRecordView.rulerScrollView.weightFactor = 1.0;
    };
    
    //[self.view bringSubviewToFront:addRecordView];
    //NSLog(@"Add Record View frme: %.0f, %.0f, %.0f, %.0f", addRecordView.frame.origin.x, addRecordView.frame.origin.y, addRecordView.frame.size.width, addRecordView.frame.size.height);
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
    //float normWeight = (delegate.normalWeight==nil ? 0.0 : [delegate.normalWeight floatValue]);
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
    
    NSString *statusStrForBMI = NSLocalizedString(@"unknown", @"");
    WeightControlChartSmoothLabelColor labelColor = WeightControlChartSmoothLabelColorRed;
    if(BMI>0.0 && BMI<15.0){
        statusStrForBMI = NSLocalizedString(@"exhaustion", @"");
        labelColor = WeightControlChartSmoothLabelColorRed;
    }else if(BMI>=15.0 && BMI<16.0){
        statusStrForBMI = NSLocalizedString(@"sev.underweight", @"");
        labelColor = WeightControlChartSmoothLabelColorRed;
    }else if(BMI>=16.0 && BMI<18.5){
        statusStrForBMI = NSLocalizedString(@"underweight", @"");
        labelColor = WeightControlChartSmoothLabelColorYellow;
    }else if(BMI>=18.5 && BMI<25.0){
        statusStrForBMI = NSLocalizedString(@"normal", @"");
        labelColor = WeightControlChartSmoothLabelColorGreen;
    }else if(BMI>=25.0 && BMI<30.0){
        statusStrForBMI = NSLocalizedString(@"overweight", @"");
        labelColor = WeightControlChartSmoothLabelColorYellow;
    }else if(BMI>=30.0 && BMI<35.0){
        statusStrForBMI = NSLocalizedString(@"obese cl.I", @"");
        labelColor = WeightControlChartSmoothLabelColorYellow;
    }else if(BMI>=35.0 && BMI<40.0){
        statusStrForBMI = NSLocalizedString(@"obese cl.II", @"");
        labelColor = WeightControlChartSmoothLabelColorRed;
    }else if(BMI>=40){
        statusStrForBMI = NSLocalizedString(@"obese cl.III", @"");
        labelColor = WeightControlChartSmoothLabelColorRed;
    };
    
    
    
    
    statusBarTrendLabel.text = NSLocalizedString(@"Trend:", @"");
    statusBarTrendValueLabel.text = isnan(endTrend) ? NSLocalizedString(@"unknown", @"") : [delegate getWeightStrForWeightInKg:endTrend withUnit:YES];
    statusBarBMILabel.text = isnan(BMI) ? @"BMI: 0.0" : [NSString stringWithFormat:NSLocalizedString(@"BMI: %.1f", @""), BMI];
    [statusBarBMIStatusSmoothLabel setText:statusStrForBMI];
    [statusBarBMIStatusSmoothLabel setColor:labelColor];
    
    float xCoord = self.view.frame.size.width - statusBarBMIStatusSmoothLabel.frame.size.width-5.0;
    CGRect newRect = statusBarBMIStatusSmoothLabel.frame;
    newRect.origin.x = xCoord;
    statusBarBMIStatusSmoothLabel.frame = newRect;
    
    xCoord -= (statusBarBMILabel.frame.size.width+10.0);
    newRect = statusBarBMILabel.frame;
    newRect.origin.x = xCoord;
    statusBarBMILabel.frame = newRect;
    //NSLog(@"STATUS BMI WIDTH: %.0f", statusBarBMIStatusSmoothLabel.frame.size.width);
    
    
    statusBarWeekTrendLabel.text = NSLocalizedString(@"Week tendentious:", @"");
    statusBarWeekTrendValueLabel.text = isnan(weekTrend) ? NSLocalizedString(@"unknown", @"") : [delegate getWeightStrForWeightInKg:weekTrend withUnit:YES];
    
    statusBarForecastLabel.text = NSLocalizedString(@"Forecast:", @"");
    if(isnan(weekForecast)){
        [statusBarForecastSmoothLabel setText:NSLocalizedString(@"unknown", @"")];
        [statusBarForecastSmoothLabel setColor:WeightControlChartSmoothLabelColorRed];
        statusBarKcalDayLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@%@/week", @""), (weekForecast<0 ? @"" : @"+"), [delegate getWeightStrForWeightInKg:0.0 withUnit:YES]];
    }else{
        [statusBarForecastSmoothLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%@%@/week", @""), (weekForecast<0 ? @"" : @"+"), [delegate getWeightStrForWeightInKg:weekForecast withUnit:YES]]];
        [statusBarForecastSmoothLabel setColor:(weekForecast<0 ? WeightControlChartSmoothLabelColorGreen : WeightControlChartSmoothLabelColorRed)];
        statusBarKcalDayLabel.text = [NSString stringWithFormat:NSLocalizedString(@"(%@%.1f kcal/week)", @""), (weekForecast<0 ? @"" : @"+"), weekForecastCalories];
    };
    
    statusBarAimLabel.text = NSLocalizedString(@"Goal:", @"");
    if(isnan(aimWeight)){
        [statusBarAimValueSmoothLabel setText:NSLocalizedString(@"no aim", @"")];
        [statusBarAimValueSmoothLabel setColor:WeightControlChartSmoothLabelColorRed];
    }else{
        [statusBarAimValueSmoothLabel setText:[delegate getWeightStrForWeightInKg:aimWeight withUnit:YES]];
        [statusBarAimValueSmoothLabel setColor:WeightControlChartSmoothLabelColorGreen];
    };
    
    statusBarExpectedAimLabel.text = NSLocalizedString(@"Expected:", @"");
    if(isnan(timeToAim)){
        statusBarExpectedAimValueLabel.text = NSLocalizedString(@"unknown", @"");
    }else{
        statusBarExpectedAimValueLabel.text = [NSString stringWithFormat:@"%@", achieveAimDateStr];
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
    NSDate *newDate = [delegate getDateWithoutTime:[newRecord objectForKey:@"date"]];
    //NSLog(@"NEW DATE DESCRIPTION: %@", [newDate description]);
    NSNumber *newWeight = [newRecord objectForKey:@"weight"];
    NSComparisonResult compRes;
    int i;
    for(i=[delegate.weightData count]-1;i>=0;i--){
        NSDictionary *oneRec = [delegate.weightData objectAtIndex:i];
        compRes = [delegate compareDateByDays:newDate WithDate:[oneRec objectForKey:@"date"]];
        if(compRes==NSOrderedSame){
            [delegate.weightData removeObject:oneRec];  
            i--;
            break;
        };
        if(compRes==NSOrderedDescending){
            break;
        };
    };

    
    NSDictionary *newRec = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:newDate, newWeight, nil] forKeys:[NSArray arrayWithObjects:@"date", @"weight", nil]];
    [delegate.weightData insertObject:newRec atIndex:i+1];
    [delegate updateTrendsFromIndex:i+1];
    [delegate saveModuleData];
    
    [Flurry logEvent:@"WeightControl.new_record"];
    
    [self updateGraphStatusLines];
    [weightGraph redrawPlot];
};

- (void)pressCancelRecord{
    
};


@end
