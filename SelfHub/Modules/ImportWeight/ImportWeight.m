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

@synthesize delegate, navBar, hostView;

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
    
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarBtn.frame = CGRectMake(0.0, 0.0, 42.0, 32.0);
    [leftBarBtn setImage:[UIImage imageNamed:@"DesktopSlideLeftNavBarButton.png"] forState:UIControlStateNormal];
    [leftBarBtn setImage:[UIImage imageNamed:@"DesktopSlideLeftNavBarButton_press.png"] forState:UIControlStateHighlighted];
    [leftBarBtn addTarget:self action:@selector(pressMainMenuButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navBar.topItem.leftBarButtonItem = leftBarButtonItem;
    [leftBarButtonItem release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    delegate = nil;
    [navBar release];
    [hostView release];
    
    [super dealloc];
};

- (IBAction)loadDataFromCVS:(id)sender{
    NSString *str = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Libra" ofType:@"csv"] encoding:NSNonLossyASCIIStringEncoding error:nil];
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    NSArray *dividedRec;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    NSDate *curDate;
    float curWeight;
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *oneResultDict;
    for(NSString *oneRec in arr){
        dividedRec = [oneRec componentsSeparatedByString:@";"];
        if([dividedRec count]<3) continue;
        curDate = [[dateFormatter dateFromString:[dividedRec objectAtIndex:0]] retain];
        curWeight = [[dividedRec objectAtIndex:1] floatValue];
        
        oneResultDict = [[NSMutableDictionary alloc] init];
        [oneResultDict setObject:curDate forKey:@"date"];
        [oneResultDict setObject:[NSNumber numberWithFloat:curWeight] forKey:@"weight"];
        [resultArray addObject:oneResultDict];
        
        //NSLog(@"%@ -> %.1f", [[oneResultDict objectForKey:@"date"] description], [[oneResultDict objectForKey:@"weight"] floatValue]);
        [curDate release];
        [oneResultDict release];
    };
    [dateFormatter release];
    
    [delegate setValue:resultArray forName:@"database" forModuleWithID:@"selfhub.weight"];
    
    //NSMutableArray *weightModuleData = (NSMutableArray*)[delegate getValueForName:@"database" fromModuleWithID:@"selfhub.weight"];
    //for(NSMutableDictionary *oneDict in resultArray){
    //    [weightModuleData addObject:oneDict];
    //};
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
