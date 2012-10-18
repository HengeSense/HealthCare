//
//  WeightControl.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 05.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControl.h"

//Number of days for exponential smoothing moving average
#define MOVING_AVERAGE_FACTOR  7

@implementation WeightControl

@synthesize delegate;
@synthesize navBar, moduleView, slidingMenu, slidingImageView;
@synthesize viewControllers, segmentedControl, hostView;
@synthesize weightData, aimWeight, normalWeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Weight";
    
    [self generateNormalWeight];
    
    //Creating navigation bar with buttons
    self.navBar.topItem.title = @"WeightControl";
    
    UIImage *navBarBackgroundImageBig = [UIImage imageNamed:@"DesktopNavBarBackground@2x.png"];
    UIImage *navBarBackgroundImage = [[UIImage alloc] initWithCGImage:[navBarBackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    [self.navBar setBackgroundImage:navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [navBarBackgroundImage release];
    
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarBtn.frame = CGRectMake(0.0, 0.0, 42.0, 32.0);
    [leftBarBtn setImage:[UIImage imageNamed:@"DesktopSlideLeftNavBarButton.png"] forState:UIControlStateNormal];
    [leftBarBtn setImage:[UIImage imageNamed:@"DesktopSlideLeftNavBarButton_press.png"] forState:UIControlStateHighlighted];
    [leftBarBtn addTarget:self action:@selector(pressMainMenuButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navBar.topItem.leftBarButtonItem = leftBarButtonItem;
    [leftBarButtonItem release];
    
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.frame = CGRectMake(0.0, 0.0, 42.0, 32.0);
    [rightBarBtn setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton.png"] forState:UIControlStateNormal];
    [rightBarBtn setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton_press.png"] forState:UIControlStateHighlighted];
    [rightBarBtn addTarget:self action:@selector(showSlidingMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navBar.topItem.rightBarButtonItem = rightBarButtonItem;
    [rightBarButtonItem release];
    
    
    
    
    //Creating module controllers
    WeightControlChart *chartViewController = [[WeightControlChart alloc] initWithNibName:@"WeightControlChart" bundle:nil];
    chartViewController.delegate = self;
    WeightControlData *dataViewController = [[WeightControlData alloc] initWithNibName:@"WeightControlData" bundle:nil];
    dataViewController.delegate = self;
    WeightControlStatistics *statisticsViewController = [[WeightControlStatistics alloc] initWithNibName:@"WeightControlStatistics" bundle:nil];
    statisticsViewController.delegate = self;
    WeightControlSettings *settingsViewController = [[WeightControlSettings alloc] initWithNibName:@"WeightControlSettings" bundle:nil];
    settingsViewController.delegate = self;
    
    viewControllers = [[NSArray alloc] initWithObjects:chartViewController, dataViewController, statisticsViewController, settingsViewController, nil];
    
    [settingsViewController release];
    [statisticsViewController release];
    [dataViewController release];
    [chartViewController release];
    
    [hostView addSubview:((UIViewController *)[viewControllers objectAtIndex:0]).view];
    segmentedControl.selectedSegmentIndex = 0;
    currentlySelectedViewController = 0;
    
    self.view = moduleView;
    
    
    
    
    
    //slideing-out navigation support
    slidingImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreenshot:)];
    [slidingImageView addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveScreenshot:)];
    [panGesture setMaximumNumberOfTouches:2];
    [slidingImageView addGestureRecognizer:panGesture];
    [tapGesture release];
    [panGesture release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    navBar = nil;
    moduleView = nil;
    slidingMenu = nil;
    slidingImageView = nil;
    weightData = nil;
    segmentedControl = nil;
}

- (void)dealloc{
    [navBar release];
    [moduleView release];
    [slidingMenu release];
    [slidingImageView release];
    [weightData release];
    [viewControllers release];
    
    [aimWeight release];
    [normalWeight release];
    
    [super dealloc];
};

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated{
    [[viewControllers objectAtIndex:currentlySelectedViewController] viewWillAppear:animated];
    
    UIBarButtonItem *rightBtn;
    if(currentlySelectedViewController==0){
        rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Test-fill" style:UIBarButtonSystemItemAction target:[viewControllers objectAtIndex:0] action:@selector(pressDefault)];
        self.navigationItem.rightBarButtonItem = rightBtn;
        [rightBtn release];
    }else if(currentlySelectedViewController==1){
        rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonSystemItemEdit target:[viewControllers objectAtIndex:1] action:@selector(pressEdit)];
        self.navigationItem.rightBarButtonItem = rightBtn;
        [rightBtn release];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    };

    
    [self generateNormalWeight];
    if(!aimWeight || isnan([aimWeight floatValue])){
        if(!normalWeight || isnan([normalWeight floatValue])){
            if(aimWeight) [aimWeight release];
            aimWeight = [[NSNumber alloc] initWithFloat:60.0];
        }else{
            if(aimWeight) [aimWeight release];
            aimWeight = [[NSNumber alloc] initWithFloat:[normalWeight floatValue]];
        };
    };
};

- (void)viewWillDisappear:(BOOL)animated{
    [self saveModuleData];
}

- (IBAction)segmentedControlChanged:(id)sender{
    [((UIViewController *)[viewControllers objectAtIndex:currentlySelectedViewController]).view removeFromSuperview];
    if(segmentedControl.selectedSegmentIndex >= [viewControllers count]){
        [hostView addSubview:((UIViewController *)[viewControllers objectAtIndex:0]).view];
        segmentedControl.selectedSegmentIndex = 0;
        currentlySelectedViewController = 0;
        return;
    };
    
    [hostView addSubview:((UIViewController *)[viewControllers objectAtIndex:segmentedControl.selectedSegmentIndex]).view];
    currentlySelectedViewController = segmentedControl.selectedSegmentIndex;
    
    UIBarButtonItem *rightBtn;
    if(currentlySelectedViewController==0){
        rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Test-fill" style:UIBarButtonSystemItemAction target:[viewControllers objectAtIndex:0] action:@selector(pressDefault)];
        self.navigationItem.rightBarButtonItem = rightBtn;
        [rightBtn release];
        //self.navigationItem.rightBarButtonItem = nil;
    }else if(currentlySelectedViewController==1){
        rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonSystemItemEdit target:[viewControllers objectAtIndex:1] action:@selector(pressEdit)];
        self.navigationItem.rightBarButtonItem = rightBtn;
        [rightBtn release];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    };

};

- (IBAction)showSlidingMenu:(id)sender{
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 2.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    slidingImageView.image = [self correctScreenshot:image];
    
    self.view = slidingMenu;
    
    slidingImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slidingImageView setFrame:CGRectMake(-130, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){
        
    }];    
};

- (IBAction)hideSlidingMenu:(id)sender{
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 2.0);
    [self.moduleView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    slidingImageView.image = [self correctScreenshot:image];
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slidingImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){
        self.view = moduleView;
    }];    
};

- (IBAction)selectScreenFromMenu:(id)sender{
    [((UIViewController *)[viewControllers objectAtIndex:currentlySelectedViewController]).view removeFromSuperview];
    if(segmentedControl.selectedSegmentIndex >= [viewControllers count]){
        [hostView addSubview:((UIViewController *)[viewControllers objectAtIndex:0]).view];
        segmentedControl.selectedSegmentIndex = 0;
        currentlySelectedViewController = 0;
        [self hideSlidingMenu:nil];
        return;
    };
    
    [self.hostView addSubview:[[viewControllers objectAtIndex:[sender tag]] view]];
    currentlySelectedViewController = [sender tag];
    
    UIBarButtonItem *rightBtn;
    if(currentlySelectedViewController==0){
        rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Test-fill" style:UIBarButtonSystemItemAction target:[viewControllers objectAtIndex:0] action:@selector(pressDefault)];
        self.navigationItem.rightBarButtonItem = rightBtn;
        [rightBtn release];
        //self.navigationItem.rightBarButtonItem = nil;
    }else if(currentlySelectedViewController==1){
        rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonSystemItemEdit target:[viewControllers objectAtIndex:1] action:@selector(pressEdit)];
        self.navigationItem.rightBarButtonItem = rightBtn;
        [rightBtn release];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    };
    
    [self hideSlidingMenu:nil];
};

