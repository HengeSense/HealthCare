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
@synthesize rightSlideBarTable, navBar, hostView, moduleView, slidingMenu, slidingImageView, moduleData;
@synthesize tutorialButton;



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
    
    if(!modulePagesArray || ![modulePagesArray isKindOfClass:[NSMutableArray class]]){
        [self loadPagesViewControllers];
    };
    [self.hostView addSubview:[[modulePagesArray objectAtIndex:0] view]];
    lastSelectedIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    
    
    
    
    //[self fillAllFieldsLocalized];
    
    self.view = moduleView;
    
    UIImageView *darkPathImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DesktopVerticalDarkRightPath.png"]];
    float verticalPathHeight = [UIScreen mainScreen].bounds.size.height;
    darkPathImage.frame = CGRectMake(self.view.frame.size.width, 0, darkPathImage.frame.size.width, verticalPathHeight);
    darkPathImage.userInteractionEnabled = NO;
    [slidingImageView addSubview:darkPathImage];
    [darkPathImage release];
    
    
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
    
    
    // tutorial elements
    float tutorialButtonOriginX = (self.view.bounds.size.width/2.0) + ([self.navBar.topItem.title sizeWithFont:[UIFont boldSystemFontOfSize:18.0]].width/2.0) + 5.0;
    tutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(tutorialButtonOriginX, 6.0, 32.0, 32.0)];
    [tutorialButton setImage:[UIImage imageNamed:@"DesktopNavBar_tutorialBtn_norm.png"] forState:UIControlStateNormal];
    [tutorialButton setImage:[UIImage imageNamed:@"DesktopNavBar_tutorialBtn_press.png"] forState:UIControlStateHighlighted];
    [tutorialButton addTarget:self action:@selector(showTutorial:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:tutorialButton];
    
    NSString *imagePath1 = ([delegate isRetina4] ? @"profileMain_tutorialBackground-568@2x" : @"profileMain_tutorialBackground@2x");
    tutorialBackgroundImage1 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imagePath1 ofType:@"png"]];
}

- (void)loadPagesViewControllers{
    if(modulePagesArray!=nil && [modulePagesArray isKindOfClass:[NSMutableArray class]]) return;
    
    modulePagesArray = [[NSMutableArray alloc] init];
    MainInformationPacient *viewController1 = [[MainInformationPacient alloc] initWithNibName:@"MainInformationPacient" bundle:nil];
    MainInformationUnits *viewController2 = [[MainInformationUnits alloc] initWithNibName:@"MainInformationUnits" bundle:nil];
    viewController1.delegate = self;
    viewController2.delegate = self;
    [modulePagesArray addObject:viewController1];
    [modulePagesArray addObject:viewController2];
    [viewController1 release];
    [viewController2 release];
};

- (void)dealloc
{
    delegate = nil;
    [modulePagesArray release];
    
    [rightSlideBarTable release];
    [navBar release];
    [hostView release];
    [slidingMenu release];
    [slidingImageView release];
    if(moduleData) [moduleData release];
    
    if(lastSelectedIndexPath) [lastSelectedIndexPath release];
    
    if(tutorialButton) [tutorialButton release];
    if(tutorialBackgroundImage1) [tutorialBackgroundImage1 release];
    
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    if(moduleData==nil){
        [self loadModuleData];
    };
    
    //NSLog(@"Adding pacient page to main view");
    UIView *currentView = [[modulePagesArray objectAtIndex:[lastSelectedIndexPath row]] view];
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
    /*
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
     */
    
    return nil;
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
    [(MainInformationPacient *)[modulePagesArray objectAtIndex:0] changeScrollFrameBeforeKeyboardDisappear];
    
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 2.0);
    [self.moduleView.layer renderInContext:UIGraphicsGetCurrentContext()];
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

#pragma mark - Module's tutorial supporting

