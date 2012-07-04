  //
//  ViewController.m
//  HealthCare
//
//  Created by Eugine Korobovsky on 16.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DesktopViewController.h"
#import "ModuleTableCell.h"

#define DEFAULT_MODULE_ID @"selfhub.weight"

@implementation DesktopViewController

@synthesize slidingImageView, applicationDelegate, modulesTable;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
};

- (void)initialize{
    self.title = NSLocalizedString(@"Menu", @"");
    
    NSArray *listFromPList = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:@"AllModules" ofType:@"plist"]]){
        listFromPList = [[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AllModules" ofType:@"plist"]] objectForKey:@"modules"];
    };
    if(listFromPList==nil){
        NSLog(@"Error: cannot read data from AllModules.plist");
    };
    
    NSMutableArray *totalArrayTmp = [[NSMutableArray alloc] init];
    NSMutableDictionary *tmpModuleInfo;
    
    Class curModuleClass;
    id module;
    for(NSDictionary *oneModuleInfo in listFromPList){
        tmpModuleInfo = [[NSMutableDictionary alloc] initWithDictionary:oneModuleInfo];
        
        curModuleClass = NSClassFromString([oneModuleInfo objectForKey:@"Interface"]);
        module = [[curModuleClass alloc] initModuleWithDelegate:self];
        [module loadModuleData];
        [tmpModuleInfo setValue:module forKey:@"viewController"];
        [module release];
        
        [totalArrayTmp addObject:tmpModuleInfo];
        [tmpModuleInfo release];
    };
    
    
    
    modulesArray = [[NSArray alloc] initWithArray:totalArrayTmp];
    [totalArrayTmp release];
    
    largeIcons = NO;
    
    
    
    //Adding support for sliding-out navigation
    slidingImageView = [[UIImageView alloc] init];
    slidingImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreenshot:)];
    [slidingImageView addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveScreenshot:)];
    [panGesture setMaximumNumberOfTouches:2];
    [slidingImageView addGestureRecognizer:panGesture];
    
    [self.view addSubview:slidingImageView];
};

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    applicationDelegate = nil;
    modulesTable = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [modulesTable reloadData];
    
    [slidingImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slidingImageView setFrame:CGRectMake(240, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){  }];
};

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
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
        [self hideSlideMenu];
}

- (void)tapScreenshot:(UITapGestureRecognizer *)gesture{
    [self hideSlideMenu];
};

- (UIViewController *)getMainModuleViewController{
    return [self getViewControllerForModuleWithID:DEFAULT_MODULE_ID];
};

#pragma mark - TableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
};
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Modules";
            break;
        case 1:
            return @"Service";
            break;
            
        default:
            return @"";
            break;
    };
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0) return [modulesArray count];
    if(section==1) return 1;
    
    return 0;
};

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==1){
        static NSString *serviceCellID = @"ServiceCellID";
        UITableViewCell *serviceCell = [tableView dequeueReusableCellWithIdentifier:serviceCellID];
        if(serviceCell==nil){
            serviceCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:serviceCellID] autorelease];
        };
        switch ([indexPath row]) {
            case 0:
                serviceCell.textLabel.text = @"Logout";
                break;
                
            default:
                break;
        };
        
        return serviceCell;
    };
    
    static NSString *cellID;
    if(largeIcons){
        cellID = @"ModuleTableCellID";
    }else{
        cellID = @"ModuleTableCellMiniID";
    }
    
    ModuleTableCell *cell = (ModuleTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil){
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ModuleTableCell" owner:self options:nil];
        for(id oneObject in nibs){
            if([oneObject isKindOfClass:[ModuleTableCell class]]){
                cell = (ModuleTableCell *)oneObject;
            };
        };
    };
    
    
    UIViewController<ModuleProtocol> *curModuleController;
    curModuleController = [[modulesArray objectAtIndex:[indexPath row]] objectForKey:@"viewController"];
    cell.moduleName.text = [curModuleController getModuleName];
    cell.moduleDescription.text = [curModuleController getModuleDescription];
    cell.moduleMessage.text = [curModuleController getModuleMessage];
    cell.moduleIcon.image = [curModuleController getModuleIcon];
        
    return cell;

};

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==1) return 44;
    
    switch (largeIcons) {
        case YES:
            return 160.0f;
            break;
            
        case NO:
            return 64.0f;
            break;
            
        default:
            return 44.0f;
            break;
    };
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"%@", [[modulesArray objectAtIndex:0] valueForKeyPath:@"moduleData.name"]);
    if([indexPath section]==1){
        if([indexPath row]==0){
            [applicationDelegate performLogout];
            [self hideSlideMenu];
            return;
        };
    };
    
    UIViewController<ModuleProtocol> *curModuleController;
    curModuleController = [[modulesArray objectAtIndex:[indexPath row]] objectForKey:@"viewController"];
    
    //[self.navigationController pushViewController:curModuleController animated:YES];
    applicationDelegate.activeModuleViewController = curModuleController;
    [self hideSlideMenu];
};

