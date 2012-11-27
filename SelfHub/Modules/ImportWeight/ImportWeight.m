//
//  ImportWeight.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 13.11.12.
//
//

#import "ImportWeight.h"

@interface ImportWeight ()

@end

@implementation ImportWeight

@synthesize delegate, modulePagesArray, navBar, hostView, moduleView, slidingMenu, slidingImageView;

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
    
    //Creating navigation bar with buttons. Use only standart elements
    self.navBar.topItem.title = [self getModuleName];
    
    modulePagesArray = [[NSMutableArray alloc] init];
    ImportWeightFromITunes *importFromITunesViewController = [[ImportWeightFromITunes alloc] initWithNibName:@"ImportWeightFromITunes" bundle:nil];
    importFromITunesViewController.delegate = self;
    [modulePagesArray addObject:importFromITunesViewController];
    [importFromITunesViewController release];
    
    currentlySelectedViewController = 0;
    
    UIImageView *darkPathImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DesktopVerticalDarkRightPath.png"]];
    float verticalPathHeight = [UIScreen mainScreen].bounds.size.height;
    darkPathImage.frame = CGRectMake(self.view.frame.size.width, 0, darkPathImage.frame.size.width, verticalPathHeight);
    darkPathImage.userInteractionEnabled = NO;
    [slidingImageView addSubview:darkPathImage];
    [darkPathImage release];
    
    
    UIImage *navBarBackgroundImage = [UIImage imageNamed:@"DesktopNavBarBackground.png"];
    [self.navBar setBackgroundImage:navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
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
};

- (void)viewWillAppear:(BOOL)animated{
    UIView *currentView = [[modulePagesArray objectAtIndex:currentlySelectedViewController] view];
    if(currentView.superview != hostView){
        [self.hostView addSubview:currentView];
    };
};


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    delegate = nil;
    if(modulePagesArray) [modulePagesArray release];
    [navBar release];
    [hostView release];
    [moduleView release];
    [slidingMenu release];
    [slidingImageView release];
    
    
    [super dealloc];
};

- (NSInteger)numOfRecordsFromFileAsCVS:(NSString *)filePath{
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSNonLossyASCIIStringEncoding error:nil];
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    NSArray *dividedRec;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    NSDate *curDate;
    float curWeight;
    
    NSInteger res = 0;
    for(NSString *oneRec in arr){
        dividedRec = [oneRec componentsSeparatedByString:@";"];
        if([dividedRec count]<2) continue;
        
        curDate = [[dateFormatter dateFromString:[dividedRec objectAtIndex:0]] retain];
        if(curDate==nil) continue;
        curWeight = [[dividedRec objectAtIndex:1] floatValue];
        if(curWeight<=0.0) continue;
        [curDate release];
        
        res++;
    };
    [dateFormatter release];
    
    return res;
};

- (NSArray *)recordsFromFileAsCVS:(NSString *)filePath{
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSNonLossyASCIIStringEncoding error:nil];
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    NSArray *dividedRec;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *curDate;
    float curWeight;
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *oneResultDict;
    for(NSString *oneRec in arr){
        //NSLog(@"%@", oneRec);
        dividedRec = [oneRec componentsSeparatedByString:@";"];
        if([dividedRec count]<2) continue;
        curDate = [[dateFormatter dateFromString:[dividedRec objectAtIndex:0]] retain];
        if(curDate==nil) continue;
        curWeight = [[dividedRec objectAtIndex:1] floatValue];
        if(curWeight<=0.0) continue;
        [curDate release];
        
        oneResultDict = [[NSMutableDictionary alloc] init];
        [oneResultDict setObject:[curDate retain] forKey:@"date"];
        [oneResultDict setObject:[NSNumber numberWithFloat:curWeight] forKey:@"weight"];
        [resultArray addObject:oneResultDict];
        
        //NSLog(@"%@ -> %.1f", [[oneResultDict objectForKey:@"date"] description], [[oneResultDict objectForKey:@"weight"] floatValue]);
        [curDate release];
        [oneResultDict release];
    };
    [dateFormatter release];
    
    NSArray *res = [NSArray arrayWithArray:resultArray];
    [resultArray release];
    
    return res;
};


- (void)addRecordsToBase:(NSArray *)newRecords{
    NSMutableArray *weightModuleData = (NSMutableArray*)[delegate getValueForName:@"database" fromModuleWithID:@"selfhub.weight"];
    for(NSDictionary *curRec in newRecords){
        NSDate *curDate = [curRec objectForKey:@"date"];
        NSNumber *curWeight = [curRec objectForKey:@"weight"];
        NSLog(@"date: %@, weight: %.1f", [curDate description], [curWeight floatValue]);
        [weightModuleData addObject:curRec];
    };
    [delegate setValue:weightModuleData forName:@"database" forModuleWithID:@"selfhub.weight"];
};

- (void)clearBaseAndAddRecords:(NSArray *)newRecords{
    NSMutableArray *weightModuleData = (NSMutableArray*)[delegate getValueForName:@"database" fromModuleWithID:@"selfhub.weight"];
    [weightModuleData removeAllObjects];
    for(NSDictionary *curRec in newRecords){
        NSDate *curDate = [curRec objectForKey:@"date"];
        NSNumber *curWeight = [curRec objectForKey:@"weight"];
        NSLog(@"date: %@, weight: %.1f", [curDate description], [curWeight floatValue]);
        [weightModuleData addObject:curRec];
    };
    [delegate setValue:weightModuleData forName:@"database" forModuleWithID:@"selfhub.weight"];};

            

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



#pragma mark - Module protoclol implementation

// Initialization of your module. Select NIB-file depending on device (iphone/ipad), set delegate member and perform custom initialization
- (id)initModuleWithDelegate:(id<ServerProtocol>)serverDelegate{
    NSString *nibName;
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        nibName = @"ImportWeight";
    }else{
        return nil;
    };
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        delegate = serverDelegate;
        if(serverDelegate==nil){
            NSLog(@"WARNING: module \"%@\" initialized without server delegate!", [self getModuleName]);
        };
    }
    return self;
};

// Returns visible module's name
- (NSString *)getModuleName{
    return @"Weight Import";
};

// Returns module's description
- (NSString *)getModuleDescription{
    return @"Import weight data from external sources";
};

// Returns current module's message for a user
- (NSString *)getModuleMessage{
    return @"";
};

// Returns module's version
- (float)getModuleVersion{
    return 1.0;
};

// Returns module's icon image (recommended 50x50 or 100x100 for retina displays)
- (UIImage *)getModuleIcon{
    return [UIImage imageNamed:@"exampleModule_icon.png"];
};

// Supporting different devices by module (iphone/ipad)
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

// Loading module data.
- (void)loadModuleData{
    
};

// Saving module data. It's recommend to save module's data in single file with module name and .dat extension. File should be place in documents folder.
- (void)saveModuleData{
    
};

// Handler for pressing navigation bar's left button (show of
- (IBAction)pressMainMenuButton{
    [delegate showSlideMenu];
}


// No need to implement at this time
- (id)getModuleValueForKey:(NSString *)key{
    return nil;
};

// No need to implement at this time
- (void)setModuleValue:(id)object forKey:(NSString *)key{
    
};

@end