- (IBAction)showTutorial:(id)sender{
    UIView *tutorialView = [[UIView alloc] initWithFrame:self.view.bounds];
    UILabel *myLabel;
    
    if([lastSelectedIndexPath row]==0){
        UIImageView *tutorialBackground = [[UIImageView alloc] initWithImage:tutorialBackgroundImage1];
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
        
        myLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 94.0, 130.0, 20.0)];
        myLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        myLabel.backgroundColor = [UIColor clearColor];
        myLabel.textColor = [UIColor whiteColor];
        myLabel.textAlignment = NSTextAlignmentRight;
        myLabel.text = NSLocalizedString(@"Module's pages", @"");
        float modulesPagesTitleWidth = [myLabel.text sizeWithFont:myLabel.font].width;
        [tutorialView addSubview:myLabel];
        [myLabel release];
        
        myLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0 - (70.0-modulesPagesTitleWidth)-15.0, 114.0, 300.0, 20.0)];
        myLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        myLabel.backgroundColor = [UIColor clearColor];
        myLabel.textColor = [UIColor whiteColor];
        myLabel.textAlignment = NSTextAlignmentLeft;
        myLabel.numberOfLines = 1;
        myLabel.text = NSLocalizedString(@"Units selection", @"");
        [tutorialView addSubview:myLabel];
        [myLabel release];
        
        myLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 220.0, 200.0, 20.0)];
        myLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        myLabel.backgroundColor = [UIColor clearColor];
        myLabel.textColor = [UIColor whiteColor];
        myLabel.textAlignment = NSTextAlignmentLeft;
        myLabel.text = NSLocalizedString(@"Fill this fields", @"");
        [tutorialView addSubview:myLabel];
        [myLabel release];
        
        myLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 240.0, 200.0, 40.0)];
        myLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        myLabel.backgroundColor = [UIColor clearColor];
        myLabel.textColor = [UIColor whiteColor];
        myLabel.textAlignment = NSTextAlignmentLeft;
        myLabel.numberOfLines = 2;
        myLabel.text = NSLocalizedString(@"They will be used in related modules", @"");
        [tutorialView addSubview:myLabel];
        [myLabel release];
        
        [delegate showTutorial:tutorialView];
    };
    
    [tutorialView release];
};

#pragma mark - Working with units view's fields

- (NSString *)getCurWeightStrForWeightInKg:(float)kgWeight withUnit:(BOOL)isUnit{
    if(isUnit==YES){
        return [NSString stringWithFormat:@"%.1f %@", kgWeight*[self getWeightFactor], [self getWeightUnit]];
    }else{
        return [NSString stringWithFormat:@"%.1f", kgWeight*[self getWeightFactor]];
    }
};

- (NSString *)getWeightUnit{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *weightUnit = [moduleData objectForKey:@"weightUnit"];
    if(weightUnit==nil) weightUnit = [NSNumber numberWithInt:0];
    return [unitsPage getWeightUnitStr:[weightUnit intValue]];
};

- (float)getMinWeightKg{
    return floor(MIN_WEIGHT_KG * [self getWeightFactor]) / [self getWeightFactor];
};

- (float)getMaxWeightKg{
    return floor(MAX_WEIGHT_KG * [self getWeightFactor]) / [self getWeightFactor];
};

- (float)getWeightFactor{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *weightUnit = [moduleData objectForKey:@"weightUnit"];
    if(weightUnit==nil) weightUnit = [NSNumber numberWithInt:0];
    return [unitsPage getWeightUnitKoef:[weightUnit intValue]];
};

- (float)getWeightPickerStep{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *weightUnit = [moduleData objectForKey:@"weightUnit"];
    if(weightUnit==nil) weightUnit = [NSNumber numberWithInt:0];
    return [unitsPage getWeightUnitPickerStep:[weightUnit intValue]];
};



// ---------------


- (float)roundFloat:(float)num forStep:(float)step{
    float a = floor(num/step);
    float b = num - a * step;
    if(b >= (step/2)) a++;
    
    return a*step;
};

- (NSString *)getCurHeightStrForHeightInCm:(float)cmHeight withUnit:(BOOL)isUnit{
    NSNumber *sizeUnit = [moduleData objectForKey:@"sizeUnit"];
    if(sizeUnit==nil) sizeUnit = [NSNumber numberWithInt:0];
    
    if([sizeUnit intValue]==1){ // foots & inch
        float inputFtVal = cmHeight * [self getSizeFactor];
        float ftVal = floorf(inputFtVal);
        float duimVal = (inputFtVal - ftVal) / (1.0/12.0);
        duimVal = [self roundFloat:duimVal forStep:1.0];
        if(fabs(duimVal-12.0)<0.001){
            ftVal += 1.0;
            duimVal = 0.0;
        }
        
        if(isUnit==YES){
            return [NSString stringWithFormat:NSLocalizedString(@"%.0f ft %.0f''", @""), ftVal, duimVal];
        }else{
            return [NSString stringWithFormat:@"%.2f", inputFtVal];
        };
        
    };
    
    if(isUnit==YES){
        return [NSString stringWithFormat:@"%.0f %@", cmHeight*[self getSizeFactor], [self getSizeUnit]];
    }else{
        return [NSString stringWithFormat:@"%.0f", cmHeight*[self getSizeFactor]];
    }
};

