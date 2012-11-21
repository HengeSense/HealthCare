//
//  MainInformation.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainInformation.h"

@implementation MainInformation

@synthesize delegate, modulePagesArray;
@synthesize navBar, hostView, moduleView, slidingMenu, slidingImageView, moduleData;



- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        moduleData = nil;
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
    
    modulePagesArray = [[NSMutableArray alloc] init];
    MainInformationPacient *viewController1 = [[MainInformationPacient alloc] initWithNibName:@"MainInformationPacient" bundle:nil];
    MainInformationUnits *viewController2 = [[MainInformationUnits alloc] initWithNibName:@"MainInformationUnits" bundle:nil];
    viewController1.delegate = self;
    viewController2.delegate = self;
    [modulePagesArray addObject:viewController1];
    [modulePagesArray addObject:viewController2];
    [self.hostView addSubview:viewController1.view];
    currentlySelectedViewController = 0;
    [viewController1 release];
    [viewController2 release];
    
    
    
    
    //[self fillAllFieldsLocalized];
    
    currentlySelectedViewController = 0;
    
    self.view = moduleView;
    
    
    //Creating navigation bar with buttons
    self.navBar.topItem.title = [self getModuleName];
    
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

- (void)dealloc
{
    delegate = nil;
    [modulePagesArray release];
    
    [navBar release];
    [hostView release];
    [slidingMenu release];
    [slidingImageView release];
    if(moduleData) [moduleData release];
    
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    if(moduleData==nil){
        [self loadModuleData];
    };
    
    NSLog(@"Adding pacient page to main view");
    UIView *currentView = [[modulePagesArray objectAtIndex:currentlySelectedViewController] view];
    if(currentView.superview != hostView){
        [self.hostView addSubview:currentView];
    };
};

- (void)viewWillDisappear:(BOOL)animated{
    [self saveModuleData];
};


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
};

- (NSDate *)getDateFromString_ddMMyy:(NSString *)dateStr{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"dd.MM.yy"];
    return [dateFormatter dateFromString:dateStr];
};

- (NSString *)getYearsWord:(NSUInteger)years padej:(BOOL)isRod{
    
    if(isRod){
        if(years>10&&years<19) return NSLocalizedString(@"years_let", @"");
        if((years%10) ==  1) return NSLocalizedString(@"years_goda", @"");
        
        return NSLocalizedString(@"years_let", @"");
    }else{
        if(years>10&&years<19) return NSLocalizedString(@"years_let", @"");
        if((years%10) == 1) return NSLocalizedString(@"year_god", @"");
        if((years%10) >= 2 && (years%10) <=4) return NSLocalizedString(@"years_goda", @"");
        
        return NSLocalizedString(@"years_let", @"");
    };
};

- (NSUInteger)getAgeByBirthday:(NSDate *)brthdy{
    NSDate *now = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:brthdy toDate:now options:0];
    
    return [ageComponents year];
};

- (NSString *)getBaseDir{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
};



#pragma mark - Right sliding menu functions

- (IBAction)showSlidingMenu:(id)sender{
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 2.0);
    [self.moduleView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    slidingImageView.image = image;
    
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
    
    slidingImageView.image = image;
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slidingImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){
        self.view = moduleView;
    }];
};

