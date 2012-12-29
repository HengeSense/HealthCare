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
#define SHOW_HIDE_MENU_DURATION 0.4f
#define SHOW_HIDE_TUTORIAL_DURATION 0.4f

@implementation DesktopViewController

@synthesize lastSelectedIndexPath, slidingImageView, screenshotImage, applicationDelegate, modulesTable, modulesTableSearchBar;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
};

- (void)initialize{
    self.title = @""; //NSLocalizedString(@"Menu", @"");
    
    retina4flag = ([UIScreen mainScreen].bounds.size.height>480 ? YES : NO);
    
    NSArray *listFromPList = nil;
    //NSDictionary *allModulesPlistDict;
    if([[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:@"AllModules" ofType:@"plist"]]){
        NSDictionary *allModulesPlistDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AllModules" ofType:@"plist"]];
        listFromPList = [[allModulesPlistDict objectForKey:@"modules"] retain];
        [allModulesPlistDict release];
    };
    if(listFromPList==nil){
        NSLog(@"Error: cannot read data from AllModules.plist");
        return;
    };
    
    NSMutableArray *totalArrayTmp = [[NSMutableArray alloc] init];
    NSMutableDictionary *tmpModuleInfo;
    
    Class curModuleClass;
    id module;
    for(NSDictionary *oneModuleInfo in listFromPList){
        if([[oneModuleInfo objectForKey:@"Show"] boolValue]==NO){
            continue;
        };
        
        tmpModuleInfo = [[NSMutableDictionary alloc] initWithDictionary:oneModuleInfo];
        
        curModuleClass = NSClassFromString([oneModuleInfo objectForKey:@"Interface"]);
        module = [[curModuleClass alloc] initModuleWithDelegate:self];
        [module loadModuleData];
        //[module loadView];
        [tmpModuleInfo setValue:module forKey:@"viewController"];
        [module release];
        
        [totalArrayTmp addObject:tmpModuleInfo];
        [tmpModuleInfo release];
    };
    
    
    
    modulesArray = [[NSArray alloc] initWithArray:totalArrayTmp];
    [totalArrayTmp release];
    [listFromPList release];
    
    filteredModulesArray = [[NSMutableArray alloc] init];
    
    largeIcons = NO;
    
    //Calc row number for default module
    NSMutableDictionary *oneModuleInfo;
    int i = 0;
    for(oneModuleInfo in modulesArray){
        if([[oneModuleInfo objectForKey:@"ID"] isEqualToString:DEFAULT_MODULE_ID]){
            if(lastSelectedIndexPath) [lastSelectedIndexPath release];
            lastSelectedIndexPath = [[NSIndexPath indexPathForRow:i inSection:0] retain];
            break;
        };
        i++;
    };
    /*if(lastSelectedIndexPath){
        [self changeSelectionToIndexPath:lastSelectedIndexPath];
    }*/
    
    //Adding support for sliding-out navigation
    slidingImageView = [[UIView alloc] initWithFrame:self.view.frame];
    //NSLog(@"slidingImageView: %.0f, %.0f, %.0f, %.0f", slidingImageView.bounds.origin.x, slidingImageView.bounds.origin.y, slidingImageView.bounds.size.width, slidingImageView.bounds.size.height);
    slidingImageView.clipsToBounds = NO;
    slidingImageView.autoresizesSubviews = YES;
    
    
    UIImageView *darkPathImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DesktopVerticalDarkPath.png"]];
    float verticalPathHeight = [UIScreen mainScreen].bounds.size.height;
    darkPathImage.frame = CGRectMake(-darkPathImage.frame.size.width, 0, darkPathImage.frame.size.width, verticalPathHeight /*darkPathImage.frame.size.height*/);
    darkPathImage.userInteractionEnabled = NO;
    [slidingImageView addSubview:darkPathImage];
    [darkPathImage release];
    
    screenshotImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    //CGRect myFrame = self.view.frame;
    screenshotImage.backgroundColor = [UIColor blackColor];
    //slidingImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    screenshotImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreenshot:)];
    [screenshotImage addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveScreenshot:)];
    [panGesture setMaximumNumberOfTouches:2];
    [screenshotImage addGestureRecognizer:panGesture];
    [tapGesture release];
    [panGesture release];
    [slidingImageView addSubview:screenshotImage];
    //screenshotImage.backgroundColor = [UIColor greenColor];
    
    UITableView *searchResultController = self.searchDisplayController.searchResultsTableView;
    searchResultController.backgroundColor = [UIColor darkGrayColor];
    searchResultController.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchResultController = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    modulesTableSearchBar.placeholder = NSLocalizedString(@"Search modules", @"");
    
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
    
    if(lastSelectedIndexPath){
        [modulesTable selectRowAtIndexPath:lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    };
    
    [slidingImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView animateWithDuration:SHOW_HIDE_MENU_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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

- (void)handleMemoryWarningNotification
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
    UIViewController<ModuleProtocol>* oneModuleViewController;
    
    NSLog(@"Memory warning was received by DESKTOP! Trying to call modules routines (didReceivedMemoryWarning)...");
    for(id oneModule in modulesArray){
        oneModuleViewController = [oneModule objectForKey:@"viewController"];
        if([oneModuleViewController canPerformAction:@selector(didReceivedMemoryWarning) withSender:nil]){
            NSLog(@"Module: %@ - didReceivedMemoryWarning runs right now!", [oneModuleViewController getModuleName]);
            [oneModuleViewController didReceiveMemoryWarning];
        }else{
            NSLog(@"Module: %@ - didReceivedMemoryWarning is not implemented.", [oneModuleViewController getModuleName]);
        }
    };
};

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
};

