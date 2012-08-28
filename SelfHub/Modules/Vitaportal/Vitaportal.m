//
//  VitaportalViewController.m
//  SelfHub
//
//  Created by Igor Barinov on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Vitaportal.h"

@interface Vitaportal ()

@end


@implementation Vitaportal

@synthesize delegate;
@synthesize moduleView;
@synthesize navBar;
@synthesize navBarItem;
@synthesize slideView;
@synthesize slideImageView;

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
    self.title = NSLocalizedString(@"Vitaportal", @"");
    navBarItem.title = NSLocalizedString(@"Vitaportal", @"");
    
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

- (IBAction)textFieldShouldReturn:(id)sender {
    [sender resignFirstResponder]; 
}


- (void)viewWillDisappear:(BOOL)animated{
    [self saveModuleData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}


- (void)viewDidUnload
{
//    [self setSlideButton:nil];
//    [self setSlideView:nil];
//    [self setSlideImageView:nil];
//    [self setLogoutButton:nil];
//    [self setNavBar:nil];
//    [self setBrendImageView:nil];
//    [self setTableViewImageView:nil];
//    moduleView = nil;
    delegate = nil;
//    medarhivLabel = nil;
//    signOutLabel = nil;
//    usernameField = nil;
//    passwordField = nil;
//    signInButton = nil;
//    signOutButton = nil;
//    activity = nil;
    
//    [self setMainView:nil];
//    [self setNavItemTitle:nil];
    [self setNavBar:nil];
    [self setNavBarItem:nil];
    [self setSlideView:nil];
    [self setSlideImageView:nil];
    [self setModuleView:nil];
    [super viewDidUnload];
    
}
- (void)dealloc{
    
    delegate = nil;
    
    //[viewControllers release];
    //[activity release];
    [user_fio release];
    [user_id release];
    [auth release];
    [user_pass release];
    [user_login release];
    [moduleData release];
    
//    [slideButton release];
//    [slideView release];
//    [slideImageView release];
//    [logoutButton release];
//    [navBar release];
    
//    [brendImageView release];
//    [tableViewImageView release];
//    [mainView release];
//    [navItemTitle release];
    [navBar release];
    [navBarItem release];
    [slideView release];
    [slideImageView release];
    [moduleView release];
    [super dealloc];
};


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Module protocol functions

- (id)initModuleWithDelegate:(id<ServerProtocol>)serverDelegate{
    NSString *nibName;
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        nibName = @"Vitaportal";
    }else{
        return nil;
    };
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
//        moduleData = [[NSMutableDictionary alloc] init];
        delegate = serverDelegate;
        if(serverDelegate==nil){
            NSLog(@"WARNING: module \"%@\" initialized without server delegate!", [self getModuleName]);
        };
    }
    return self;
};


- (NSString *)getModuleName{
    return NSLocalizedString(@"Vitaportal", @"");
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
    
//    NSString *medarhivFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"medarhiv.dat"];               
//    NSDictionary *fileData = [NSDictionary dictionaryWithContentsOfFile:medarhivFilePath];
//    
//    if(!fileData){
//        NSLog(@"Cannot load data from file medarhiv.dat. Loading test data...");
//        if(user_fio==nil) user_fio=@"";
//        if(user_id==nil) user_id=@"";
//        if(auth==nil) auth=@"0";
//        if(user_login==nil) user_login=@"";
//        if(user_pass==nil) user_pass=@"";
//    }else{
//        if(moduleData) [moduleData release]; 
//        moduleData = [[NSMutableDictionary alloc] initWithDictionary:fileData];
//        
//        if(user_fio) [user_fio release];
//        user_fio  = [[moduleData objectForKey:@"user_fio"]retain];
//        
//        if(user_id) [user_id release];
//        user_id = [[moduleData objectForKey:@"user_id"] retain];
//        
//        if(auth) [auth release];
//        auth = [[moduleData objectForKey:@"auth"] retain];
//        
//        if(user_login) [user_login release];
//        user_login = [[moduleData objectForKey:@"user_login"] retain];
//        
//        if(user_pass) [user_pass release];
//        user_pass = [[moduleData objectForKey:@"user_pass"] retain];
//        
//    };
};

- (void)saveModuleData{
//    if([self isViewLoaded]){
//        [moduleData setObject:user_fio forKey:@"user_fio"];
//        [moduleData setObject:user_id forKey:@"user_id"];
//        [moduleData setObject:auth forKey:@"auth"];
//        [moduleData setObject:user_login forKey:@"user_login"];
//        [moduleData setObject:user_pass forKey:@"user_pass"];        
//    };
//    
//    if(moduleData==nil){    
//        return; 
//    };
//    
//    BOOL succ = [moduleData writeToFile:[[self getBaseDir] stringByAppendingPathComponent:@"medarhiv.dat"] atomically:YES];    	
//    if(succ==NO){
//        NSLog(@"ExampleModule: error during save data");        	
//    };
    
};

- (id)getModuleValueForKey:(NSString *)key{
    return nil;
};
- (void)setModuleValue:(id)object forKey:(NSString *)key{    
};

- (IBAction)pressMainMenuButton{
    [delegate showSlideMenu];
};

#pragma mark - Module functions

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

@end
