//
//  Withings.m
//  SelfHub
//
//  Created by Igor Barinov on 10/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Withings.h"

@interface Withings ()

@end

@implementation Withings
@synthesize logoutButton;

@synthesize hostView;
@synthesize slideView, slideImageView;
@synthesize moduleView;
@synthesize navBar;
@synthesize delegate, rightBarBtn, viewControllers, segmentedControl, tutorialButton;
@synthesize lastuser, auth, lastTime, userID, userPublicKey, notify, listOfUsers, user_firstname, expNotifyDate;

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
    
    [self designInitialization];    
    LoginWithingsViewController *loginWController = [[LoginWithingsViewController alloc] initWithNibName:@"LoginWithingsViewController" bundle:nil];
    loginWController.delegate = self;
    
    DataLoadWithingsViewController *loadDataWithingsController = [[DataLoadWithingsViewController alloc] initWithNibName:@"DataLoadWithingsViewController" bundle:nil];
    loadDataWithingsController.delegate = self;
    
    //loginWController,
    viewControllers = [[NSArray alloc] initWithObjects:loginWController, loadDataWithingsController, nil];
    
    [loadDataWithingsController release];
    [loginWController release];
    
    segmentedControl.selectedSegmentIndex = 0;
    currentlySelectedViewController = 0;
    [rightBarBtn setEnabled:false];
        
    [hostView addSubview:((UIViewController *)[viewControllers objectAtIndex:currentlySelectedViewController]).view];
    
    self.view = moduleView;
    
    //slideing-out navigation support
    slideImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreenshot:)];
    [slideImageView addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveScreenshot:)];
    [panGesture setMaximumNumberOfTouches:2];
    [slideImageView addGestureRecognizer:panGesture];
    [tapGesture release];
    [panGesture release];
    
}