#pragma mark - ServerProtocol functions

- (BOOL)isModuleAvailableWithID:(NSString *)moduleID{
    for(NSDictionary *oneModuleInfo in modulesArray){
        if([[oneModuleInfo objectForKey:@"ID"] isEqualToString:moduleID]){
            return YES;
        }
    };
    return NO;
};

- (id)getValueForName:(NSString *)name fromModuleWithID:(NSString *)moduleID{
    BOOL isModuleExist = NO;
    NSMutableDictionary *oneModuleInfo;
    for(oneModuleInfo in modulesArray){
        if([[oneModuleInfo objectForKey:@"ID"] isEqualToString:moduleID]){
            isModuleExist = YES;
            break;
        };
    };
    if(isModuleExist==NO){
        NSLog(@"WARNING: getValueForName:fromModuleWithID: cannot find module with ID \"%@\"", moduleID);
        return nil;
    };
    
    NSArray *moduleExchangeList = [oneModuleInfo objectForKey:@"ExchangeList"];
    if(moduleExchangeList==nil){
        NSString *moduleExchangeFileName = [oneModuleInfo objectForKey:@"ExchangeFile"];
        if(moduleExchangeFileName==nil || 
           [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:[moduleExchangeFileName stringByDeletingPathExtension] ofType:nil]] ){
            NSLog(@"WARNING: getValueForName:fromModuleWithID: cannot find module exchange file for module with ID \"%@\"", moduleID);
            return nil;
        };
        
        moduleExchangeList = [[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:moduleExchangeFileName ofType:nil]] objectForKey:@"items"];
        if(moduleExchangeList == nil){
            NSLog(@"WARNING: getValueForName:fromModuleWithID: exchange list is empty in module with ID \"%@\". Check format of exchange file (plist, one item with name \"items\".", moduleID);
            return nil;
        };
        [oneModuleInfo setObject:moduleExchangeList forKey:@"ExchangeList"];
    };
    
    BOOL isObjectExist = NO;
    NSDictionary *oneExchangeEntry;
    for(oneExchangeEntry in moduleExchangeList){
        if([[oneExchangeEntry objectForKey:@"name"] isEqualToString:name]){
            isObjectExist = YES;
            break;
        };
    };
    if(isObjectExist==NO){
        NSLog(@"WARNING: getValueForName:fromModuleWithID: cannot find exchange object \"%@\" in module with ID \"%@\"", name, moduleID);
        return nil;
    };
    
    UIViewController *curModule = [oneModuleInfo objectForKey:@"viewController"];
    if(curModule == nil){
        NSLog(@"WARNING: getValueForName:fromModuleWithID: cannot find view controler for module with ID \"%@\"", moduleID);
        return nil;
    };
    
    NSString *keyPath = [oneExchangeEntry objectForKey:@"keypath"];
    if(keyPath==nil){
        NSLog(@"WARNING: getValueForName:fromModuleWithID: cannot retrieve keypath for exchange object \"%@\" in module with ID \"%@\"", name, moduleID);
        return nil;
    };
    
    id resultValue = [curModule valueForKeyPath:keyPath];
    if(resultValue==nil){
        NSLog(@"WARNING: getValueForName:fromModuleWithID: retrieved empty exchange object \"%@\" in module with ID \"%@\"", name, moduleID);
        return nil;
    }
    
    return resultValue;
};

