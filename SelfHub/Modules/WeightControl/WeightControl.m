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
@synthesize rightSlideBarTable, navBar, moduleView, slidingMenu, slidingImageView;
@synthesize modulePagesArray, hostView;
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
    
    modulePagesArray = [[NSArray alloc] initWithObjects:chartViewController, dataViewController, statisticsViewController, settingsViewController, nil];
    
    [settingsViewController release];
    [statisticsViewController release];
    [dataViewController release];
    [chartViewController release];
    
    [hostView addSubview:((UIViewController *)[modulePagesArray objectAtIndex:0]).view];
    lastSelectedIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    
    
    
    self.view = moduleView;
    
    UIImageView *darkPathImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DesktopVerticalDarkRightPath.png"]];
    float verticalPathHeight = [UIScreen mainScreen].bounds.size.height;
    darkPathImage.frame = CGRectMake(self.view.frame.size.width, 0, darkPathImage.frame.size.width, verticalPathHeight);
    darkPathImage.userInteractionEnabled = NO;
    [slidingImageView addSubview:darkPathImage];
    [darkPathImage release];
    
    
    
    
    
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

- (void)dealloc{
    [rightSlideBarTable release];
    [navBar release];
    [moduleView release];
    [slidingMenu release];
    [slidingImageView release];
    [weightData release];
    [modulePagesArray release];
    
    [aimWeight release];
    [normalWeight release];
    
    if(lastSelectedIndexPath) [lastSelectedIndexPath release];
    
    [super dealloc];
};

- (void)viewWillLayoutSubviews{
    //self.view.frame = self.view.superview.frame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated{
    [[modulePagesArray objectAtIndex:[lastSelectedIndexPath row]] viewWillAppear:animated];
    
    [self generateNormalWeight];
    if(!aimWeight || isnan([aimWeight floatValue])){
        if(!normalWeight || isnan([normalWeight floatValue])){
            if(aimWeight) [aimWeight release];
            //aimWeight = [[NSNumber alloc] initWithFloat:N];
            aimWeight = [[NSNumber alloc] initWithFloat:NAN];
        }else{
            if(aimWeight) [aimWeight release];
            aimWeight = [[NSNumber alloc] initWithFloat:[normalWeight floatValue]];
        };
    };
};

- (void)viewWillDisappear:(BOOL)animated{
    [self saveModuleData];
}

#pragma mark - Right sliding menu functions

- (IBAction)showSlidingMenu:(id)sender{
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 2.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    slidingImageView.image = [self correctScreenshot:image];
    
    self.view = slidingMenu;
    
    [rightSlideBarTable selectRowAtIndexPath:lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    //NSLog(@"SLIDING IMAGE SIZE: %.0fx%.0f (BOUNDS: %.0fx%.0f)", self.view.frame.size.width, self.view.frame.size.height, viewSize.width, viewSize.height);
    slidingImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slidingImageView setFrame:CGRectMake(-rightSlideBarTable.bounds.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){
        
    }];    
};

- (IBAction)hideSlidingMenu:(id)sender{
    CGSize viewSize = self.view.bounds.size;
    //NSLog(@"Hide right slide menu: bounds = %.0fx%.0f", viewSize.width, viewSize.height);
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 2.0);
    [self.moduleView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    slidingImageView.image = [self correctScreenshot:image];
    //slidingImageView.image = image;
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slidingImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){
        self.view = moduleView;
    }];    
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

#pragma mark - TableView delegate (supporting right table-based navigation)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
};

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
};

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGRect headerRect = CGRectMake(0.0, 0.0, tableView.bounds.size.width, 20.0);
    
    UIView *headerView = [[[UIView alloc] initWithFrame:headerRect] autorelease];
    
    UIImageView *headerBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DesktopCellHeaderBackground.png"]];
    headerBackgroundImage.alpha = 0.3;
    [headerView addSubview:headerBackgroundImage];
    [headerBackgroundImage release];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 2.0, 140.0, 16.0)];
    headerLabel.textColor = [UIColor lightTextColor];
    headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    headerLabel.backgroundColor = [UIColor clearColor];
    
    headerLabel.text = @"Pages";
    
    [headerView addSubview:headerLabel];
    [headerLabel release];
    
    return headerView;
};


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID;
    cellID = @"RightSlideMenuTableCell";
    
    ModuleTableCell *cell = (ModuleTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil){
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ModuleTableCell" owner:self options:nil];
        for(id oneObject in nibs){
            if([oneObject isKindOfClass:[ModuleTableCell class]] && [[oneObject reuseIdentifier] isEqualToString:cellID]){
                cell = (ModuleTableCell *)oneObject;
            };
        };
    };
    
    if([indexPath section]==0){
        switch([indexPath row]){
            case 0:
                cell.moduleName.text = @"Chart";
                break;
            case 1:
                cell.moduleName.text = @"Data";
                break;
            case 2:
                cell.moduleName.text = @"Statistics";
                break;
            case 3:
                cell.moduleName.text = @"Settings";
                break;
                
            default:
                break;
        };
    }else{
        cell.moduleName.text = @"";
    };
    
    return cell;
    
};

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66.0;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0){
        [[[modulePagesArray objectAtIndex:[lastSelectedIndexPath row]] view] removeFromSuperview];
        [self.hostView addSubview:[[modulePagesArray objectAtIndex:[indexPath row]] view]];
        
        if(lastSelectedIndexPath) [lastSelectedIndexPath release];
        lastSelectedIndexPath = [indexPath retain];
        [tableView selectRowAtIndexPath:lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        [self hideSlidingMenu:nil];
    };
};


