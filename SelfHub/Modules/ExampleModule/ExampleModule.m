//
//  ExampleModule.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 24.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExampleModule.h"

@interface ExampleModule ()

@end

@implementation ExampleModule

@synthesize delegate, navBar, hostView, myTextField;

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
    self.navBar.topItem.title = @"Example";
    
    UIImage *navBarBackgroundImage = [UIImage imageNamed:@"DesktopNavBarBackground.png"];
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
    
    // Restoring module data (fill example test fill with loaded data)
    myTextField.text = [moduleData objectForKey:@"string"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    navBar = nil;
    hostView = nil;
    myTextField = nil;
}

- (void)dealloc{
    delegate = nil;
    [navBar release];
    [hostView release];
    [myTextField release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)getBaseDir{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
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
        nibName = @"ExampleModule";
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
    return @"Example";
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
    NSString *listFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"example.dat"];
    NSDictionary *loadedParams = [NSDictionary dictionaryWithContentsOfFile:listFilePath];
    if(loadedParams){
        if(moduleData) [moduleData release];
        moduleData = [[NSMutableDictionary alloc] initWithDictionary:loadedParams];
    };
    
    if([self isViewLoaded]){
        myTextField.text = [moduleData objectForKey:@"string"];
    }
};

// Saving module data. It's recommend to save module's data in single file with module name and .dat extension. File should be place in documents folder.
- (void)saveModuleData{    
    if([self isViewLoaded]){
        [moduleData setObject:myTextField.text forKey:@"string"];
    };
    
    if(moduleData==nil){
        return;
    };
    
    BOOL succ = [moduleData writeToFile:[[self getBaseDir] stringByAppendingPathComponent:@"example.dat"] atomically:YES];
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


@end