-(void)moveScreenshot:(UIPanGestureRecognizer *)gesture
{
    UIView *piece = [gesture view];
    //[self adjustAnchorPointForGestureRecognizer:gesture];
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:[piece superview]];
        
        // I edited this line so that the image view cannont move vertically
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y)];
        [gesture setTranslation:CGPointZero inView:[piece superview]];
    }
    else if ([gesture state] == UIGestureRecognizerStateEnded)
        [self hideSlidingMenu:nil];
}

- (void)tapScreenshot:(UITapGestureRecognizer *)gesture{
    [self hideSlidingMenu:nil];
};

#pragma mark - Key-value-coding delegate
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //NSLog(@"observeValueForKeyPath");
};
- (void)didChangeValueForKey:(NSString *)key{
    [self sortWeightData];
    [self updateTrendsFromIndex:0];
    [((WeightControlChart *)[self.viewControllers objectAtIndex:0]).weightGraph redrawPlot];
    [self saveModuleData];
    NSLog(@"Weight Control Module: received new database (total records %d)", [weightData count]);
};


#pragma mark - Module protocol functions

- (id)initModuleWithDelegate:(id<ServerProtocol>)serverDelegate{
    NSString *nibName;
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        nibName = @"WeightControl";
    }else{
        return nil;
    };
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        delegate = serverDelegate;
        if(serverDelegate==nil){
            NSLog(@"WARNING: module \"%@\" initialized without server delegate!", [self getModuleName]);
        };
        [self addObserver:self forKeyPath:@"weightData" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
};

