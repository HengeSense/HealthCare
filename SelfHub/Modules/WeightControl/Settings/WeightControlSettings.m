//
//  WeightControlSettings.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlSettings.h"

@interface WeightControlSettings ()

@end

@implementation WeightControlSettings

@synthesize delegate;
@synthesize aimLabel, rulerScroll, moduleSmoothLabel, heightLabel, ageLabel;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    delegate = nil;
    aimLabel = nil;
    rulerScroll = nil;
    moduleSmoothLabel = nil;
    heightLabel = nil;
    ageLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"Settings view will appear: weight = %.1f", [delegate.aimWeight floatValue]);
    aimLabel.text = isnan([delegate.aimWeight floatValue]) ? @"Current aim: not set" : [NSString stringWithFormat:@"Current aim: %.1f kg", [delegate.aimWeight floatValue]];
    [rulerScroll showWeight:[delegate.aimWeight floatValue]];
    
    UIViewController<ModuleProtocol> *antropometryController = (UIViewController<ModuleProtocol> *)[delegate.delegate getViewControllerForModuleWithID:@"selfhub.antropometry"];
    if(antropometryController!=nil){
        moduleSmoothLabel.text = [NSString stringWithFormat:@"%@ module", [antropometryController getModuleName]];
    };
    [moduleSmoothLabel setColor:WeightControlChartSmoothLabelColorYellow];
    
    
    NSNumber *length = [delegate.delegate getValueForName:@"length" fromModuleWithID:@"selfhub.antropometry"];
    if(length==nil){
        heightLabel.text = @"<unknown>";
    }else{
        heightLabel.text = [NSString stringWithFormat:@"%.0f cm", [length floatValue]];
    };
    
    NSUInteger years;
    NSDate *birthday = [delegate.delegate getValueForName:@"birthday" fromModuleWithID:@"selfhub.antropometry"];
    if(birthday==nil){
        ageLabel.text = @"<unknown>";
    }else{
        years = [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:birthday toDate:[NSDate date] options:0] year];
        ageLabel.text = [NSString stringWithFormat:@"%d years", years];
    };

    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)dealloc{
    [aimLabel release];
    [aimLabel release];
    [rulerScroll release];
    [moduleSmoothLabel release];
    [heightLabel release];
    [ageLabel release];
    
    [super dealloc];
};


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pressChangeAntropometryValues:(id)sender{
    [delegate.delegate switchToModuleWithID:@"selfhub.antropometry"];
    
    //[delegate.navigationController pushViewController:antropometryController animated:YES];
    //[self.navigationController pushViewController:antropometryController animated:YES];
};


#pragma mark - UIScrollViewDelegate's functions

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"scrolling...");
    float curAimWeight = [rulerScroll getWeight];
    //delegate.aimWeight = [NSNumber numberWithFloat:curAimWeight];
    aimLabel.text = isnan(curAimWeight) ? @"Current aim: not set" : [NSString stringWithFormat:@"Current aim: %.1f kg", curAimWeight];
    //NSLog(@"viewDidScroll: %.1f", curAimWeight);
};

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    //float startTargetOffsetX = targetContentOffset->x;
    float dist = [rulerScroll getPointsBetween100g];
    div_t dt = div(((int)targetContentOffset->x), dist);
    
    if(dt.rem <= (dist/2)){
        targetContentOffset->x = dt.quot * dist;
    }else{
        targetContentOffset->x = (dt.quot+1) * dist;
    };
    
    WeightControlAddRecordRulerScroll *myRulerScroll = (WeightControlAddRecordRulerScroll *)scrollView;
    myRulerScroll.isNanAim = NO;
    float curAimWeight = [myRulerScroll getWeightForOffset:targetContentOffset->x];
    delegate.aimWeight = [NSNumber numberWithFloat:curAimWeight];
    NSLog(@"viewWillEndDragging: %.1f", curAimWeight);
    [delegate saveModuleData];
};


@end