-(void) designInitialization {
    self.navBar.topItem.title = @"Withings";
    
    
    UIImageView *darkPathImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DesktopVerticalDarkRightPath.png"]];
    float verticalPathHeight = [UIScreen mainScreen].bounds.size.height;
    darkPathImage.frame = CGRectMake(self.view.frame.size.width, 0, darkPathImage.frame.size.width, verticalPathHeight);
    darkPathImage.userInteractionEnabled = NO;
    [slideImageView addSubview:darkPathImage];
    [darkPathImage release];
    
    UIImage *slideBackgroundImageBig = [UIImage imageNamed:@"DesktopBackgroundPortrait.png"];
    UIImage *slideBackgroundImage = [[UIImage alloc] initWithCGImage:[slideBackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    slideView.backgroundColor = [UIColor colorWithPatternImage:slideBackgroundImage];
    [slideBackgroundImage release];
    
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
    
    rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.frame = CGRectMake(0.0, 0.0, 42.0, 32.0);
    [rightBarBtn setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton.png"] forState:UIControlStateNormal];
    [rightBarBtn setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton_press.png"] forState:UIControlStateHighlighted];
    [rightBarBtn addTarget:self action:@selector(showSlidingMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navBar.topItem.rightBarButtonItem = rightBarButtonItem;
    [rightBarButtonItem release];
    
    float tutorialButtonOriginX = (self.view.bounds.size.width/2.0) + ([self.navBar.topItem.title sizeWithFont:[UIFont boldSystemFontOfSize:18.0]].width/2.0) + 5.0;
    tutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(tutorialButtonOriginX, 6.0, 32.0, 32.0)];
    [tutorialButton setImage:[UIImage imageNamed:@"DesktopNavBar_tutorialBtn_norm.png"] forState:UIControlStateNormal];
    [tutorialButton setImage:[UIImage imageNamed:@"DesktopNavBar_tutorialBtn_press.png"] forState:UIControlStateHighlighted];
    [tutorialButton addTarget:self action:@selector(showTutorial:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:tutorialButton];
    
    NSString *imagePath1 = ([delegate isRetina4] ? @"tutorial_wihings2_iphone5-568@2x" : @"tutorial_img@2x");   
    tutorialBackgroundImages = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imagePath1 ofType:@"png"]];
   
    
    UIImage *BackgroundImageBig = [UIImage imageNamed:@"withings_background-568h@2x.png"];
    UIImage *BackgroundImage = [[UIImage alloc] initWithCGImage:[BackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    self.moduleView.backgroundColor = [UIColor colorWithPatternImage:BackgroundImage];
    self.hostView.backgroundColor = [UIColor colorWithPatternImage: BackgroundImage];
    
    self.hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.moduleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [BackgroundImage release];
    
    [logoutButton setImage:[UIImage imageNamed:@"DesktopCellBackground.png"] forState:UIControlStateNormal];
    [logoutButton setImage:[UIImage imageNamed:@"DesktopCellBackground_press.png"] forState:UIControlStateHighlighted];
    UILabel *logoutButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 7.0, 80.0, 32.0)];
    logoutButtonLabel.textColor = [UIColor lightTextColor];
    logoutButtonLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    [logoutButtonLabel setBackgroundColor:[UIColor clearColor]];
    logoutButtonLabel.text = NSLocalizedString(@"Logout", @"");
    [logoutButton addSubview:logoutButtonLabel];
    [logoutButtonLabel release];
    
}


- (BOOL) checkAndTurnOnNotification{
    NetworkStatus curStatus;
    curStatus= [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    BOOL resultNotify;
    if(curStatus != NotReachable){ 
        WorkWithWithings *notifyWork = [[WorkWithWithings alloc] init];
        notifyWork.user_id = userID;
        notifyWork.user_publickey = userPublicKey;
        [notifyWork getNotificationRevoke:1];
        [UAPush shared].alias = @""; 
        [[UAPush shared] registerDeviceToken:(NSData*)[UAPush shared].deviceToken];
        resultNotify = [notifyWork getNotificationSibscribeWithComment:@"reconnection" andAppli:1];
        NSString *yourAlias = [NSString stringWithFormat:@"%d", userID];
        [UAPush shared].alias = yourAlias; 
        [[UAPush shared] registerDeviceToken:(NSData*)[UAPush shared].deviceToken];
        [notifyWork release];
    }else{
        return true;
    }
    return resultNotify;
}

- (void)viewDidUnload {
    [self setModuleView:nil];
    [self setNavBar:nil];
    [self setHostView:nil];
    [self setSlideView:nil];
    [self setSlideImageView:nil];
    [self setSegmentedControl:nil]; 
    [self setLogoutButton:nil];
    
    [self setAuth:nil];
    [self setNotify:nil];
    [self setUserPublicKey:nil];
    [self setListOfUsers:nil];
    [self setUser_firstname:nil];
    [self setTutorialButton:nil];
    tutorialBackgroundImages = nil;
    
    [super viewDidUnload];
    
}
- (void)viewWillAppear:(BOOL)animated{
    if(moduleData==nil){
        [self loadModuleData];
    }
};

- (void)viewWillDisappear:(BOOL)animated{
    [self saveModuleData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc{
    
    delegate = nil;
    [moduleView release];
    [navBar release];
    [hostView release];
    [slideView release];
    [slideImageView release];
    [logoutButton release];
    
    [auth release];
    [notify release];
    [userPublicKey release];
    [listOfUsers release];
    [user_firstname release];
    [tutorialButton release];
    [tutorialBackgroundImages release];

    [moduleData release];
    [viewControllers release];
    [rightBarBtn release];
    [segmentedControl release];
    [super dealloc];
}

#pragma mark - Module protocol functions

- (id)initModuleWithDelegate:(id<ServerProtocol>)serverDelegate{
    NSString *nibName;
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        nibName = @"Withings";
    }else{
        return nil;
    }
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        moduleData = [[NSMutableDictionary alloc] init];
        delegate = serverDelegate;
        if(serverDelegate==nil){
            //NSLog(@"WARNING: module \"%@\" initialized without server delegate!", [self getModuleName]);
        };
    }
    return self;
};


- (NSString *)getModuleName{
    return @"Withings";
};
- (NSString *)getModuleDescription{
    return @"The module  etc.";
};
- (NSString *)getModuleMessage{
    return @"Enter !";
};
- (float)getModuleVersion{
    return 1.0f;
};
- (UIImage *)getModuleIcon{
    return [UIImage imageNamed:@"Moduls_Icons_Withings.png"];
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
    }
    return res;
};

- (NSString *)getBaseDir{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
};


- (void)loadModuleData{  
    
    NSString *withingsFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"withings.dat"];               
    NSDictionary *fileData = [NSDictionary dictionaryWithContentsOfFile:withingsFilePath];
    
    if(!fileData){        
        if(auth==nil) auth=@"0";
        lastuser=0;
        lastTime=0;
        userID=0;
        if(userPublicKey==nil) userPublicKey=@"";
        if(notify==nil) notify=@"0";
        if(user_firstname==nil) user_firstname=@"";
        expNotifyDate = 0;
    }else{
        if(moduleData) [moduleData release]; 
        moduleData = [[NSMutableDictionary alloc] initWithDictionary:fileData];
        
        if(userPublicKey) [userPublicKey release];
        userPublicKey  = [[moduleData objectForKey:@"userPublicKey"]retain];
        
        if(auth) [auth release];
        auth = [[moduleData objectForKey:@"auth"] retain];
        
        lastuser = [[moduleData objectForKey:@"lastuser"] intValue];
        lastTime = [[moduleData objectForKey:@"lastTime"] intValue];
        userID = [[moduleData objectForKey:@"userID"] intValue];
        expNotifyDate = [[moduleData objectForKey:@"expNotifyDate"] intValue];
        
        if(notify) [notify release];
        notify = [[moduleData objectForKey:@"notify"] retain];
        
        if(listOfUsers) [listOfUsers release];
        listOfUsers = [[moduleData objectForKey:@"listOfUsers"] retain];
        
        if(user_firstname) [user_firstname release];
        user_firstname = [[moduleData objectForKey:@"user_firstname"] retain];
        
    };
};

- (void)saveModuleData{
    
    if([self isViewLoaded]){
        [moduleData setObject:userPublicKey forKey:@"userPublicKey"];
        [moduleData setObject:[NSNumber numberWithInt:userID] forKey:@"userID"];
        [moduleData setObject:auth forKey:@"auth"];
        [moduleData setObject:[NSNumber numberWithInt:lastTime] forKey:@"lastTime"];
        [moduleData setObject:[NSNumber numberWithInt:lastuser] forKey:@"lastuser"];
        [moduleData setObject:[NSNumber numberWithInt:expNotifyDate] forKey:@"expNotifyDate"];
        [moduleData setObject:notify forKey:@"notify"];
        [moduleData setObject:user_firstname forKey:@"user_firstname"];
        if(listOfUsers)[moduleData setObject:listOfUsers forKey:@"listOfUsers"];
    };
    
    if(moduleData==nil){    
        return; 
    }
    
    BOOL succop = [moduleData writeToFile:[[self getBaseDir] stringByAppendingPathComponent:@"withings.dat"] atomically:YES];
    if(succop==NO){
       // NSLog(@"ExampleModule: error during save data");
    };
    
};

- (id)getModuleValueForKey:(NSString *)key{
    return nil;
};
- (void)setModuleValue:(id)object forKey:(NSString *)key{    
};

- (void)receiveRemoteNotification:(NSDictionary*) userInfo{
    if([notify isEqualToString:@"1"] && userID!=0){
        int alias = [[userInfo objectForKey:@"userid"] intValue];
        if(userID == alias){
            DataLoadWithingsViewController *loadDataWController = [[[DataLoadWithingsViewController alloc]initWithNibName:@"DataLoadWithingsViewController" bundle:nil] autorelease];
            loadDataWController.delegate = self;
            [loadDataWController loadDataForPushNotify];
        }
    }
}

- (IBAction)pressMainMenuButton{
    [delegate showSlideMenu];
};

- (IBAction)showSlidingMenu:(id)sender{
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    slideImageView.image = image;
    
    self.view = slideView;
    
    slideImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slideImageView setFrame:CGRectMake(-130, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){
        
    }];    
};


- (IBAction)hideSlidingMenu:(id)sender{
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
    [self.moduleView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    slideImageView.image = image;
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slideImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
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

#pragma mark - Module's tutorial supporting

- (IBAction)showTutorial:(id)sender{
    UILabel *myLabel;
    UIView *tutorialView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImageView *tutorialBackground = [[UIImageView alloc] initWithImage:tutorialBackgroundImages];
    [tutorialView addSubview:tutorialBackground];
    [tutorialBackground release];
    
    myLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 66.0, 125.0, 20.0)];
    myLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    myLabel.backgroundColor = [UIColor clearColor];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.textAlignment = NSTextAlignmentLeft;
    myLabel.text = NSLocalizedString(@"Module selection", @"");
    [tutorialView addSubview:myLabel];
    [myLabel release];
    
    myLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 94.0, 125.0, 20.0)];
    myLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    myLabel.backgroundColor = [UIColor clearColor];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.textAlignment = NSTextAlignmentRight;
    myLabel.text = NSLocalizedString(@"Module's pages", @"");
    [tutorialView addSubview:myLabel];
    [myLabel release];

    [delegate showTutorial:tutorialView];
    
    [tutorialView release];
};