- (BOOL)setValue:(id)value forName:(NSString *)name forModuleWithID:(NSString *)moduleID{
    BOOL isModuleExist = NO;
    NSMutableDictionary *oneModuleInfo;
    for(oneModuleInfo in modulesArray){
        if([[oneModuleInfo objectForKey:@"ID"] isEqualToString:moduleID]){
            isModuleExist = YES;
            break;
        };
    };
    if(isModuleExist==NO){
        NSLog(@"WARNING: setValue:forName:fromModuleWithID: cannot find module with ID \"%@\"", moduleID);
        return NO;
    };
    
    NSArray *moduleExchangeList = [oneModuleInfo objectForKey:@"ExchangeList"];
    if(moduleExchangeList==nil){
        NSString *moduleExchangeFileName = [oneModuleInfo objectForKey:@"ExchangeFile"];
        if(moduleExchangeFileName==nil || 
           [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:[moduleExchangeFileName stringByDeletingPathExtension] ofType:nil]] ){
            NSLog(@"WARNING: setValue:forName:fromModuleWithID: cannot find module exchange file for module with ID \"%@\"", moduleID);
            return NO;
        };
        
        moduleExchangeList = [[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:moduleExchangeFileName ofType:nil]] objectForKey:@"items"];
        if(moduleExchangeList == nil){
            NSLog(@"WARNING: setValue:forName:fromModuleWithID: exchange list is empty in module with ID \"%@\". Check format of exchange file (plist, one item with name \"items\".", moduleID);
            return NO;
        };
        [oneModuleInfo setObject:moduleExchangeList forKey:@"ExchangeList"];
    };
    
    BOOL isObjectExist = NO;
    NSDictionary *oneExchangeEntry;
    for(oneExchangeEntry in moduleExchangeList){
        if([[oneExchangeEntry objectForKey:@"name"] isEqualToString:name]){
            isObjectExist = YES;
            break;
        };
    };
    if(isObjectExist==NO){
        NSLog(@"WARNING: setValue:forName:fromModuleWithID: cannot find exchange object \"%@\" in module with ID \"%@\"", name, moduleID);
        return NO;
    };
    
    UIViewController *curModule = [oneModuleInfo objectForKey:@"viewController"];
    if(curModule == nil){
        NSLog(@"WARNING: setValue:forName:fromModuleWithID: cannot find view controler for module with ID \"%@\"", moduleID);
        return NO;
    };
    
    NSString *keyPath = [oneExchangeEntry objectForKey:@"keypath"];
    if(keyPath==nil){
        NSLog(@"WARNING: setValue:forName:fromModuleWithID: cannot retrieve keypath for exchange object \"%@\" in module with ID \"%@\"", name, moduleID);
        return NO;
    };
    
    NSNumber *isValueReadonly = [oneExchangeEntry objectForKey:@"readonly"];
    if(isValueReadonly!=nil && [isValueReadonly boolValue]==YES){
        NSLog(@"WARNING: setValue:forName:fromModuleWithID: cannot set READ-ONLY exchange object \"%@\" in module with ID \"%@\"", name, moduleID);
        return NO;
    }
    
    [curModule setValue:value forKeyPath:keyPath];    
    
    return YES;
};

- (UIViewController *)getViewControllerForModuleWithID:(NSString *)moduleID{
    NSMutableDictionary *oneModuleInfo;
    for(oneModuleInfo in modulesArray){
        if([[oneModuleInfo objectForKey:@"ID"] isEqualToString:moduleID]){
            return [oneModuleInfo objectForKey:@"viewController"];
        };
    };
    
    return nil;
};

- (void)showSlideMenu{
    [applicationDelegate showSlideMenu];
};

- (void)hideSlideMenu{
    [applicationDelegate updateMenuSliderImage];
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slidingImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){
        [applicationDelegate hideSlideMenu];
    }];
};

@end
