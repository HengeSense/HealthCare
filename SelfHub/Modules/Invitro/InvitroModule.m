//
//  ExampleModule.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 24.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InvitroModule.h"

@interface InvitroModule ()

@end

@implementation InvitroModule

@synthesize delegate, navBar, hostView, slidingImageView, slidingMenu, moduleView,rightSlideBarTable, backImView;


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
        backImView.image =  [UIImage imageNamed:@"Invitro_iphone_tests_draft.png"];
    }else{
        backImView.frame = CGRectMake(0, 0, backImView.frame.size.width, 524);
        backImView.image = [UIImage imageNamed:@"Fake_Moduls_Icons_invitro_i5.png"];
    }
    
    self.view = moduleView;
    lastSelectedIndexPath = [[NSIndexPath indexPathForRow:1 inSection:1] retain];
    
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    navBar = nil;
    hostView = nil;
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
    if(lastSelectedIndexPath) [lastSelectedIndexPath release];
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
        nibName = @"InvitroModule";
    }else{
        return nil;
    };
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        moduleData = [[NSMutableDictionary alloc] init];
        delegate = serverDelegate;
        if(serverDelegate==nil){
            NSLog(@"WARNING: module \"%@\" initialized without server delegate!", [self getModuleName]);
        };
    }
    return self;
};

// Returns visible module's name
- (NSString *)getModuleName{
    return @"Invitro";
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
    return [UIImage imageNamed:@"Fake_Moduls_Icons_invitro.png"];
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
    NSString *listFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"invitro.dat"];
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
        //[moduleData setObject:myTextField.text forKey:@"string"];
    };
    
    if(moduleData==nil){
        return;
    };
    
    BOOL succ = [moduleData writeToFile:[[self getBaseDir] stringByAppendingPathComponent:@"invitro.dat"] atomically:YES];
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
    [rightSlideBarTable selectRowAtIndexPath:lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
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
    return 3;
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (section==0 || section==1)? 2:3;
};

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (section==1 || section==2)? 20.0 : 0.0;
};

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
    CGRect headerRect = CGRectMake(0.0, 0.0, tableView.bounds.size.width, 20.0);
    
    UIView *headerView = [[[UIView alloc] initWithFrame:headerRect] autorelease];
   if(section==1 || section==2){  
       UIImageView *headerBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DesktopCellHeaderBackground.png"]];
       headerBackgroundImage.alpha = 0.3;
       [headerView addSubview:headerBackgroundImage];
       [headerBackgroundImage release];
       
       UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, 2.0, 140.0, 16.0)];
       headerLabel.textColor = [UIColor lightTextColor];
       headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
       headerLabel.backgroundColor = [UIColor clearColor];
       
       headerLabel.text = (section==1)? NSLocalizedString(@"AnalysesAndPrices",@"") : NSLocalizedString(@"AddressesAndServices", @"");
       
       [headerView addSubview:headerLabel];
       [headerLabel release];
    }
    
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
    
    UITextField *cellName = [[UITextField alloc] initWithFrame:CGRectMake(18.0, 2.0, 140.0, 44.0)];
    cellName.textColor = [UIColor lightTextColor];
    cellName.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    cellName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    cellName.userInteractionEnabled = NO;
    
    if([indexPath section]==0){
        switch([indexPath row]){
            case 0:
                cellName.text = NSLocalizedString(@"News", @"");
                cell.moduleName.text= @"";
                break;
            case 1:
                cellName.text =  NSLocalizedString(@"GetResult", @"");
                cell.moduleName.text= @"";
                break;
            default:
                break;
        };
    }else if([indexPath section]==1){
        switch([indexPath row]){
            case 0:
                cellName.text = NSLocalizedString(@"ByCategory",@"");
                cell.moduleName.text= @"";
                break;
            case 1:
                cellName.text = NSLocalizedString(@"ByAlphabet",@"") ;
                cell.moduleName.text= @"";
                break;
            default:
                break;
        };
    }else{
        switch([indexPath row]){
            case 0:
                cellName.text = NSLocalizedString(@"Nearest",@"");
                cell.moduleName.text= @"";
                break;
            case 1:
                cellName.text = NSLocalizedString(@"ByMetro",@"");
                cell.moduleName.text= @"";
                break;
            case 2:
                cellName.text = NSLocalizedString(@"Map", @"");
                cell.moduleName.text= @"";
                break;
            default:
                break;
        };
    };
    [cell addSubview: cellName];
    [cellName release];
    
    return cell;
    
};

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(lastSelectedIndexPath) [lastSelectedIndexPath release];
    lastSelectedIndexPath = [indexPath retain];
    [tableView selectRowAtIndexPath:lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    [self hideSlidingMenu:nil];
    
};

@end