#pragma mark - Key-value-coding delegate
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //NSLog(@"observeValueForKeyPath");
};
- (void)didChangeValueForKey:(NSString *)key{
    if([key isEqualToString:@"weightData"]){
        NSLog(@"Processing %d records...", [weightData count]);
        [self sortWeightData];
        [self normalizeWeightData];
        [self updateTrendsFromIndex:0];
        [((WeightControlChart *)[self.modulePagesArray objectAtIndex:0]).weightGraph redrawPlot];
        [self saveModuleData];
        NSLog(@"Weight Control Module: received new database (total records %d)", [weightData count]);
    };
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
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
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
        //[self fillTestData:33];
        
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
    if([lastSelectedIndexPath row]==0){
        UIImage *glImage = [((WeightControlChart *)[modulePagesArray objectAtIndex:0]).weightGraph.glContentView getViewScreenshot];
        
        UIGraphicsBeginImageContextWithOptions(screenshotImage.size, NO, 2.0);
        
        // Use existing opacity as is
        
        [screenshotImage drawInRect:CGRectMake(0.0, 0.0, screenshotImage.size.width, screenshotImage.size.height)];
        
        // Apply supplied opacity if applicable
        CGRect glViewRect = [((WeightControlChart *)[modulePagesArray objectAtIndex:0]).weightGraph frame];
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
    
    NSNumber *curWeight = nil;
    if([weightData count]>0){
        curWeight = [[weightData lastObject] objectForKey:@"trend"];
    };
    if(curWeight==nil){
        curWeight = [delegate getValueForName:@"weight" fromModuleWithID:@"selfhub.antropometry"];
    };
    
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

- (float)getForecastTrendForWeek{
    float w1, w2, aim;
    NSInteger lastIndex = [weightData count]-1;
    NSTimeInterval w1w2TimeInt, result;
    if(lastIndex>0){
        w1 = [[[weightData objectAtIndex:lastIndex] objectForKey:@"trend"] floatValue];
        w2 = [[[weightData objectAtIndex:lastIndex-1] objectForKey:@"trend"] floatValue];
        aim = [aimWeight floatValue];
        w1w2TimeInt = [[[weightData objectAtIndex:lastIndex] objectForKey:@"date"] timeIntervalSinceDate:[[weightData objectAtIndex:lastIndex-1] objectForKey:@"date"]];
        if(fabs(w2-w1)<0.00001) return NAN;
        
        result = ((w1-w2) * (w1w2TimeInt+60*60*24*7)) / w1w2TimeInt;
        
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

- (void)normalizeWeightData{
    int i = 0;
    NSMutableDictionary *oneNewRec;
    NSDate *newRecDate;
    NSDate *lastRecDate;
    NSDictionary *oneRec;
    //NSString *logStr;
    for(i=0; i<[weightData count]; i++){
        oneRec = [weightData objectAtIndex:i];
        newRecDate = [self getDateWithoutTime:[oneRec objectForKey:@"date"]];
        oneNewRec = [NSMutableDictionary dictionaryWithDictionary:oneRec];
        [oneNewRec setObject:newRecDate forKey:@"date"];
        [weightData removeObjectAtIndex:i];
        if(i==0 || (i>0 && [self compareDateByDays:lastRecDate WithDate:newRecDate]!=NSOrderedSame)){
            [weightData insertObject:[NSDictionary dictionaryWithDictionary:(NSDictionary *)oneNewRec] atIndex:i];
            lastRecDate = [NSDate dateWithTimeInterval:0 sinceDate:newRecDate];
            //logStr = [NSString stringWithFormat:@" + %@ (%.1f kg)", [newRecDate description], [[oneNewRec objectForKey:@"weight"] floatValue]];
        }else{
            i--;
            //logStr = [NSString stringWithFormat:@" - %@ (%.1f kg)", [newRecDate description], [[oneNewRec objectForKey:@"weight"] floatValue]];
        };
        //NSLog(@"%@", logStr);
    };
};


@end