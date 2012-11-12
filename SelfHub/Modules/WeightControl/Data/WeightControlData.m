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
    detailView = nil;
}

-(void)dealloc{
    [dataTableView release];
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
    if(section==1) return 13.0;
    
    return 0.0;
};

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==0) return nil;
    
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
    };
    
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
    NSString *weekdayString = [dateFormatter stringFromDate:[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"date"]];
    [dateFormatter release];
    float curWeight = [[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"weight"] floatValue];
    float curTrend = [[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"trend"] floatValue];
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@", dateString];
    //NSString *deltaStr;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f kg", [[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"weight"] floatValue]];
    cell.weekdayLabel.text = weekdayString;
    cell.dateLabel.text = dateString;
    cell.weightLabel.text = [NSString stringWithFormat:@"%.1f kg", curWeight];
    cell.trendLabel.text = [NSString stringWithFormat:@"%.1f kg", curTrend];
    cell.deviationLabel.text = [NSString stringWithFormat:@"%@%.1f kg", (curWeight > curTrend ? @"+" : @""), curWeight-curTrend];
    if(curWeight > curTrend){
        cell.deviationLabel.textColor = [UIColor colorWithRed:161.0/255.0 green:16.0/255.0 blue:48.0/255.0 alpha:1.0];
    }else if(curWeight < curTrend){
        cell.deviationLabel.textColor = [UIColor colorWithRed:119.0/255.0 green:156.0/255.0 blue:57.0/255.0 alpha:1.0];
    }else{
        cell.deviationLabel.textColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:126.0/255.0 alpha:1.0];
    };
    
    return cell;

};


#pragma mark - UITableViewDelegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0) return 57.0;
    
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
            [dataTableView reloadData];
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
            [dataTableView reloadData];
            
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
};

#pragma mark - WeightControlAddRecordProtocol

- (void)pressAddRecord:(NSDictionary *)newRecord{
    NSDate *newDate = [newRecord objectForKey:@"date"];
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
    
    if([delegate compareDateByDays:newDate WithDate:[NSDate date]] == NSOrderedSame){   //Setting weight in antropometry module
        [delegate.delegate setValue:newWeight forName:@"weight" forModuleWithID:@"selfhub.antropometry"];
    }
    
    [delegate saveModuleData];
    [dataTableView reloadData];
    [dataTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:([delegate.weightData count] - curIndex - 1) inSection:1] animated:YES scrollPosition:UITableViewScrollPositionMiddle];

};

- (void)pressCancelRecord{
    
};



@end