- (IBAction)hideTutorial:(id)sender{
    //NSLog(@"HIDE tutorial...");
};


- (IBAction)selectScreenFromMenu:(id)sender{
    [((UIViewController *)[viewControllers objectAtIndex:currentlySelectedViewController]).view removeFromSuperview];
    if(segmentedControl.selectedSegmentIndex >= [viewControllers count]){
        [hostView addSubview:((UIViewController *)[viewControllers objectAtIndex:0]).view];
        segmentedControl.selectedSegmentIndex = 0;
        currentlySelectedViewController = 0;
        [self hideSlidingMenu:nil];
        return;
    }

    [self.hostView addSubview:[[viewControllers objectAtIndex:[sender tag]] view]];
    currentlySelectedViewController = [sender tag];
    
    [self hideSlidingMenu:nil];
};

- (IBAction)logoutButtonClick:(id)sender {
    
    if([notify isEqualToString:@"0"] || userID==0){
        [self logoutFromModule];
        [self selectScreenFromMenu:sender];
    }else{
        NetworkStatus curStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        if(curStatus != NotReachable){
            [self logoutFromModule];
            [self selectScreenFromMenu:sender];
        }else{
            [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];
        }
    }
}

-(void) logoutFromModule {
    for(UIViewController *item in viewControllers){
        if([item isKindOfClass:[LoginWithingsViewController class]] == YES){
            [(LoginWithingsViewController*)item cleanup];
        }
        if([item isKindOfClass:[DataLoadWithingsViewController class]] == YES){
            [(DataLoadWithingsViewController*)item cleanup];
        }
    }
    
    [rightBarBtn setEnabled:false];
    
    auth = @"0"; 
    userID = 0;
    userPublicKey = @"";
    listOfUsers = nil;
    user_firstname = @""; 
    [self saveModuleData];
    
}



@end
