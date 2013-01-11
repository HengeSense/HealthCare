//
//  WeightControlData.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlData.h"
#import "WeightControlDataCell.h"

@interface WeightControlData ()

@end

@implementation WeightControlData

@synthesize delegate;
@synthesize dataTableView;
@synthesize backgroundImageView;
@synthesize detailView;

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
    // Do any additional setup after loading the view from its nib.
    deletedRow = nil;
    
    detailView.viewControllerDelegate = self;
    [self.view addSubview:detailView];
    
    UILabel *cancelLabel = [[UILabel alloc] initWithFrame:detailView.cancelButton.bounds];
    cancelLabel.backgroundColor = [UIColor clearColor];
    cancelLabel.textAlignment = NSTextAlignmentCenter;
    cancelLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    cancelLabel.shadowColor = [UIColor blackColor];
    cancelLabel.shadowOffset = CGSizeMake(0, 0.5);
    cancelLabel.textColor = [UIColor colorWithRed:121.0/255.0 green:119.0/255.0 blue:128.0/255.0 alpha:1.0];
    cancelLabel.highlightedTextColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:0.35];
    cancelLabel.text = NSLocalizedString(@"Cancel", @"");
    [detailView.cancelButton addSubview:cancelLabel];
    [cancelLabel release];
    
    UILabel *continueLabel = [[UILabel alloc] initWithFrame:detailView.okButton.bounds];
    continueLabel.backgroundColor = [UIColor clearColor];
    continueLabel.textAlignment = NSTextAlignmentCenter;
    continueLabel.font = [UIFont boldSystemFontOfSize:14.0];
    continueLabel.shadowColor = [UIColor blackColor];
    continueLabel.shadowOffset = CGSizeMake(0, 0.5);
    continueLabel.textColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:1.0];
    continueLabel.highlightedTextColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:0.35];
    continueLabel.text = NSLocalizedString(@"Continue", @"");
    [detailView.okButton addSubview:continueLabel];
    [continueLabel release];
    
    
    
    
    if([delegate.weightData count]>0){
        [dataTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    };
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    delegate = nil;
    dataTableView = nil;
    backgroundImageView = nil;
    detailView = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
};

-(void)dealloc{
    [dataTableView release];
    [backgroundImageView release];
    if(detailView) [detailView release];
    if(deletedRow) [deletedRow release];
    [detailView release];
   
    [super dealloc];
};

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [dataTableView reloadData];
};

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
};