- (NSString *)getModuleName{
    return NSLocalizedString(@"Weight Control", @"");
};

- (NSString *)getModuleDescription{
    return @"The module for those watching their weight. It allows you to make a prediction of weight, display the graph, etc.";
};

- (NSString *)getModuleMessage{
    return @"Enter your weight!";
};

- (float)getModuleVersion{
    return 1.0f;
};

- (UIImage *)getModuleIcon{
    return [UIImage imageNamed:@"weightModule_icon.png"];
};

- (BOOL)isInterfaceIdiomSupportedByModule:(UIUserInterfaceIdiom)idiom{
    BOOL res;
    switch (idiom) {
        case UIUserInterfaceIdiomPhone:
            res = YES;
            break;
            
        case UIUserInterfaceIdiomPad:
            res = NO;
            break;
            
        default:
            res = NO;
            break;
    };
    
    return res;
};

- (NSString *)getBaseDir{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
};

- (void)loadModuleData{
    
    //weightData = [[NSMutableArray alloc] init];
    //[self fillTestData:20];
    //return;
    
    NSString *weightFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"weightcontrol.dat"];
    //NSArray *importedWeightArray = [NSArray arrayWithContentsOfFile:weightFilePath];
    
    if(weightData){
        [weightData release];
        weightData = nil;
    };
    
    NSDictionary *fileData = [[NSDictionary alloc] initWithContentsOfFile:weightFilePath];
    if(!fileData){
        NSLog(@"Cannot load weight data from file weightcontrol.dat. Loading test data...");
        weightData = [[NSMutableArray alloc] init];
        [self fillTestData:33];
        
    }else{
        if(weightData) [weightData release];
        weightData = [[NSMutableArray alloc] initWithArray:[fileData objectForKey:@"data"]]; //[[fileData objectForKey:@"data"] retain];
        if(aimWeight) [aimWeight release];
        aimWeight = [[fileData objectForKey:@"aim"] retain];
        
        [fileData release];
    };
    
    if([weightData count]>0 && [[weightData objectAtIndex:0] objectForKey:@"trend"]==nil){
        NSLog(@"Weight data without trends was loaded! Generating trends...");
        [self updateTrendsFromIndex:0];
    }
};
- (void)saveModuleData{
    NSString *weightFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"weightcontrol.dat"];
    NSDictionary *moduleData = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:weightData, aimWeight, nil] forKeys:[NSArray arrayWithObjects:@"data", @"aim", nil]];
    [moduleData writeToFile:weightFilePath atomically:YES];
};

