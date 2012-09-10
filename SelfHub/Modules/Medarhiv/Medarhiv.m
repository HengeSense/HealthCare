//
//  Medarhiv.m
//  SelfHub
//
//  Created by Elena Trishina on 7/10/12.
//  Copyright (c) 2012 __HintSolutions__. All rights reserved.
//

#import "Medarhiv.h"
#import "WorkWithWithings.h"

@interface Medarhiv ()
@property (nonatomic, retain) NSArray *viewControllers;
@end

@implementation Medarhiv
//@synthesize tableViewSingin;
@synthesize tableViewImageView;
@synthesize mainView;

@synthesize delegate;
@synthesize medarhivLabel, signOutLabel;
@synthesize usernameField, passwordField;
@synthesize signInButton, signOutButton;
@synthesize viewControllers, auth, user_id, user_fio, user_login, user_pass;
@synthesize moduleView, hostView;
@synthesize navBar;
@synthesize brendImageView;
@synthesize navItemTitle;
@synthesize slideButton;
@synthesize slideView;
@synthesize slideImageView;
@synthesize logoutButton;
@synthesize activity;


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
    self.title = NSLocalizedString(@"Medarhiv", @"");
    navItemTitle.title = NSLocalizedString(@"Medarhiv", @"");
    [self fillAllFieldsLocalized];
    
    UIView *springView  = [[UIView alloc] initWithFrame:CGRectMake(0, 41, 320, 13)];
    [self.view addSubview:springView];
    UIImage *springImBig = [UIImage imageNamed:@"spring@2x.png"];
    UIImage *springIm = [[UIImage alloc] initWithCGImage:[springImBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    [springView setBackgroundColor:[UIColor colorWithPatternImage:springIm]];
    [springIm release];
    [springView release];
   
    //--- applied design ---
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"medarhiv_background.png"]];
    mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"medarhiv_background.png"]];
    
    
    
