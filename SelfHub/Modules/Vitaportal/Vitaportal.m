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

@synthesize authButton;
@synthesize delegate;
@synthesize moduleView, hostView;
@synthesize navBar, navBarItem;
@synthesize slideView, slideImageView;
@synthesize viewControllers, segmentedControl, rightBarBtn;
@synthesize user_fio, user_id, user_login, user_pass, auth, agreement;

//
@synthesize user_string;
//

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
    
    rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.frame = CGRectMake(0.0, 0.0, 42.0, 32.0);
    [rightBarBtn setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton.png"] forState:UIControlStateNormal];
    [rightBarBtn setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton_press.png"] forState:UIControlStateHighlighted];
    [rightBarBtn addTarget:self action:@selector(showSlidingMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navBar.topItem.rightBarButtonItem = rightBarButtonItem;
    [rightBarButtonItem release];
    
    //Creating module controllers
    AgreementView *agreemController = [[AgreementView alloc] initWithNibName:@"AgreementView" bundle:nil];
    agreemController.delegate = self;
    
    AuthView *authViewController = [[AuthView alloc] initWithNibName:@"AuthView" bundle:nil];
    authViewController.delegate = self;
    
    AllAdvicesView *allAdvicesController = [[AllAdvicesView alloc] initWithNibName:@"AllAdvicesView" bundle:nil];
    allAdvicesController.delegate = self;
    
    
    viewControllers = [[NSArray alloc] initWithObjects: authViewController, agreemController, allAdvicesController, nil];
    
    [authViewController release];
    [allAdvicesController release];
    [agreemController release];
    
    [hostView addSubview:((UIViewController *)[viewControllers objectAtIndex:0]).view];
    //TODO: добавить проверку было ли принято соглашение и соотв-но надо хранить это флаг в модуле
        
    if([agreement isEqualToString:@"1"] || [agreement isEqualToString:@""] || agreement==nil ){        
        segmentedControl.selectedSegmentIndex = 0;
        currentlySelectedViewController = 0;
        [rightBarBtn setEnabled:false];
    } else{
        //TODO: поправить немного логику
        segmentedControl.selectedSegmentIndex = 2;
        currentlySelectedViewController = 2;
        [rightBarBtn setEnabled:true];
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

- (IBAction)textFieldShouldReturn:(id)sender {
    [sender resignFirstResponder]; 
}


- (void)viewWillDisappear:(BOOL)animated{
    [self saveModuleData];
}

-(void) viewWillAppear:(BOOL)animated{
    [[viewControllers objectAtIndex:currentlySelectedViewController] viewWillAppear:animated];
    
//    UIBarButtonItem *rightBtn;
//    if(currentlySelectedViewController==0){
//        rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Test-fill" style:UIBarButtonSystemItemAction target:[viewControllers objectAtIndex:0] action:@selector(pressDefault)];
//        self.navigationItem.rightBarButtonItem = rightBtn;
//        [rightBtn release];
//    }else if(currentlySelectedViewController==1){
//        rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonSystemItemEdit target:[viewControllers objectAtIndex:1] action:@selector(pressEdit)];
//        self.navigationItem.rightBarButtonItem = rightBtn;
//        [rightBtn release];
//    }else{
//        self.navigationItem.rightBarButtonItem = nil;
//    };    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

- (void)viewDidUnload
{

    delegate = nil;

    [self setNavBar:nil];
    [self setNavBarItem:nil];
    [self setSlideView:nil];
    [self setSlideImageView:nil];
    [self setModuleView:nil];
    [self setHostView:nil];
    segmentedControl = nil;
    [self setAuthButton:nil];
    [super viewDidUnload];
    
}

- (void)dealloc{
    
    delegate = nil;
    
    [viewControllers release];
    [user_fio release];
    [user_id release];
    [auth release];
    [user_pass release];
    [user_login release];
    [moduleData release];
    [navBar release];
    [navBarItem release];
    [slideView release];
    [slideImageView release];
    [moduleView release];
    [hostView release];
    [authButton release];
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
        moduleData = [[NSMutableDictionary alloc] init];
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
    
    NSString *vitapotalFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"vitaportal.dat"];               
    NSDictionary *fileData = [NSDictionary dictionaryWithContentsOfFile:vitapotalFilePath];
    
    if(!fileData){
        NSLog(@"Cannot load data from file medarhiv.dat. Loading test data...");
        if(user_fio==nil) user_fio=@"";
        if(user_id==nil) user_id=@"";
        if(auth==nil) auth=@"1";
        if(user_login==nil) user_login=@"";
        if(user_pass==nil) user_pass=@"";
        if(agreement==nil) agreement=@"1";
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
        
        if(agreement) [agreement release];
        agreement = [[moduleData objectForKey:@"agreement"] retain];
        
    };
};

- (void)saveModuleData{
    if([self isViewLoaded]){
        [moduleData setObject:user_fio forKey:@"user_fio"];
        [moduleData setObject:user_id forKey:@"user_id"];
        [moduleData setObject:auth forKey:@"auth"];
        [moduleData setObject:user_login forKey:@"user_login"];
        [moduleData setObject:user_pass forKey:@"user_pass"]; 
        [moduleData setObject:user_pass forKey:@"agreement"]; 
    };
    
    if(moduleData==nil)
    {
        return; 
    };
    
    BOOL succ = [moduleData writeToFile:[[self getBaseDir] stringByAppendingPathComponent:@"vitaportal.dat"] atomically:YES];    	
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

#pragma mark - Module functions

- (IBAction)selectScreenFromMenu:(id)sender
{
    /*
    [((UIViewController *)[viewControllers objectAtIndex:currentlySelectedViewController]).view removeFromSuperview];
    if(segmentedControl.selectedSegmentIndex >= [viewControllers count]){
        [hostView addSubview:((UIViewController *)[viewControllers objectAtIndex:2]).view];
        segmentedControl.selectedSegmentIndex = 2;
        currentlySelectedViewController = 2;
        [self hideSlidingMenu:nil];
        return;
    };
     */
    if([sender tag] < 3)
    {
    [self.hostView addSubview:[[viewControllers objectAtIndex:[sender tag]] view]];
    currentlySelectedViewController = [sender tag];
    }
    
    if([sender tag] == 2)
    {
        AllAdvicesView *all = [viewControllers objectAtIndex:2];
        all.mainScroll.hidden = NO;
        all.favoritesScroll.hidden = YES;
        [all downloadFirstAdvices];
        //NSLog(@"%f %f", all.mainScroll.contentSize.width, all.favoritesScroll.contentSize.height);
        //NSLog(@"%f", all.mainScroll.frame.size.height);
    }
    
    if([sender tag] == 3)
    {
        AllAdvicesView *all = [viewControllers objectAtIndex:2];
        all.mainScroll.hidden = YES;
        all.favoritesScroll.hidden = NO;
        
        /*
         for(AdviceView *adv in all.favoritePages)
        {
            NSLog(@"%@",adv.advice.title);
        }
        NSLog(@"%f %f", all.favoritesScroll.contentSize.width, all.favoritesScroll.contentSize.height);
        NSLog(@"%f", all.favoritesScroll.frame.size.height);
        
        */
    }
    if(currentlySelectedViewController!=0){
        [rightBarBtn setEnabled:TRUE];  
    }     
    [self hideSlidingMenu:nil];
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


@end
