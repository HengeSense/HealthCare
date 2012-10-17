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
@synthesize delegate, rightBarBtn, viewControllers, segmentedControl;
@synthesize lastuser, auth, lastTime, userID, userPublicKey;

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
    self.navBar.topItem.title = @"Withings";
    
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
    
    LoginWithingsViewController *loginWController = [[LoginWithingsViewController alloc] initWithNibName:@"LoginWithingsViewController" bundle:nil];
    loginWController.delegate = self;
   
    DataLoadWithingsViewController *loadDataWithingsController = [[DataLoadWithingsViewController alloc] initWithNibName:@"DataLoadWithingsViewController" bundle:nil];
    loadDataWithingsController.delegate = self;
    
    //loginWController,
    viewControllers = [[NSArray alloc] initWithObjects:loginWController, loadDataWithingsController, nil];
   
    [loadDataWithingsController release];
    [loginWController release];
        
    if([auth isEqualToString:@"0"] || [auth isEqualToString:@""] || auth==nil ){        
        segmentedControl.selectedSegmentIndex = 0;
        currentlySelectedViewController = 0;
        [rightBarBtn setEnabled:false];
    } else{
        segmentedControl.selectedSegmentIndex = 1;
        currentlySelectedViewController = 1;
        [rightBarBtn setEnabled:true];
    }
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


- (void)viewDidUnload {
    [self setModuleView:nil];
    [self setNavBar:nil];
    [self setHostView:nil];
    [self setSlideView:nil];
    [self setSlideImageView:nil];
    segmentedControl = nil;
    [self setLogoutButton:nil];
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
    [super dealloc];
}

#pragma mark - Module protocol functions

- (id)initModuleWithDelegate:(id<ServerProtocol>)serverDelegate{
    NSString *nibName;
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        nibName = @"Withings";
    }else{
        return nil;
    };
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        moduleData = [[NSMutableDictionary alloc] init];
        delegate = serverDelegate;
        if(serverDelegate==nil){
            NSLog(@"WARNING: module \"%@\" initialized without server delegate!", [self getModuleName]);
        };
    }
    return self;
};


- (NSString *)getModuleName{
    return NSLocalizedString(@"Withings", @"");
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
    return [UIImage imageNamed:@"navigation_icon.png"];
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
    
    NSString *medarhivFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"withings.dat"];               
    NSDictionary *fileData = [NSDictionary dictionaryWithContentsOfFile:medarhivFilePath];
    
    if(!fileData){
//        NSLog(@"Cannot load data from file medarhiv.dat. Loading test data...");
//        if(user_fio==nil) user_fio=@"";
        
        if(auth==nil) auth=@"0";
        lastuser=0;
        lastTime=0;
        userID=0;
        if(userPublicKey==nil) userPublicKey=@"";
//        if(user_pass==nil) user_pass=@"";
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
        
//        if(user_login) [user_login release];
//        user_login = [[moduleData objectForKey:@"user_login"] retain];
//        
//        if(user_pass) [user_pass release];
//        user_pass = [[moduleData objectForKey:@"user_pass"] retain];
        
    };
};

- (void)saveModuleData{
    if([self isViewLoaded]){
        [moduleData setObject:userPublicKey forKey:@"userPublicKey"];
        [moduleData setObject:[NSNumber numberWithInt:userID] forKey:@"userID"];
        [moduleData setObject:auth forKey:@"auth"];
        [moduleData setObject:[NSNumber numberWithInt:lastTime] forKey:@"lastTime"];
        [moduleData setObject:[NSNumber numberWithInt:lastuser] forKey:@"lastuser"];
//        [moduleData setObject:user_login forKey:@"user_login"];
//        [moduleData setObject:user_pass forKey:@"user_pass"];        
    };
    
    if(moduleData==nil){    
        return; 
    };
    
    BOOL succ = [moduleData writeToFile:[[self getBaseDir] stringByAppendingPathComponent:@"withings.dat"] atomically:YES];    	
    if(succ==NO){
        NSLog(@"ExampleModule: error during save data");        	
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
    
    if(currentlySelectedViewController==1){
        [rightBarBtn setEnabled:true];
    } else {
        [rightBarBtn setEnabled:false];
    }
    
    [self hideSlidingMenu:nil];
};

- (IBAction)logoutButtonClick:(id)sender {

    for(UIViewController *item in viewControllers)
    {
        if([item isKindOfClass:[LoginWithingsViewController class]] == YES)
        {
            [(LoginWithingsViewController*)item cleanup];
        }
        if([item isKindOfClass:[DataLoadWithingsViewController class]] == YES)
        {
             [(DataLoadWithingsViewController*)item cleanup];
        }
    }
    [self selectScreenFromMenu:sender];

    auth = @"0"; 
    lastuser = userID;
    userID = 0;
    userPublicKey = @"";
    [self saveModuleData];

    
}



@end