/*
// iPhone retina 4 support
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGRect viewRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    NSLog(@"DATA viewWillLayoutSubviews: %.0f, %.0f, %.0f, %.0f", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);

    
    dataTableView.frame = viewRect;
    backgroundImageView.frame = viewRect;
};
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
};
/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Database operations";
            break;
        case 1:
            return @"Data base records";
            break;
            
        default:
            return @"";
            break;
    };
};*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0) return 0.0;
    //if(section==1) return 13.0;
    
    return 0.0;
};

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    /*if(section==0) return nil;
    
    if(section==1){
        UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 13.0)] autorelease];
        UIImageView *headerBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weightControlDataCell_background_headerRecs.png"]];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
        headerLabel.text = @"Records";
        headerLabel.font = [UIFont systemFontOfSize:13.0];
        headerLabel.textAlignment = UITextAlignmentCenter;
        headerLabel.textColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:126.0/255.0 alpha:1.0];
        headerLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:headerBackgroundImage];
        [headerView addSubview:headerLabel];
        [headerBackgroundImage release];
        [headerLabel release];
        
        return headerView;
    };*/
    
    return nil;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0) return 1;
    
    return [delegate.weightData count];
};

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier;
    if([indexPath section]==0){
        CellIdentifier = @"WeightControlEditCellID";
        
        WeightControlDataCell *addCell = (WeightControlDataCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(addCell==nil){
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"WeightControlDataCell" owner:self options:nil];
            for(id oneObject in nibs){
                if([oneObject isKindOfClass:[WeightControlDataCell class]] && [[oneObject reuseIdentifier] isEqualToString:CellIdentifier]){
                    addCell = (WeightControlDataCell *)oneObject;
                    
                    UILabel *addLabel = [[UILabel alloc] initWithFrame:addCell.addButton.bounds];
                    addLabel.backgroundColor = [UIColor clearColor];
                    addLabel.textAlignment = NSTextAlignmentCenter;
                    addLabel.font = [UIFont boldSystemFontOfSize:14.0];
                    addLabel.shadowColor = [UIColor blackColor];
                    addLabel.shadowOffset = CGSizeMake(0, 0.5);
                    addLabel.textColor = [UIColor colorWithRed:121.0/255.0 green:119.0/255.0 blue:128.0/255.0 alpha:1.0];
                    addLabel.highlightedTextColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:0.35];
                    addLabel.text = NSLocalizedString(@"Add", @"");
                    [addCell.addButton addSubview:addLabel];
                    [addLabel release];
                    
                    UILabel *editLabel = [[UILabel alloc] initWithFrame:addCell.editButton.bounds];
                    editLabel.backgroundColor = [UIColor clearColor];
                    editLabel.textAlignment = NSTextAlignmentCenter;
                    editLabel.font = [UIFont boldSystemFontOfSize:14.0];
                    editLabel.shadowColor = [UIColor blackColor];
                    editLabel.shadowOffset = CGSizeMake(0, 0.5);
                    editLabel.textColor = [UIColor colorWithRed:121.0/255.0 green:119.0/255.0 blue:128.0/255.0 alpha:1.0];
                    editLabel.highlightedTextColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:0.35];
                    editLabel.text = NSLocalizedString(@"Edit", @"");
                    [addCell.editButton addSubview:editLabel];
                    [editLabel release];
                    
                    UILabel *removeLabel = [[UILabel alloc] initWithFrame:addCell.removeButton.bounds];
                    removeLabel.backgroundColor = [UIColor clearColor];
                    removeLabel.textAlignment = NSTextAlignmentCenter;
                    removeLabel.font = [UIFont boldSystemFontOfSize:14.0];
                    removeLabel.shadowColor = [UIColor blackColor];
                    removeLabel.shadowOffset = CGSizeMake(0, 0.5);
                    removeLabel.textColor = [UIColor colorWithRed:121.0/255.0 green:119.0/255.0 blue:128.0/255.0 alpha:1.0];
                    removeLabel.highlightedTextColor = [UIColor colorWithRed:155.0/255.0 green:153.0/255.0 blue:164.0/255.0 alpha:0.35];
                    removeLabel.text = NSLocalizedString(@"Remove", @"");
                    [addCell.removeButton addSubview:removeLabel];
                    [removeLabel release];
                    
                    
                    [addCell.addButton addTarget:self action:@selector(addDataRecord:) forControlEvents:UIControlEventTouchUpInside];
                    [addCell.editButton addTarget:self action:@selector(pressEdit:) forControlEvents:UIControlEventTouchUpInside];
                    [addCell.removeButton addTarget:self action:@selector(removeAllDatabase:) forControlEvents:UIControlEventTouchUpInside];
                };
            };
        };

        
                
        return addCell;
    };
    
    CellIdentifier = @"WeightControlDataCellID";
    NSUInteger curRecIndex = [delegate.weightData count] - [indexPath row] - 1;
    WeightControlDataCell *cell = (WeightControlDataCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"WeightControlDataCell" owner:self options:nil];
        for(id oneObject in nibs){
            if([oneObject isKindOfClass:[WeightControlDataCell class]] && [[oneObject reuseIdentifier] isEqualToString:CellIdentifier]){
                cell = (WeightControlDataCell *)oneObject;
            };
        };
    };

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yy"];
    NSString *dateString = [dateFormatter stringFromDate:[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"date"]];
    [dateFormatter setDateFormat:@"EE"];
    NSString *weekdayString = [[dateFormatter stringFromDate:[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"date"]] uppercaseString];
    [dateFormatter release];
    float curWeight = [[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"weight"] floatValue];
    float curTrend = [[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"trend"] floatValue];
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@", dateString];
    //NSString *deltaStr;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f kg", [[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"weight"] floatValue]];
    cell.weekdayLabel.text = weekdayString;
    cell.dateLabel.text = dateString;
    cell.weightLabel.text = [delegate getWeightStrForWeightInKg:curWeight withUnit:YES];
    cell.trendTitleLabel.text = NSLocalizedString(@"Trend:", @"");
    cell.trendLabel.text = [delegate getWeightStrForWeightInKg:curTrend withUnit:YES];
    cell.deviationTitleLabel.text = NSLocalizedString(@"Deviation", @"");
    cell.deviationLabel.text = [NSString stringWithFormat:@"%@%@", (curWeight > curTrend ? @"+" : @""), [delegate getWeightStrForWeightInKg:curWeight-curTrend withUnit:YES]];
    if(curWeight > curTrend){
        cell.deviationLabel.textColor = [UIColor colorWithRed:161.0/255.0 green:16.0/255.0 blue:48.0/255.0 alpha:1.0];
    }else if(curWeight < curTrend){
        cell.deviationLabel.textColor = [UIColor colorWithRed:119.0/255.0 green:156.0/255.0 blue:57.0/255.0 alpha:1.0];
    }else{
        cell.deviationLabel.textColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:126.0/255.0 alpha:1.0];
    };
    cell.deviationTitleLabel.alpha = 1.0;
    cell.deviationLabel.alpha = 1.0;
    
    return cell;

};


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"BEGIN editing row at index path: %d-%d", indexPath.section, indexPath.row);
    if([indexPath section]==0) return;
    
    WeightControlDataCell *cell = (WeightControlDataCell *)[tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.4 animations:^(void){
        cell.deviationTitleLabel.alpha = 0.0;
        cell.deviationLabel.alpha = 0.0;
    }];
};

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"END editing row at index path: %d-%d", indexPath.section, indexPath.row);
    if([indexPath section]==0) return;
    WeightControlDataCell *cell = (WeightControlDataCell *)[tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.4 animations:^(void){
        cell.deviationTitleLabel.alpha = 1.0;
        cell.deviationLabel.alpha = 1.0;
    }];
};

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0) return 70.0;
    
    return 70.0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0){
        return nil;
    };
    
    return indexPath;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0){
        return;
    };
    
    NSUInteger curRecIndex = [delegate.weightData count] - [indexPath row] - 1;
    
    detailView.curWeight = [[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"weight"] floatValue];
    detailView.datePicker.date = [[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"date"];
    editingRecordIndex = curRecIndex;
    
    MainInformation *antropometryController = (MainInformation *)[delegate.delegate getViewControllerForModuleWithID:@"selfhub.antropometry"];
    if(antropometryController!=nil){
        detailView.rulerScrollView.minWeightKg = [antropometryController getMinWeightKg];
        detailView.rulerScrollView.maxWeightKg = [antropometryController getMaxWeightKg];
        detailView.rulerScrollView.stepWeightKg = [antropometryController getWeightPickerStep];
        detailView.rulerScrollView.weightFactor = [antropometryController getWeightFactor];
    }else{
        detailView.rulerScrollView.minWeightKg = 30.0;
        detailView.rulerScrollView.maxWeightKg = 300.0;
        detailView.rulerScrollView.stepWeightKg = 0.1;
        detailView.rulerScrollView.weightFactor = 1.0;
    };

    
    [detailView showView];
}