-(void)moveScreenshot:(UIPanGestureRecognizer *)gesture{
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:[slidingImageView superview]];
        
        // I edited this line so that the image view cannont move vertically
        [slidingImageView setCenter:CGPointMake([slidingImageView center].x + translation.x, [slidingImageView center].y)];
        [gesture setTranslation:CGPointZero inView:[slidingImageView superview]];
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

- (BOOL)isSearchModeForTable:(UITableView *)tableView{
    return tableView==self.searchDisplayController.searchResultsTableView ? YES : NO;
};

- (IBAction)closeTutorial:(id)sender{
    UIButton *closeButton = (UIButton *)sender;
    UIView *tutorialView = [closeButton superview];
    
    [UIView animateWithDuration:SHOW_HIDE_TUTORIAL_DURATION animations:^(void){
        tutorialView.alpha = 0.0;
    }completion:^(BOOL finished){
        [tutorialView removeFromSuperview];
    }];
};

#pragma mark - TableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([self isSearchModeForTable:tableView]){
        return 1;
    }else{
        return 2;
    };
};
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if([self isSearchModeForTable:tableView]){
        return @"Search results";
    };
    
    switch (section) {
        case 0:
            return NSLocalizedString(@"Modules", @"");
            break;
        case 1:
            return NSLocalizedString(@"Service", @"");
            break;
            
        default:
            return @"";
            break;
    };
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([self isSearchModeForTable:tableView]){
        return [filteredModulesArray count];
    };
    
    if(section==0) return [modulesArray count];
    if(section==1) return 1;
    
    return 0;
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
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 2.0, 200.0, 16.0)];
    headerLabel.textColor = [UIColor lightTextColor];
    headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    headerLabel.backgroundColor = [UIColor clearColor];
    if([self isSearchModeForTable:tableView]){
        headerLabel.text = NSLocalizedString(@"Search result", @"");
    }else{
        switch (section) {
            case 0:
                headerLabel.text = NSLocalizedString(@"Modules", @"");
                break;
            case 1:
                headerLabel.text = NSLocalizedString(@"Service", @"");
                break;
                
                
            default:
                headerLabel.text = @"";
                break;
        };
    };
    [headerView addSubview:headerLabel];
    [headerLabel release];
    
    return headerView;
};


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
            if([oneObject isKindOfClass:[ModuleTableCell class]] && [[oneObject reuseIdentifier] isEqualToString:cellID]){
                cell = (ModuleTableCell *)oneObject;
            };
        };
        if(cell==nil){
            NSLog(@"DesktopViewController error: Cannot find table cell with reuse identifier %@", cellID);
            return nil;
        };
    };
    
    if([indexPath section]==0){
        UIViewController<ModuleProtocol> *curModuleController;
        if([self isSearchModeForTable:tableView]){
            curModuleController = [[filteredModulesArray objectAtIndex:[indexPath row]] objectForKey:@"viewController"];
        }else{
            curModuleController = [[modulesArray objectAtIndex:[indexPath row]] objectForKey:@"viewController"];
        };
        cell.moduleName.text = [curModuleController getModuleName];
        cell.moduleDescription.text = [curModuleController getModuleDescription];
        cell.moduleMessage.text = [curModuleController getModuleMessage];
        cell.moduleIcon.image = [curModuleController getModuleIcon];
    }else{
        switch([indexPath row]){
            case 0:
                cell.moduleName.text = NSLocalizedString(@"Logout", @"");
                cell.moduleDescription.text = @"";
                cell.moduleMessage.text = @"";
                cell.moduleIcon.image = nil;
                break;
                
            default:
                break;
        };
    };
        
    return cell;

};

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //if([indexPath section]==1) return 44;
    
    switch (largeIcons) {
        case YES:
            return 160.0f;
            break;
            
        case NO:
            return 66.0f;
            break;
            
        default:
            return 44.0f;
            break;
    };
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==1){
        if([indexPath row]==0){
            [applicationDelegate performLogout];
            [self hideSlideMenu];
            return;
        };
    };
    
    
    if(lastSelectedIndexPath) [lastSelectedIndexPath release];
    lastSelectedIndexPath = [indexPath retain];
    [tableView selectRowAtIndexPath:lastSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    UIViewController<ModuleProtocol> *curModuleController;
    if([self isSearchModeForTable:tableView]){
        curModuleController = [[filteredModulesArray objectAtIndex:[indexPath row]] objectForKey:@"viewController"];
    }else{
        curModuleController = [[modulesArray objectAtIndex:[indexPath row]] objectForKey:@"viewController"];
    };
    curModuleController.view.frame = self.view.frame;
    
    //[self.navigationController pushViewController:curModuleController animated:YES];
    applicationDelegate.activeModuleViewController = curModuleController;
    [self hideSlideMenu];
};

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    UIViewController<ModuleProtocol> *curModuleController;
    [filteredModulesArray removeAllObjects]; // First clear the filtered array.
	
	for (NSDictionary *oneModule in modulesArray){
        curModuleController = [oneModule objectForKey:@"viewController"];
        NSString *str = [curModuleController getModuleName];
        NSRange substringRange = [str rangeOfString:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if(substringRange.location != NSNotFound){
            [filteredModulesArray addObject:oneModule];
            continue;
        };
        str = [curModuleController getModuleDescription];
        substringRange = [str rangeOfString:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if(substringRange.location != NSNotFound){
            [filteredModulesArray addObject:oneModule];
            continue;
        };
	};
    
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
};


- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{
    CGRect rct = tableView.frame;
    tableView.frame = CGRectMake(rct.origin.x, rct.origin.y, 240.0, rct.size.height);
    tableView.backgroundColor = [UIColor darkGrayColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view bringSubviewToFront:slidingImageView];
};

/*
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    [UIView animateWithDuration:0.2 animations:^(void){
        modulesTable.alpha = 1.0;
    }];
};*/


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
        
        moduleExchangeList = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:moduleExchangeFileName ofType:nil]] objectForKey:@"items"];
        if(moduleExchangeList == nil){
            NSLog(@"WARNING: getValueForName:fromModuleWithID: exchange list is empty in module with ID \"%@\". Check format of exchange file (plist, one item with name \"items\".", moduleID);
            return nil;
        };
        [oneModuleInfo setObject:moduleExchangeList forKey:@"ExchangeList"];
        //[moduleExchangeList release];
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
        
        moduleExchangeList = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:moduleExchangeFileName ofType:nil]] objectForKey:@"items"];
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

