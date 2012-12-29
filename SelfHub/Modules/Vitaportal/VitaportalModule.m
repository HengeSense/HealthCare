//
//  ExampleModule.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 24.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VitaportalModule.h"
#import "ModuleTableCell.h"

@interface VitaportalModule ()

@end

@implementation VitaportalModule

@synthesize delegate, navBar, hostView, slidingMenu, slidingImageView, backImView, moduleView;
@synthesize rightSlideBarTable, tutorialButton;

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
    
    self.navBar.topItem.title = [self getModuleName];
    UIImage *navBarBackgroundImage = [UIImage imageNamed:@"DesktopNavBarBackground.png"];
    [self.navBar setBackgroundImage:navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    UIImage *slideBackgroundImageBig = [UIImage imageNamed:@"DesktopBackgroundPortrait.png"];
    UIImage *slideBackgroundImage = [[UIImage alloc] initWithCGImage:[slideBackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    slidingMenu.backgroundColor = [UIColor colorWithPatternImage:slideBackgroundImage];
    [slideBackgroundImage release];
    
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarBtn.frame = CGRectMake(0.0, 0.0, 42.0, 32.0);
    [leftBarBtn setImage:[UIImage imageNamed:@"DesktopSlideLeftNavBarButton.png"] forState:UIControlStateNormal];
    [leftBarBtn setImage:[UIImage imageNamed:@"DesktopSlideLeftNavBarButton_press.png"] forState:UIControlStateHighlighted];
    [leftBarBtn addTarget:self action:@selector(pressMainMenuButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navBar.topItem.leftBarButtonItem = leftBarButtonItem;
    [leftBarButtonItem release];
    
    
    float tutorialButtonOriginX = (self.view.bounds.size.width/2.0) + ([self.navBar.topItem.title sizeWithFont:[UIFont boldSystemFontOfSize:18.0]].width/2.0) + 5.0;
    tutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(tutorialButtonOriginX, 6.0, 32.0, 32.0)];
    [tutorialButton setImage:[UIImage imageNamed:@"DesktopNavBar_tutorialBtn_norm.png"] forState:UIControlStateNormal];
    [tutorialButton setImage:[UIImage imageNamed:@"DesktopNavBar_tutorialBtn_press.png"] forState:UIControlStateHighlighted];
    [tutorialButton addTarget:self action:@selector(showTutorial:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:tutorialButton];
    
    NSString *imagePath1 = ([delegate isRetina4] ? @"Vitaportal_tutorial-568@2x" : @"Vitaportal_tutorial@2x");
    tutorialBackgroundImageV = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imagePath1 ofType:@"png"]];
    
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.frame = CGRectMake(0.0, 0.0, 42.0, 32.0);
    [rightBarBtn setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton.png"] forState:UIControlStateNormal];
    [rightBarBtn setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton_press.png"] forState:UIControlStateHighlighted];
    [rightBarBtn addTarget:self action:@selector(showSlidingMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navBar.topItem.rightBarButtonItem = rightBarButtonItem;
    [rightBarButtonItem release];
    
    UIImageView *darkPathImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DesktopVerticalDarkRightPath.png"]];
    float verticalPathHeight = [UIScreen mainScreen].bounds.size.height;
    darkPathImage.frame = CGRectMake(self.view.frame.size.width, 0, darkPathImage.frame.size.width, verticalPathHeight);
    darkPathImage.userInteractionEnabled = NO;
    [slidingImageView addSubview:darkPathImage];
    [darkPathImage release];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height != 568) {
        backImView.image =  [UIImage imageNamed:@"vitaportal_img.png"];
    }else{
        backImView.frame = CGRectMake(0, 0, backImView.frame.size.width, 504);
        backImView.image = [UIImage imageNamed:@"1_03_i5.png"];
    }
    
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
    [self setSlidingMenu:nil];
    [self setSlidingImageView:nil];
    [self setModuleView:nil];
    [self setRightSlideBarTable:nil];
    [self setBackImView:nil];
    
    navBar = nil;
    hostView = nil;
    tutorialBackgroundImageV = nil;
    
    [super viewDidUnload];
}

- (void)dealloc{
    delegate = nil;
    [navBar release];
    [hostView release];
    
    [slidingMenu release];
    [slidingImageView release];
    [moduleView release];
    [rightSlideBarTable release];
    [backImView release];
    [tutorialBackgroundImageV release];
    [tutorialButton release];
    [moduleData release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)getBaseDir{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
};

- (IBAction)hideKeyboard:(id)sender{
    // Save module data when necessary...
    [self saveModuleData];
    
    // ...and hide keyboard
    [sender resignFirstResponder];
}


#pragma mark - Module protoclol implementation

// Initialization of your module. Select NIB-file depending on device (iphone/ipad), set delegate member and perform custom initialization
- (id)initModuleWithDelegate:(id<ServerProtocol>)serverDelegate{
    NSString *nibName;
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        nibName = @"VitaportalModule";
    }else{
        return nil;
    }
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        moduleData = [[NSMutableDictionary alloc] init];
        delegate = serverDelegate;
        if(serverDelegate==nil){
            NSLog(@"WARNING: module \"%@\" initialized without server delegate!", [self getModuleName]);
        }
    }
    return self;
};

// Returns visible module's name
- (NSString *)getModuleName{
    return @"Vitaportal";
};

// Returns module's description
- (NSString *)getModuleDescription{
    return @"The new module description";
};

// Returns current module's message for a user
- (NSString *)getModuleMessage{
    return @"Current module message";
};

// Returns module's version
- (float)getModuleVersion{
    return 1.0;
};

// Returns module's icon image (recommended 50x50 or 100x100 for retina displays)
- (UIImage *)getModuleIcon{
    return [UIImage imageNamed:@"Fake_Moduls_Icons_vita.png"];
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
    }
    
    return res;
};

// Loading module data.
- (void)loadModuleData{
    NSString *listFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"vitaportal.dat"];
    NSDictionary *loadedParams = [NSDictionary dictionaryWithContentsOfFile:listFilePath];
    if(loadedParams){
        if(moduleData) [moduleData release];
        moduleData = [[NSMutableDictionary alloc] initWithDictionary:loadedParams];
    };
    
    if([self isViewLoaded]){
        
    }
};

// Saving module data. It's recommend to save module's data in single file with module name and .dat extension. File should be place in documents folder.
- (void)saveModuleData{    
    if([self isViewLoaded]){
       // [moduleData setObject:myTextField.text forKey:@"string"];
    };
    
    if(moduleData==nil){
        return;
    }
    
    BOOL succ = [moduleData writeToFile:[[self getBaseDir] stringByAppendingPathComponent:@"vitaportal.dat"] atomically:YES];
    if(succ==NO){
        NSLog(@"ExampleModule: error during save data");
    };
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

- (IBAction)showSlidingMenu:(id)sender{
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 2.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    slidingImageView.image = image;
    
    self.view = slidingMenu;
    
    slidingImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slidingImageView setFrame:CGRectMake(-rightSlideBarTable.bounds.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){
        
    }];
};


- (IBAction)hideSlidingMenu:(id)sender{
    CGSize viewSize = self.view.bounds.size;
    NSLog(@"Hide right slide menu: bounds = %.0fx%.0f", viewSize.width, viewSize.height);
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
    return 2;
};

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0;
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
    
    UITextField *cellName = [[UITextField alloc] initWithFrame:CGRectMake(18.0, 2.0, 140.0, 44.0)];
    cellName.textColor = [UIColor lightTextColor];
    cellName.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    cellName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    cellName.userInteractionEnabled = NO;
    
    if([indexPath section]==0){
        switch([indexPath row]){
            case 0:
                cellName.text = NSLocalizedString(@"Logout", @"");
                cell.moduleName.text= @"";
                break;
            case 1:
                cellName.text = NSLocalizedString(@"Favorites", @"");
                cell.moduleName.text= @"";
                break;
            default:
                break;
        }
    }
    [cell addSubview: cellName];
    [cellName release];
    
    return cell;
    
};

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
};

#pragma mark - Module's tutorial supporting

- (IBAction)showTutorial:(id)sender{
    UILabel *myLabel;
    UIView *tutorialView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImageView *tutorialBackground = [[UIImageView alloc] initWithImage:tutorialBackgroundImageV];
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
    NSLog(@"HIDE tutorial...");
};


@end