- (NSString *)getSizeUnit{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *sizeUnit = [moduleData objectForKey:@"sizeUnit"];
    if(sizeUnit==nil) sizeUnit = [NSNumber numberWithInt:0];
    return [unitsPage getSizeUnitStr:[sizeUnit intValue]];
};

- (float)getMinHeightCm{
    return MIN_HEIGHT_CM;
};

- (float)getMaxHeightCm{
    return MAX_HEIGHT_CM;
};


- (float)getSizeFactor{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *sizeUnit = [moduleData objectForKey:@"sizeUnit"];
    if(sizeUnit==nil) sizeUnit = [NSNumber numberWithInt:0];
    return [unitsPage getSizeUnitKoef:[sizeUnit intValue]];
};

- (float)getSizePickerStep{
    MainInformationUnits *unitsPage = [modulePagesArray objectAtIndex:1];
    NSNumber *sizeUnit = [moduleData objectForKey:@"sizeUnit"];
    if(sizeUnit==nil) sizeUnit = [NSNumber numberWithInt:0];
    return [unitsPage getSizeUnitPickerStep:[sizeUnit intValue]];
};

- (void)recalcAllFieldsToCurrentlySelectedUnits{
    
};

#pragma mark - TableView delegate (supporting right table-based navigation)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
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
    
    headerLabel.text = NSLocalizedString(@"Pages", @"");
    
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
                cell.moduleName.text = NSLocalizedString(@"Main", @"");
                break;
            case 1:
                cell.moduleName.text = NSLocalizedString(@"Units", @"");
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
    return 45.0;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0){
        [[[modulePagesArray objectAtIndex:[lastSelectedIndexPath row]] view] removeFromSuperview];
        [[[modulePagesArray objectAtIndex:[indexPath row]] view] setFrame:self.hostView.bounds];
        [self.hostView addSubview:[[modulePagesArray objectAtIndex:[indexPath row]] view]];
        
        if(lastSelectedIndexPath) [lastSelectedIndexPath release];
        lastSelectedIndexPath = [indexPath retain];
        [tableView selectRowAtIndexPath:lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        if([indexPath row]==0){
            [tutorialButton setHidden:NO];
        }else{
            [tutorialButton setHidden:YES];
        };

        [self hideSlidingMenu:nil];
    };
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
    
    if([moduleData objectForKey:@"name"]==nil || [moduleData objectForKey:@"surname"]==nil) return NSLocalizedString(@"Specify the name", @"");
    if([moduleData objectForKey:@"birthday"]==nil) return NSLocalizedString(@"Specify your birthday", @"");
    if([moduleData objectForKey:@"length"]==nil) return NSLocalizedString(@"Specify the height!", @"");
    if([moduleData objectForKey:@"weight"]==nil) return NSLocalizedString(@"Specify the weight", @"");
    
    return NSLocalizedString(@"All fields are filled!", @"");
};

- (float)getModuleVersion{
    return 1.1f;
};

- (UIImage *)getModuleIcon{
    return [UIImage imageNamed:@"profileModule_icon.png"];
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
    int tmp;
    //NSLog(@"%@", [[NSLocale currentLocale] objectForKey:NSLocaleMeasurementSystem]);
    if(loadedParams){
        if(moduleData) [moduleData release];
        moduleData = [[NSMutableDictionary alloc] initWithDictionary:loadedParams];
        if([moduleData objectForKey:@"weightUnit"]==nil){
            if([[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue]==YES){
                tmp = 0;
            }else{
                tmp = 1;
            };
            [moduleData setObject:[NSNumber numberWithInt:tmp] forKey:@"weightUnit"];
        };
        if([moduleData objectForKey:@"sizeUnit"]==nil){
            if([[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue]==YES){
                tmp = 0;
            }else{
                tmp = 1;
            };
            [moduleData setObject:[NSNumber numberWithInt:tmp] forKey:@"sizeUnit"];
        };
    }else{
        if([[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue]==YES){
            tmp = 0;
        }else{
            tmp = 1;
        };
        moduleData = [[NSMutableDictionary alloc] init];
        [moduleData setObject:[NSNumber numberWithInt:tmp] forKey:@"weightUnit"];
        [moduleData setObject:[NSNumber numberWithInt:tmp] forKey:@"sizeUnit"];
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
    [(MainInformationPacient *)[modulePagesArray objectAtIndex:0] changeScrollFrameBeforeKeyboardDisappear];
    
    [delegate showSlideMenu];
};


@end