/*- (NSUInteger)getRowForCurrentModuleInTebleView{
    UIViewController<ModuleProtocol> *curViewController = applicationDelegate.activeModuleViewController;
    NSString *curModuleName = 
    
};*/

- (void) recieveRemotePushNotification:(NSDictionary*) userInfo{
    NSString *getModuleID = [userInfo objectForKey:@"id"];
    if ([self isModuleAvailableWithID:getModuleID]) {
        UIViewController<ModuleProtocol> *foundController = (UIViewController<ModuleProtocol> *)[self getViewControllerForModuleWithID:getModuleID]; 
        if (foundController!=nil){
            [foundController receiveRemoteNotification:userInfo];
        }
    }
}

- (void)showSlideMenu{
    [applicationDelegate showSlideMenu];
};

- (void)hideSlideMenu{
    [applicationDelegate updateMenuSliderImage];
    [UIView animateWithDuration:SHOW_HIDE_MENU_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [slidingImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }completion:^(BOOL finished){
        [applicationDelegate hideSlideMenu];
    }];
};

- (void)changeSelectionToIndexPath:(NSIndexPath *)needIndexPath{
    [modulesTable selectRowAtIndexPath:needIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
};

- (void)switchToModuleWithID:(NSString *)moduleID{
    UIViewController *needController = nil;
    NSMutableDictionary *oneModuleInfo;
    int i = 0;
    NSIndexPath *findingIndexPath;
    for(oneModuleInfo in modulesArray){
        if([[oneModuleInfo objectForKey:@"ID"] isEqualToString:moduleID]){
            needController = [oneModuleInfo objectForKey:@"viewController"];
            findingIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        };
        i++;
    };    
    if(needController==nil) return;
    
    [self showSlideMenu];
    applicationDelegate.activeModuleViewController = needController;
    if(lastSelectedIndexPath) [lastSelectedIndexPath release];
    lastSelectedIndexPath = [findingIndexPath retain];
    [self performSelector:@selector(changeSelectionToIndexPath:) withObject:lastSelectedIndexPath afterDelay:SHOW_HIDE_MENU_DURATION/2];
    [self performSelector:@selector(hideSlideMenu) withObject:nil afterDelay:SHOW_HIDE_MENU_DURATION];
};

- (void)showTutorial:(UIView *)moduleTutorialView{
    UIButton *closeButtonAtModuleTutorial = [[UIButton alloc] initWithFrame:moduleTutorialView.bounds];
    [closeButtonAtModuleTutorial addTarget:self action:@selector(closeTutorial:) forControlEvents:UIControlEventTouchUpInside];
    [moduleTutorialView addSubview:closeButtonAtModuleTutorial];
    [closeButtonAtModuleTutorial release];
    moduleTutorialView.userInteractionEnabled = YES;
    moduleTutorialView.alpha = 0.0;
    [applicationDelegate.activeModuleViewController.view addSubview:moduleTutorialView];
    [UIView animateWithDuration:SHOW_HIDE_TUTORIAL_DURATION animations:^(void){
        moduleTutorialView.alpha = 1.0;
    }];
};

- (BOOL)isRetina4{
    return retina4flag;
}


@end
