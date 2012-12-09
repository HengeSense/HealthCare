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
@synthesize aimLabel, rulerScroll, moduleSmoothLabel, heightLabel, ageLabel, goToProfileButton;

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
    UILabel *changeSettingsLabel = [[UILabel alloc] initWithFrame:goToProfileButton.bounds];
    changeSettingsLabel.backgroundColor = [UIColor clearColor];
    changeSettingsLabel.textAlignment = NSTextAlignmentCenter;
    changeSettingsLabel.font = [UIFont boldSystemFontOfSize:14.0];
    changeSettingsLabel.shadowColor = [UIColor blackColor];
    changeSettingsLabel.shadowOffset = CGSizeMake(0, 0.5);
    changeSettingsLabel.textColor = [UIColor colorWithRed:121.0/255.0 green:119.0/255.0 blue:128.0/255.0 alpha:1.0];
    changeSettingsLabel.highlightedTextColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:0.35];
    changeSettingsLabel.text = @"Change values";
    [goToProfileButton addSubview:changeSettingsLabel];
    [changeSettingsLabel release];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //NSLog(@"Settings view will appear: weight = %.1f", [delegate.aimWeight floatValue]);
    aimLabel.text = isnan([delegate.aimWeight floatValue]) ? @"Current aim: not set" : [NSString stringWithFormat:@"Current goal: %@", [delegate getWeightStrForWeightInKg:[delegate.aimWeight floatValue] withUnit:YES]];
    
    MainInformation *antropometryController = (MainInformation *)[delegate.delegate getViewControllerForModuleWithID:@"selfhub.antropometry"];
    if(antropometryController!=nil){
        rulerScroll.minWeightKg = [antropometryController getMinWeightKg];
        rulerScroll.maxWeightKg = [antropometryController getMaxWeightKg];
        rulerScroll.stepWeightKg = [antropometryController getWeightPickerStep];
        rulerScroll.weightFactor = [antropometryController getWeightFactor];
    }else{
        rulerScroll.minWeightKg = 30.0;
        rulerScroll.maxWeightKg = 300.0;
        rulerScroll.stepWeightKg = 0.1;
        rulerScroll.weightFactor = 1.0;
    };

    [rulerScroll showWeight:[delegate.aimWeight floatValue]];
    
    if(antropometryController!=nil){
        moduleSmoothLabel.text = [NSString stringWithFormat:@"%@", [antropometryController getModuleName]];
    };
    [moduleSmoothLabel setColor:WeightControlChartSmoothLabelColorYellow];
    
    
    NSNumber *length = [delegate.delegate getValueForName:@"length" fromModuleWithID:@"selfhub.antropometry"];
    if(length==nil){
        heightLabel.text = @"<unknown>";
    }else{
        heightLabel.text = [NSString stringWithFormat:@"%@", [delegate getHeightStrForHeightInCm:[length floatValue] withUnit:YES]];
    };
    
    NSUInteger years;
    NSDate *birthday = [delegate.delegate getValueForName:@"birthday" fromModuleWithID:@"selfhub.antropometry"];
    if(birthday==nil){
        ageLabel.text = @"<unknown>";
    }else{
        years = [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:birthday toDate:[NSDate date] options:0] year];
        ageLabel.text = [NSString stringWithFormat:@"%d years", years];
    };
    
    //CGRect rootFrame = self.view.frame;
    //NSLog(@"SETTINGS VIEW FRAME: %.0f, %.0f, %.0f, %.0f", rootFrame.origin.x, rootFrame.origin.y, rootFrame.size.width, rootFrame.size.height);
};

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
};

-(void)dealloc{
    [aimLabel release];
    [aimLabel release];
    [rulerScroll release];
    [moduleSmoothLabel release];
    [heightLabel release];
    [ageLabel release];
    [goToProfileButton release];
    
    [super dealloc];
};

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
};


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pressChangeAntropometryValues:(id)sender{
    [delegate.delegate switchToModuleWithID:@"selfhub.antropometry"];
};


#pragma mark - UIScrollViewDelegate's functions

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"scrolling...");
    float curAimWeight = [rulerScroll getWeight];
    //delegate.aimWeight = [NSNumber numberWithFloat:curAimWeight];
    aimLabel.text = isnan(curAimWeight) ? @"Current aim: not set" : [NSString stringWithFormat:@"Current aim: %@", [delegate getWeightStrForWeightInKg:curAimWeight withUnit:YES]];
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
    //NSLog(@"viewWillEndDragging: %.1f", curAimWeight);
    [delegate saveModuleData];
};


@end
