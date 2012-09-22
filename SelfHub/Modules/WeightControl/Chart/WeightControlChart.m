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
@synthesize topGraphStatus, bottomGraphStatus;

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
    
    weightGraph = [[WeightControlQuartzPlot alloc] initWithFrame:CGRectMake(0.0, 24.0, 320.0, 388.0) andDelegate:delegate];
    [self.view addSubview:weightGraph];
    
    UIButton *addRecordButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addRecordButton.frame = CGRectMake(274.0, 20.0, 29.0, 29.0);
    [addRecordButton addTarget:self action:@selector(pressNewRecordButton:) forControlEvents:UIControlEventTouchDown];
    [weightGraph addSubview:addRecordButton];
    
    
    
    addRecordView.viewControllerDelegate = self;
    [self.view addSubview:addRecordView];
    
    [self updateGraphStatusLines];
    
};

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    topGraphStatus = nil;
    bottomGraphStatus = nil;

}

-(void)dealloc{
    [topGraphStatus release];
    [bottomGraphStatus release];
    
    [super dealloc];
};


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
    [weightGraph redrawPlot];
    [self updateGraphStatusLines];
    
};

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
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
    if(weightGraph.glContentView !=nil){
        [weightGraph.glContentView _testHorizontalLinesAnimating];
        return;
    }
    
    addRecordView.curWeight = [self getTodaysWeightState];
    addRecordView.datePicker.date = [NSDate date];
    
    [addRecordView showView];
}


- (IBAction)pressScaleButton:(id)sender{
    NSLog(@"WeightControlChart: scaleButtonPressed - tag = %d", [sender tag]);
};

- (void)updateGraphStatusLines{
    float BMI = [delegate getBMI];
    float normWeight = (delegate.normalWeight==nil ? 0.0 : [delegate.normalWeight floatValue]);
    float deltaWeight;
    if([delegate.weightData count]>0 && fabs(normWeight)>0.0001){
        [[[delegate.weightData lastObject] objectForKey:@"weight"] floatValue];
        deltaWeight = [[[delegate.weightData lastObject] objectForKey:@"weight"] floatValue] - normWeight;
    }else{
        deltaWeight = 0.0;
    };
    float aimWeight = (delegate.aimWeight==nil ? 0.0 : [delegate.aimWeight floatValue]);
    NSTimeInterval timeToAim = [delegate getTimeIntervalToAim];
    NSString *forecastStr = isnan(timeToAim) ? @"unknown" : [NSString stringWithFormat:@"%d", (NSUInteger)(timeToAim/(60*60*24))];
    
    topGraphStatus.text = [NSString stringWithFormat:@"BMI = %.1f, normal weight = %.1f kg (%@%.1f kg)", BMI, normWeight, (deltaWeight<0.0 ? @"-" : @"+"), fabs(deltaWeight)];
    bottomGraphStatus.text = [NSString stringWithFormat:@"Aim: %.1f kg, days to achieve aim: %@", aimWeight, forecastStr];
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