- (IBAction)addDataRecord:(id)sender{
    if([delegate.weightData count]>0){
        detailView.curWeight = [[[delegate.weightData lastObject] objectForKey:@"weight"] floatValue];
    }else{
        detailView.curWeight = 75.0;
    };
    detailView.datePicker.date = [NSDate date];
    editingRecordIndex = -1;
    
    MainInformation *antropometryController = (MainInformation *)[delegate.delegate getViewControllerForModuleWithID:@"selfhub.antropometry"];
    if(antropometryController!=nil){
        detailView.rulerScrollView.minWeightKg = [antropometryController getMinWeightKg];
        detailView.rulerScrollView.maxWeightKg = [antropometryController getMaxWeightKg];
        detailView.rulerScrollView.stepWeightKg = [antropometryController getWeightPickerStep];
        detailView.rulerScrollView.weightFactor = [antropometryController getWeightFactor];
    }else{
        detailView.rulerScrollView.minWeightKg = 30.0;
        detailView.rulerScrollView.maxWeightKg = 300.0;
        detailView.rulerScrollView.stepWeightKg = 0.1;
        detailView.rulerScrollView.weightFactor = 1.0;
    };

    
    [detailView showView];
};

- (IBAction)pressEdit:(id)sender{
    [dataTableView setEditing:!(dataTableView.isEditing)];
    if(sender){
        [sender setSelected:![sender isSelected]];
    }
};

- (IBAction)removeAllDatabase:(id)sender{
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to erase ALL records? This action is undone!", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:NSLocalizedString(@"ERASE ALL RECORDS", @"") otherButtonTitles:nil];
    actionSheet.tag = 1;
	[actionSheet showInView:self.view];
	[actionSheet release];  
    
};

- (IBAction)testFillDatabase{
    UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"This action will overwrite existing records. Are you sure you want to fill database by randomize weights? This action is undone!", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:NSLocalizedString(@"Fill base by randomize weights", @"") otherButtonTitles:nil];
    actionSheet.tag = 2;
	[actionSheet showInView:self.view];
	[actionSheet release];
};

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0) return NO;
    
    return YES;
};

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    [self tableView:tableView didEndEditingRowAtIndexPath:indexPath];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    if(deletedRow!=nil) [deletedRow release];
    deletedRow = nil;
	deletedRow = [indexPath retain];//[NSIndexPath indexPathForRow:[indexPath row] inSection:[indexPath section]]; //indexPath;
    //NSLog(@"deleted row: %d, %d",[deletedRow section], [deletedRow row]);
    
	UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to erase this record?", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:NSLocalizedString(@"Erase", @"") otherButtonTitles:nil];
    actionSheet.tag = 0;
	[actionSheet showInView:self.view];
	[actionSheet release];  
}