- (id)getModuleValueForKey:(NSString *)key{
    return nil;
};

- (void)setModuleValue:(id)object forKey:(NSString *)key{
    
};

- (IBAction)pressMainMenuButton{
    [delegate showSlideMenu];
};

- (UIImage *)correctScreenshot:(UIImage *)screenshotImage{
    if(currentlySelectedViewController==0){
        UIImage *glImage = [((WeightControlChart *)[viewControllers objectAtIndex:0]).weightGraph.glContentView getViewScreenshot];
        
        UIGraphicsBeginImageContextWithOptions(screenshotImage.size, NO, 2.0);
        
        // Use existing opacity as is
        
        [screenshotImage drawInRect:CGRectMake(0.0, 0.0, screenshotImage.size.width, screenshotImage.size.height)];
        
        // Apply supplied opacity if applicable
        CGRect glViewRect = [((WeightControlChart *)[viewControllers objectAtIndex:0]).weightGraph frame];
        glViewRect.origin.y += 44;
        [glImage drawInRect:glViewRect blendMode:kCGBlendModeNormal alpha:1.0];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return newImage;
        
    }else{
        return screenshotImage;
    };
};

#pragma mark - module functions
- (void)fillTestData:(NSUInteger)numOfElements{
    if(weightData){
        [weightData release];
        weightData = nil;
    };
    weightData = [[NSMutableArray alloc] init];
    
    NSTimeInterval startTimeInt = [[NSDate date] timeIntervalSince1970] - (60*60*24*numOfElements);
    NSDate *refDate = [NSDate dateWithTimeIntervalSince1970:startTimeInt];
    
    int i;
    NSDictionary *dict;
    NSNumber *weight;
    NSDate *date;
    [weightData removeAllObjects];
    float weightNum = 50.0;
    for(i=0;i<numOfElements;i++){
        weightNum = (((double)rand()/RAND_MAX) * 70) + 50;
        //weightNum += (((double)rand()/RAND_MAX) * 0.1);
        
        
        //if(i<10 || i>40) weightNum += (((double)rand()/RAND_MAX) * 70);
        //if(i>=10 && i<20) weightNum += (i-10);
        //if(i>=20 && i<30) weightNum += (10-i+20);
        //if(i>=30 && i<40) weightNum *= 1.5;
        
        weight = [NSNumber numberWithDouble:weightNum];
        date = [NSDate dateWithTimeInterval:(60*60*24*i) sinceDate:refDate];
        dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:weight, date, nil] forKeys:[NSArray arrayWithObjects:@"weight", @"date", nil]];
        //NSLog(@"Weight for date %@: %.2f", [date description], [weight doubleValue]);
        [weightData addObject:dict];
    };
};

- (void)generateNormalWeight{
    NSNumber *length = [delegate getValueForName:@"length" fromModuleWithID:@"selfhub.antropometry"];
    NSDate *birthday = [delegate getValueForName:@"birthday" fromModuleWithID:@"selfhub.antropometry"];
    if(length==nil){
        normalWeight = [NSNumber numberWithFloat:NAN];
        return;
    };
    
    NSUInteger years = 18;
    if(birthday!=nil){
        years = [[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:birthday toDate:[NSDate date] options:0] year];
    };
    float res = [length floatValue];
    
    if([length floatValue]<165.0f){
        res -= 100.0f;
    };
    if([length floatValue]>=165.0f && [length floatValue]<=175.0f){
        res -= 105.0f;
    };
    if([length floatValue]>175.0f){
        res -= 110.0f;
    };
    
    if(years>40){
        res += 5.0f;
    }
    
    normalWeight = [[NSNumber numberWithFloat:res] retain];
};