- (IBAction)selectScreenFromMenu:(id)sender{
    int i;
    for(i = 0; i<[modulePagesArray count]; i++){
        if(i==currentlySelectedViewController){
            [[[modulePagesArray objectAtIndex:i] view] removeFromSuperview];
        };
        if(i==[sender tag]){
            [self.hostView addSubview:[[modulePagesArray objectAtIndex:i] view]];
        };
    };
    
    
    currentlySelectedViewController = [sender tag];
    
    
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


#pragma mark - Working with units view's fields

- (NSString *)getWeightUnit{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *weightUnit = [moduleData objectForKey:@"weightUnit"];
    if(weightUnit==nil) weightUnit = [NSNumber numberWithInt:0];
    return [unitsPage getWeightUnitStr:[weightUnit intValue]];
};

- (float)getWeightFactor{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *weightUnit = [moduleData objectForKey:@"weightUnit"];
    if(weightUnit==nil) weightUnit = [NSNumber numberWithInt:0];
    return [unitsPage getWeightUnitKoef:[weightUnit intValue]];
};

- (NSString *)getSizeUnit{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *sizeUnit = [moduleData objectForKey:@"sizeUnit"];
    if(sizeUnit==nil) sizeUnit = [NSNumber numberWithInt:0];
    return [unitsPage getSizeUnitStr:[sizeUnit intValue]];
};

- (float)getSizeFactor{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *sizeUnit = [moduleData objectForKey:@"sizeUnit"];
    if(sizeUnit==nil) sizeUnit = [NSNumber numberWithInt:0];
    return [unitsPage getSizeUnitKoef:[sizeUnit intValue]];
};

- (void)recalcAllFieldsToCurrentlySelectedUnits{
    
};


#pragma mark - Module protocol functions

- (id)initModuleWithDelegate:(id<ServerProtocol>)serverDelegate{
    NSString *nibName;
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        nibName = @"MainInformation";
    }else{
        return nil;
    };
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        //realBirthday = nil;
        moduleData = nil;
        delegate = serverDelegate;
        if(serverDelegate==nil){
            NSLog(@"WARNING: module \"%@\" initialized without server delegate!", [self getModuleName]);
        };
    }
    return self;
};

- (NSString *)getModuleName{
    return NSLocalizedString(@"Profile", @"");
};

- (NSString *)getModuleDescription{
    return NSLocalizedString(@"The module allows you to display and edit general information about the patient (height, weight, age, etc)", @"");
};

- (NSString *)getModuleMessage{
    if(moduleData==nil) return NSLocalizedString(@"The data is not loaded", @"");
    
    if([moduleData objectForKey:@"name"]==nil || [moduleData objectForKey:@"surname"]==nil || [moduleData objectForKey:@"patronymic"]==nil) return NSLocalizedString(@"Specify the name", @"");
    if([moduleData objectForKey:@"birthday"]==nil) return NSLocalizedString(@"Specify your birthday", @"");
    if([moduleData objectForKey:@"length"]==nil) return NSLocalizedString(@"Specify the height!", @"");
    if([moduleData objectForKey:@"weight"]==nil) return NSLocalizedString(@"Specify the weight", @"");
    
    return NSLocalizedString(@"All fields are filled!", @"");
};

- (float)getModuleVersion{
    return 1.1f;
};

- (UIImage *)getModuleIcon{
    return [UIImage imageNamed:@"mainInfoModule_icon.png"];
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

- (void)loadModuleData{
    NSString *listFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"antropometry.dat"];
    NSDictionary *loadedParams = [NSDictionary dictionaryWithContentsOfFile:listFilePath];
    if(loadedParams){
        if(moduleData) [moduleData release];
        moduleData = [[NSMutableDictionary alloc] initWithDictionary:loadedParams];
        if([moduleData objectForKey:@"weightUnit"]==nil){
            [moduleData setObject:[NSNumber numberWithInt:0] forKey:@"weightUnit"];
        };
        if([moduleData objectForKey:@"sizeUnit"]==nil){
            [moduleData setObject:[NSNumber numberWithInt:0] forKey:@"sizeUnit"];
        };
    }else{
        moduleData = [[NSMutableDictionary alloc] init];
        [moduleData setObject:[NSNumber numberWithInt:0] forKey:@"weightUnit"];
        [moduleData setObject:[NSNumber numberWithInt:0] forKey:@"sizeUnit"];
    }
};
- (void)saveModuleData{
    if(moduleData==nil){
        return;
    };
    
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@", [self getBaseDir]];
    BOOL succ = [moduleData writeToFile:[fileName stringByAppendingPathComponent:@"antropometry.dat"] atomically:YES];
    [fileName release];
    if(succ==NO){
        NSLog(@"Anthropometry: Error during save data");
    };
};

- (id)getModuleValueForKey:(NSString *)key{
    return nil;
};

- (void)setModuleValue:(id)object forKey:(NSString *)key{
    
};

- (IBAction)pressMainMenuButton{
    [delegate showSlideMenu];
};


@end