#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0){
        if(actionSheet.tag==0){ //Erase one record
            NSUInteger curRecordIndex = [delegate.weightData count] - [deletedRow row] - 1;
            [delegate.weightData removeObjectAtIndex:curRecordIndex];
            [delegate updateTrendsFromIndex:curRecordIndex];
            [dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:deletedRow] withRowAnimation:UITableViewRowAnimationFade];
            //[dataTableView reloadData];
            [delegate saveModuleData];
        };
        if(actionSheet.tag==1){ //Erase all database
            NSMutableArray *deletedRows = [[NSMutableArray alloc] init];
            for(int i=0;i<[delegate.weightData count];i++){
                [deletedRows addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
            [delegate.weightData removeAllObjects];
            [dataTableView deleteRowsAtIndexPaths:deletedRows withRowAnimation:UITableViewRowAnimationFade];
            [deletedRows release];
            //[dataTableView reloadData];
            
            [delegate saveModuleData];
        };
        if(actionSheet.tag==2){ //Test-fill database
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setMonth:03];
            [dateComponents setDay:25];
            [dateComponents setYear:2011];
            [dateComponents setHour:0];
            [dateComponents setMinute:0];
            [dateComponents setSecond:0];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *startTestFillDate = [gregorian dateFromComponents:dateComponents];
            [dateComponents release];
            [gregorian release];
            
            NSTimeInterval timeIntBetweenStartTestAndNow = [[NSDate date] timeIntervalSinceDate:startTestFillDate];
            [delegate fillTestData:(NSUInteger)(timeIntBetweenStartTestAndNow/(60*60*24))-1];
            [delegate updateTrendsFromIndex:0];
            [dataTableView reloadData];
            
            [delegate saveModuleData];
        };
	};
    if(buttonIndex==1){
        if(actionSheet.tag==0){
            [self pressCancelRecord];
        };
    };
};

#pragma mark - WeightControlAddRecordProtocol

- (void)pressAddRecord:(NSDictionary *)newRecord{
    NSDate *newDate = [delegate getDateWithoutTime:[newRecord objectForKey:@"date"]];
    NSNumber *newWeight = [newRecord objectForKey:@"weight"];
    NSComparisonResult compRes;
    NSUInteger curIndex = 0;
    NSDictionary *newRec;
    
    if(editingRecordIndex==-1){ //Adding new record
        for(NSDictionary *oneRecord in delegate.weightData){
            compRes = [delegate compareDateByDays:newDate WithDate:[oneRecord objectForKey:@"date"]];
            if(compRes==NSOrderedSame){
                [delegate.weightData removeObject:oneRecord];
                break;
            };
            
            if(compRes==NSOrderedAscending){
                break;
            };
            
            curIndex++;
        };
        
        newRec = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:newDate, newWeight, nil] forKeys:[NSArray arrayWithObjects:@"date", @"weight", nil]];
        [delegate.weightData insertObject:newRec atIndex:curIndex];
        [delegate updateTrendsFromIndex:curIndex];
    }else{      //Finish editing existing record
        //compRes = [delegate compareDateByDays:newDate WithDate:[[delegate.weightData objectAtIndex:editingRecordIndex] objectForKey:@"date"]];
        [delegate.weightData removeObjectAtIndex:editingRecordIndex];
        for(NSDictionary *oneRecord in delegate.weightData){
            compRes = [delegate compareDateByDays:newDate WithDate:[oneRecord objectForKey:@"date"]];   
            if(compRes==NSOrderedSame){
                [delegate.weightData removeObject:oneRecord];
                break;
            };
            if(compRes==NSOrderedAscending){
                break;
            };
            curIndex++;
        };
        newRec = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:newDate, newWeight, nil] forKeys:[NSArray arrayWithObjects:@"date", @"weight", nil]];
        [delegate.weightData insertObject:newRec atIndex:curIndex];
        [delegate updateTrendsFromIndex:curIndex];
    };
    
    [delegate saveModuleData];
    [dataTableView reloadData];
    [dataTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:([delegate.weightData count] - curIndex - 1) inSection:1] animated:YES scrollPosition:UITableViewScrollPositionMiddle];

};

- (void)pressCancelRecord{
    //[[dataTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:editingRecordIndex inSection:1]] setEditing:NO];
    //  [dataTableView setEditing:NO];
    [dataTableView reloadData];
    
};



@end