- (void)updateTrendsFromIndex:(NSUInteger)startIndex{
    float curTrend, lastTrend, curWeight, curPower;
    NSUInteger i, numOfDaysBetweenDates;
    NSTimeInterval intervalBetweenDates, oneDay = 60 * 60 * 24;
    NSMutableDictionary *changedRecord;
    for(i = startIndex; i < [weightData count]; i++){
        if(i==0){
            curTrend = [[[weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
        }else{
            lastTrend = [[[weightData objectAtIndex:i-1] objectForKey:@"trend"] floatValue];
            curWeight = [[[weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
            intervalBetweenDates = [[[weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSinceDate:[[weightData objectAtIndex:i-1] objectForKey:@"date"]];
            numOfDaysBetweenDates = (NSUInteger)intervalBetweenDates / oneDay;
            curPower = 1.0 - exp(-(float)numOfDaysBetweenDates/MOVING_AVERAGE_FACTOR);
            curTrend = lastTrend + curPower * (curWeight - lastTrend);
        };
        
        //NSLog(@"Trend for record %2d: %.1f (weight = %.1f)", i, curTrend, curWeight);
        changedRecord = [[NSMutableDictionary alloc] initWithDictionary:[weightData objectAtIndex:i]];
        [changedRecord removeObjectForKey:@"trend"];
        [changedRecord setValue:[NSNumber numberWithFloat:curTrend] forKey:@"trend"];
        [weightData removeObjectAtIndex:i];
        [weightData insertObject:changedRecord atIndex:i];
        [changedRecord release];
        changedRecord = nil;
    };
};

- (float)getBMI{
    NSNumber *length = [delegate getValueForName:@"length" fromModuleWithID:@"selfhub.antropometry"];
    NSNumber *curWeight = [delegate getValueForName:@"weight" fromModuleWithID:@"selfhub.antropometry"];
    
    float res = 0.0;
    if(length && curWeight){
        if([length floatValue]!=NAN && [curWeight floatValue]!=NAN){
            res = [curWeight floatValue] / pow([length floatValue]/100.0, 2.0);
        };
    };
    
    return res;
};

- (NSTimeInterval)getTimeIntervalToAim{
    float w1, w2, aim;
    NSInteger lastIndex = [weightData count]-1;
    NSTimeInterval w1w2TimeInt, result;
    if(lastIndex>0 && aimWeight && [aimWeight floatValue]!=NAN){
        w1 = [[[weightData objectAtIndex:lastIndex] objectForKey:@"trend"] floatValue];
        w2 = [[[weightData objectAtIndex:lastIndex-1] objectForKey:@"trend"] floatValue];
        aim = [aimWeight floatValue];
        w1w2TimeInt = [[[weightData objectAtIndex:lastIndex] objectForKey:@"date"] timeIntervalSinceDate:[[weightData objectAtIndex:lastIndex-1] objectForKey:@"date"]];
        if(fabs(w2-w1)<0.00001) return NAN;
        result = ((float)w1w2TimeInt * (w1 - aim)) / (w2-w1);
        if(result>60*60*24*365 || result<0.0) return NAN;
        
        return result;
    };
    
    return NAN;
};

- (NSDate *)getDateWithoutTime:(NSDate *)_myDate{
    NSDate *res;
    NSTimeInterval timeInt = [_myDate timeIntervalSince1970];
    NSTimeInterval oneDay = 60.0f * 60.0f * 24.0f;
    
    NSTimeInterval remainder = timeInt - floor(timeInt / oneDay) * oneDay;
    
    res = [NSDate dateWithTimeIntervalSince1970:timeInt - remainder];
    
    //NSLog(@"%@ -> %@", [_myDate description], [res description]);
    
    return res;
};

- (NSComparisonResult)compareDateByDays:(NSDate *)_firstDate WithDate:(NSDate *)_secondDate{
    double delta = [_firstDate timeIntervalSinceDate:_secondDate];
    if(fabs(delta) < 60*60*24){
        return NSOrderedSame;
    };
    
    if(delta>0){
        return NSOrderedDescending;
    };
    
    return NSOrderedAscending;
};

- (void)sortWeightData{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [weightData sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
};


@end