//    UIImage *brendIm = [UIImage imageNamed:@"brend@2x.png"];
//    UIImage *brendImage = [[UIImage alloc] initWithCGImage:[brendIm CGImage] scale:1.0 orientation:UIImageOrientationUp];
//    UIImageView *brendImView = [[UIImageView alloc] initWithImage:brendImage];
//    [brendImView setFrame:CGRectMake(60, 60, 189, 45)];  
//    [moduleView addSubview:brendImView];    
//    [brendImage release];
//    [brendImView release];
    
    
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
    
    [logoutButton setImage:[UIImage imageNamed:@"DesktopCellBackground.png"] forState:UIControlStateNormal];
    [logoutButton setImage:[UIImage imageNamed:@"DesktopCellBackground_press.png"] forState:UIControlStateHighlighted];
    UILabel *logoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 7.0, 80.0, 32.0)];
    logoutLabel.textColor = [UIColor lightTextColor];
    logoutLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    [logoutLabel setBackgroundColor:[UIColor clearColor]];
    logoutLabel.text = NSLocalizedString(@"Logout", @"");
    [logoutButton addSubview:logoutLabel];
    [logoutLabel release];
    
    slideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    slideButton.frame = CGRectMake(0.0, 0.0, 42.0, 32.0);
    [slideButton setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton.png"] forState:UIControlStateNormal];
    [slideButton setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton_press.png"] forState:UIControlStateHighlighted];
    [slideButton addTarget:self action:@selector(showSlidingMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:slideButton];
    self.navBar.topItem.rightBarButtonItem = rightBarButtonItem;
    [rightBarButtonItem release];
    
    [self.signOutButton setImage:[UIImage imageNamed:@"signout_press@2x.png"] forState:UIControlStateHighlighted];
    [self.signInButton setImage:[UIImage imageNamed:@"signin_press@2x.png"] forState:UIControlStateHighlighted];
    usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    // -- end design ---
    
    LoadViewController *loadViewController = [[[LoadViewController alloc] initWithNibName:@"LoadViewController" bundle:nil] autorelease];
    loadViewController.delegate = self;
    viewControllers = [[NSArray alloc] initWithObjects:loadViewController,nil];
    
    
    [hostView addSubview:((UIViewController *)[viewControllers objectAtIndex:0]).view]; 
    
    if([auth isEqualToString:@"0"] || auth==nil){
        [hostView setHidden:TRUE];
        [slideButton setEnabled:false];
    }else{
        [hostView setHidden:FALSE];
        [slideButton setEnabled:TRUE];
    }
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

- (void) fillAllFieldsLocalized {
    [activity setHidden: true];
    medarhivLabel.text = NSLocalizedString(@"MedarhivMainLabel", @"");
    signOutLabel.text = NSLocalizedString(@"SignOutLabel", @"");
        
    usernameField.placeholder = NSLocalizedString(@"Login", @"");
    usernameField.returnKeyType =  UIReturnKeyDefault;
    passwordField.placeholder = NSLocalizedString(@"Password", @"");
    
    [signInButton setTitle:NSLocalizedString(@"SignIn", @"") forState:UIControlStateNormal];
    [signOutButton setTitle:NSLocalizedString(@"SignOut", @"") forState:UIControlStateNormal];
    
}

- (IBAction)textFieldShouldReturn:(id)sender {
    [sender resignFirstResponder]; 
}

//- (void)viewWillAppear:(BOOL)animated{
//    
//};


- (void)viewWillDisappear:(BOOL)animated{
    [self saveModuleData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}


- (void)viewDidUnload
{
    [self setSlideButton:nil];
    [self setSlideView:nil];
    [self setSlideImageView:nil];
    [self setLogoutButton:nil];
    [self setNavBar:nil];
    [self setBrendImageView:nil];
    [self setTableViewImageView:nil];
    moduleView = nil;
    delegate = nil;
    medarhivLabel = nil;
    signOutLabel = nil;
    usernameField = nil;
    passwordField = nil;
    signInButton = nil;
    signOutButton = nil;
    activity = nil;
    
    [self setMainView:nil];
    [self setNavItemTitle:nil];
    [super viewDidUnload];
    
}
- (void)dealloc{
    
    delegate = nil;
    [medarhivLabel release];
    [signOutLabel release];
    [usernameField release];
    [passwordField release];
    [signInButton release];
    [signOutButton release];
    [viewControllers release];
    [activity release];
    [user_fio release];
    [user_id release];
    [auth release];
    [user_pass release];
    [user_login release];
    [moduleData release];
    
    [slideButton release];
    [slideView release];
    [slideImageView release];
    [logoutButton release];
    [navBar release];

    [brendImageView release];
    [tableViewImageView release];
    [mainView release];
    [navItemTitle release];
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
        nibName = @"Medarhiv";
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
    return NSLocalizedString(@"Medarhiv", @"");
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
    
    NSString *medarhivFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"medarhiv.dat"];               
    NSDictionary *fileData = [NSDictionary dictionaryWithContentsOfFile:medarhivFilePath];

    if(!fileData){
        NSLog(@"Cannot load data from file medarhiv.dat. Loading test data...");
        if(user_fio==nil) user_fio=@"";
        if(user_id==nil) user_id=@"";
        if(auth==nil) auth=@"0";
        if(user_login==nil) user_login=@"";
        if(user_pass==nil) user_pass=@"";
    }else{
        if(moduleData) [moduleData release]; 
        moduleData = [[NSMutableDictionary alloc] initWithDictionary:fileData];
        
        if(user_fio) [user_fio release];
        user_fio  = [[moduleData objectForKey:@"user_fio"]retain];
                
        if(user_id) [user_id release];
        user_id = [[moduleData objectForKey:@"user_id"] retain];
                
        if(auth) [auth release];
        auth = [[moduleData objectForKey:@"auth"] retain];
        
        if(user_login) [user_login release];
        user_login = [[moduleData objectForKey:@"user_login"] retain];
                
        if(user_pass) [user_pass release];
        user_pass = [[moduleData objectForKey:@"user_pass"] retain];
        
    };
};

- (void)saveModuleData{
    if([self isViewLoaded]){
        [moduleData setObject:user_fio forKey:@"user_fio"];
        [moduleData setObject:user_id forKey:@"user_id"];
        [moduleData setObject:auth forKey:@"auth"];
        [moduleData setObject:user_login forKey:@"user_login"];
        [moduleData setObject:user_pass forKey:@"user_pass"];        
    };
    
    if(moduleData==nil){    
        return; 
    };
    
    BOOL succ = [moduleData writeToFile:[[self getBaseDir] stringByAppendingPathComponent:@"medarhiv.dat"] atomically:YES];    	
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


#pragma mark  Medarhiv functions

- (IBAction)pressSignInButton:(UIButton *)sender {
    
    [self textFieldShouldReturn:passwordField];
    [self textFieldShouldReturn:usernameField];
    
    if (![usernameField.text isEqualToString:@""] && ![passwordField.text isEqualToString:@""]){
        [activity setHidden: false];
        [activity startAnimating];
        
        NSURL *signinrUrl = [NSURL URLWithString:@"https://medarhiv.ru"];
        id	context = nil;
        NSMutableURLRequest *requestSigninMedarhiv = [NSMutableURLRequest requestWithURL:signinrUrl 
                                                                             cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                                         timeoutInterval:30.0];
        
        
        [requestSigninMedarhiv setHTTPMethod:@"POST"];
        [requestSigninMedarhiv setHTTPBody:[[NSString stringWithFormat:@"cmd=srv&action=auth&email=%@&pass=%@", usernameField.text, passwordField.text] dataUsingEncoding:NSWindowsCP1251StringEncoding]]; 
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self
                                                             action:@selector(handleResultOrError:withContext:)
                                                            context:context] autorelease];
        
        NSURLConnection* conn = [NSURLConnection connectionWithRequest:requestSigninMedarhiv delegate:network];
        [conn start];
    } else{
        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
        
    }    
}

- (void)handleResultOrError:(id)resultOrError withContext:(id)context
{
    
    if ([resultOrError isKindOfClass:[NSError class]])
	{
        
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];
        [activity stopAnimating]; 
        [activity setHidden:true];
		return; 
	}
    
	//NSURLResponse* response = [resultOrError objectForKey:@"response"];
	NSData* data = [resultOrError objectForKey:@"data"];
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    if ([[res objectForKey:@"result"] intValue]==1){
        user_fio = [res objectForKey:@"fio"];
        user_id = [res objectForKey:@"userID"] ;
        auth = (NSString*)[[res objectForKey:@"result"] stringValue]; 
        user_login = usernameField.text;
        user_pass = passwordField.text;
        [self saveModuleData];
        
        //    NSLog(@"key: %@", res);
        [[[viewControllers lastObject] fioLabel] setText:[res objectForKey:@"fio"]]; 
        [hostView setHidden:FALSE];
        [slideButton setEnabled:true];
        
    } else {        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Wrong username or password. Check the entered data.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];        
    }
    [activity stopAnimating]; 
    [activity setHidden:true];
    
}


- (IBAction)PressSignOutButton:(UIButton *)sender {
    
    SignUpMedarhivViewController *signupViewController = [[SignUpMedarhivViewController alloc] initWithNibName:@"SignUpMedarhivViewController" bundle:nil];
    signupViewController.delegate = self;
    [self presentModalViewController:signupViewController animated:YES];
    [signupViewController release];
    
}

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

- (IBAction)logoutButtonPressed:(id)sender {
       
    [((UIViewController *)[viewControllers objectAtIndex:0]).view removeFromSuperview];
    self.view = moduleView;
    [self.hostView addSubview:[[viewControllers objectAtIndex:0] view]];
    [passwordField setText:@""];
    [hostView setHidden:TRUE];
    [slideButton setEnabled:false];
    [self hideSlidingMenu:nil];
    
    for(UIViewController *item in viewControllers)
    {
        if([item isKindOfClass:[LoadViewController class]] == YES)
        {
            [(LoadViewController*)item cleanup];
        }
    }
    
    user_fio = @"";
    user_id = @"";
    auth = @"0"; 
    user_login = usernameField.text;
    user_pass = @"";
    [self saveModuleData];
    
    
}

@end
