//
//  WeightControlStatistics.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlStatistics.h"

@interface WeightControlStatistics ()

@end

@implementation WeightControlStatistics

@synthesize delegate, statTableView;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    delegate = nil;
    statTableView = nil;
}

-(void)dealloc{
    [statTableView release];
    
    [super dealloc];
};

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [statTableView reloadData];
};


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (float)getRecordValueAtTimeInterval:(NSTimeInterval)needInterval forKey:(NSString *)key{
    float needWeight = 0.0;
    NSDictionary *oneRecord = nil;
    NSUInteger i;
    NSTimeInterval testedTimeInt;
    float w1, w2;
    for(i=0;i<[delegate.weightData count]-1;i++){
        oneRecord = [delegate.weightData objectAtIndex:i];
        testedTimeInt = [[oneRecord objectForKey:@"date"] timeIntervalSince1970];
        NSDictionary *nextRecord = [delegate.weightData objectAtIndex:i+1];
        NSTimeInterval nextTimeInt = [[nextRecord objectForKey:@"date"] timeIntervalSince1970];
        if(needInterval>=testedTimeInt && needInterval<=nextTimeInt){
            if(i<[delegate.weightData count]-1){
                w1 = [[oneRecord objectForKey:key] floatValue];
                w2 = [[nextRecord objectForKey:key] floatValue];
                needWeight = w1 + (((needInterval - testedTimeInt) * (w2 - w1)) / (nextTimeInt - testedTimeInt));
                break;
            };
        };
    };

    return needWeight;
};

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
};

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 70.0;
};

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)] autorelease];
    UIImageView *headerBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weightControlStatistic_headerBackground.png"]];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    switch (section) {
        case 0:
            headerLabel.text = @"Trends statistic";
            break;
        case 1:
            headerLabel.text = @"Data base statistic";
            break;
            
        case 2:
            headerLabel.text = @"Weight statistic";
            break;
            
        default:
            headerLabel.text = @"";
            break;
    };
    headerLabel.font = [UIFont boldSystemFontOfSize:22.0];
    headerLabel.textAlignment = UITextAlignmentLeft;
    headerLabel.textColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:126.0/255.0 alpha:1.0];
    headerLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerBackgroundImage];
    [headerView addSubview:headerLabel];
    [headerBackgroundImage release];
    [headerLabel release];
    
    return headerView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 7;
            break;
        case 1:
            return 2;
            break;
            
        case 2:
            return 8;
            break;
            
        default:
            return 0;
            break;
    };

};

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath section]==0){
        return 22.0;
    };
    
    return 44.0;
    
    
};


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /*NSString *CellIdentifier;
    CellIdentifier = @"addCellID";
    
    UITableViewCell *addCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (addCell == nil) {
        addCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        addCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIButton *addContactButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addContactButton addTarget:self action:@selector(addDataRecord) forControlEvents:UIControlEventTouchUpInside];
        addCell.accessoryView = addContactButton;
        addCell.textLabel.textAlignment = UITextAlignmentCenter;
        addCell.textLabel.text = @"Add data";
    };
    
    return addCell;*/

    
    
    
    static NSString *cellID;
    if([indexPath section]==0){
        cellID = @"WeightControlStatisticsCellSmallID";
    }else{
        cellID = @"WeightControlStatisticsCellBigID";
    }
    
    WeightControlStatisticsCell *cell = (WeightControlStatisticsCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil){
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"WeightControlStatisticsCell" owner:self options:nil];
        for(id oneObject in nibs){
            if([oneObject isKindOfClass:[WeightControlStatisticsCell class]] && [[oneObject reuseIdentifier] isEqualToString:cellID]){
                cell = (WeightControlStatisticsCell *)oneObject;
            };
        };
    };
    
    cell.mainLabel.text = @"Last...";
    cell.label1.text = @"kg/week";
    cell.label2.text = @"kcal/day";
    
    //Trends cells
    if([indexPath section]==0){
        UIFont *labelsFont;
        if([indexPath row]==0){
            labelsFont = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        }else{
            labelsFont = [UIFont fontWithName:@"Helvetica" size:15];
        };
        cell.mainLabel.font = labelsFont;
        cell.label1.font = labelsFont;
        cell.label2.font = labelsFont;
        
        NSTimeInterval startTimeInterval = 0, lastTimeInterval = 0;
        if([delegate.weightData count]>0){
            startTimeInterval = [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
            lastTimeInterval = [[[delegate.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
        };
        NSTimeInterval oneDay = 60 * 60 *24;
        NSTimeInterval curTimeInterval;
        float startTrend, endTrend, kgweek;
        
        cell.backgroundImageView.image = [UIImage imageNamed:([indexPath row]==0 ? @"weightControlStatistic_smallCellLightBackground.png" : @"weightControlStatistic_smallCellBackground.png")];
        
        UIColor *grayColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:126.0/255.0 alpha:1.0];
        UIColor *greenColor = [UIColor colorWithRed:119.0/255.0 green:156.0/255.0 blue:57.0/255.0 alpha:1.0];
        UIColor *redColor = [UIColor colorWithRed:161.0/255.0 green:16.0/255.0 blue:48.0/255.0 alpha:1.0];
        
        
        switch ([indexPath row]) {
            case 0:
                cell.mainLabel.text = @"Last...";
                cell.label1.text = @"kg/week";
                cell.label2.text = @"kcal/day";
                cell.label1.textColor = grayColor;
                cell.label2.textColor = grayColor;
                
                break;
            case 1:
                cell.mainLabel.text = @"Week";
                if([delegate.weightData count]==0){
                    cell.label1.text = @"0.0";
                    cell.label2.text = @"0.0";
                    break;
                };
                curTimeInterval = lastTimeInterval - oneDay * 7;
                if(curTimeInterval<startTimeInterval) curTimeInterval = startTimeInterval;
                startTrend = [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                endTrend = [self getRecordValueAtTimeInterval:lastTimeInterval forKey:@"trend"];
                kgweek = (endTrend - startTrend) / 1.0;
                
                cell.label1.text = [NSString stringWithFormat:@"%@%.2f", (kgweek>0 ? @"+" : @""), kgweek];
                cell.label2.text = [NSString stringWithFormat:@"%@%.1f", (kgweek>0 ? @"+" : @""), kgweek * 1100.0];
                cell.label1.textColor = (kgweek > 0.0 ? redColor : greenColor);
                cell.label2.textColor = (kgweek > 0.0 ? redColor : greenColor);
                
                break;
                
            case 2:
                cell.mainLabel.text = @"15 days";
                if([delegate.weightData count]==0){
                    cell.label1.text = @"0.0";
                    cell.label2.text = @"0.0";
                    break;
                };
                curTimeInterval = lastTimeInterval - oneDay * 15;
                if(curTimeInterval<startTimeInterval) curTimeInterval = startTimeInterval;
                startTrend = [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                endTrend = [self getRecordValueAtTimeInterval:lastTimeInterval forKey:@"trend"];
                kgweek = (endTrend - startTrend) / (15.0/7.0);
                cell.label1.text = [NSString stringWithFormat:@"%@%.2f", (kgweek>0 ? @"+" : @""), kgweek];
                cell.label2.text = [NSString stringWithFormat:@"%@%.1f", (kgweek>0 ? @"+" : @""), kgweek * 1100.0];
                cell.label1.textColor = (kgweek > 0.0 ? redColor : greenColor);
                cell.label2.textColor = (kgweek > 0.0 ? redColor : greenColor);
                
                break;
                
            case 3:
                cell.mainLabel.text = @"Month";
                if([delegate.weightData count]==0){
                    cell.label1.text = @"0.0";
                    cell.label2.text = @"0.0";
                    break;
                };
                curTimeInterval = lastTimeInterval - oneDay * 30;
                if(curTimeInterval<startTimeInterval) curTimeInterval = startTimeInterval;
                startTrend = [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                endTrend = [self getRecordValueAtTimeInterval:lastTimeInterval forKey:@"trend"];
                kgweek = (endTrend - startTrend) / (30.0/7.0);
                cell.label1.text = [NSString stringWithFormat:@"%@%.2f", (kgweek>0 ? @"+" : @""), kgweek];
                cell.label2.text = [NSString stringWithFormat:@"%@%.1f", (kgweek>0 ? @"+" : @""), kgweek * 1100.0];
                cell.label1.textColor = (kgweek > 0.0 ? redColor : greenColor);
                cell.label2.textColor = (kgweek > 0.0 ? redColor : greenColor);
                
                break;
                
            case 4:
                cell.mainLabel.text = @"3 month";
                if([delegate.weightData count]==0){
                    cell.label1.text = @"0.0";
                    cell.label2.text = @"0.0";
                    break;
                };
                curTimeInterval = lastTimeInterval - oneDay * 91;
                if(curTimeInterval<startTimeInterval) curTimeInterval = startTimeInterval;
                startTrend = [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                endTrend = [self getRecordValueAtTimeInterval:lastTimeInterval forKey:@"trend"];
                kgweek = (endTrend - startTrend) / (91.0/7.0);
                cell.label1.text = [NSString stringWithFormat:@"%@%.2f", (kgweek>0 ? @"+" : @""), kgweek];
                cell.label2.text = [NSString stringWithFormat:@"%@%.1f", (kgweek>0 ? @"+" : @""), kgweek * 1100.0];
                cell.label1.textColor = (kgweek > 0.0 ? redColor : greenColor);
                cell.label2.textColor = (kgweek > 0.0 ? redColor : greenColor);
                
                break;
                
            case 5:
                cell.mainLabel.text = @"6 month";
                if([delegate.weightData count]==0){
                    cell.label1.text = @"0.0";
                    cell.label2.text = @"0.0";
                    break;
                };
                curTimeInterval = lastTimeInterval - oneDay * 182;
                if(curTimeInterval<startTimeInterval) curTimeInterval = startTimeInterval;
                startTrend = [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                endTrend = [self getRecordValueAtTimeInterval:lastTimeInterval forKey:@"trend"];
                kgweek = (endTrend - startTrend) / (182.0/7.0);
                cell.label1.text = [NSString stringWithFormat:@"%@%.2f", (kgweek>0 ? @"+" : @""), kgweek];
                cell.label2.text = [NSString stringWithFormat:@"%@%.1f", (kgweek>0 ? @"+" : @""), kgweek * 1100.0];
                cell.label1.textColor = (kgweek > 0.0 ? redColor : greenColor);
                cell.label2.textColor = (kgweek > 0.0 ? redColor : greenColor);
                
                break;
                
            case 6:
                cell.mainLabel.text = @"Year";
                if([delegate.weightData count]==0){
                    cell.label1.text = @"0.0";
                    cell.label2.text = @"0.0";
                    break;
                };
                curTimeInterval = lastTimeInterval - oneDay * 365;
                if(curTimeInterval<startTimeInterval) curTimeInterval = startTimeInterval;
                startTrend = [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                endTrend = [self getRecordValueAtTimeInterval:lastTimeInterval forKey:@"trend"];
                kgweek = (endTrend - startTrend) / (365.0/7.0);
                cell.label1.text = [NSString stringWithFormat:@"%@%.2f", (kgweek>0 ? @"+" : @""), kgweek];
                cell.label2.text = [NSString stringWithFormat:@"%@%.1f", (kgweek>0 ? @"+" : @""), kgweek * 1100.0];
                cell.label1.textColor = (kgweek > 0.0 ? redColor : greenColor);
                cell.label2.textColor = (kgweek > 0.0 ? redColor : greenColor);
                
                break;
                
            default:
                break;
        };
    };
    
    //Data base cells
    if([indexPath section]==1){
        switch ([indexPath row]) {
            case 0:
                cell.mainLabel.text = @"Database size";
                cell.label1.text = [NSString stringWithFormat:@"records: %d", [delegate.weightData count]];
                NSUInteger yearsNum=0, monthNum=0, daysNum=0;
                if([delegate.weightData count]>0){
                    NSDate *firstDate = [[delegate.weightData objectAtIndex:0] objectForKey:@"date"];
                    NSDate *lastDate = [[delegate.weightData lastObject] objectForKey:@"date"];
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)  fromDate:firstDate toDate:lastDate options:0];
                    [gregorian release];
                    yearsNum = [dateComponents year];
                    monthNum = [dateComponents month];
                    daysNum = [dateComponents day];
                };
                cell.label2.text = [NSString stringWithFormat:@"years: %d, months: %d, days: %d", yearsNum, monthNum, daysNum];
                
                break;
            case 1:
                cell.mainLabel.text = @"Total weight change";
                float weightChangeKg = 0.0, weightChangePercents = 0.0;
                if([delegate.weightData count]>0){
                    float firstWeight = [[[delegate.weightData objectAtIndex:0] objectForKey:@"weight"] floatValue];
                    float lastWeight = [[[delegate.weightData lastObject] objectForKey:@"weight"] floatValue];
                    weightChangeKg = lastWeight - firstWeight;
                    if(fabs(firstWeight)<0.001){
                        weightChangePercents = NAN;
                    }else{
                        weightChangePercents = (lastWeight/firstWeight)*100.0 - 100.0;
                    };
                };
                cell.label1.text = [NSString stringWithFormat:@"%.1f kg (%.1f%%)", weightChangeKg, weightChangePercents];
                cell.label2.text = @"";
                break;
                
            default:
                break;
        };
    };
    
    
    
    
    //Weight cells
    if([indexPath section]==2){
        NSString *strOut;
        float floatOut;
        NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
        dateFormat1.dateFormat = @"dd MMMM YYYY";
        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
        dateFormat2.dateFormat = @"MMMM YYYY";
        
        switch ([indexPath row]) {
            case 0:
                cell.mainLabel.text = @"Max weight";
                floatOut = 0.0;
                strOut = @"";
                if([delegate.weightData count]>0){
                    for(NSDictionary *oneRec in delegate.weightData){
                        if([[oneRec objectForKey:@"weight"] floatValue]>floatOut){
                            floatOut = [[oneRec objectForKey:@"weight"] floatValue];
                            strOut = [dateFormat1 stringFromDate:[oneRec objectForKey:@"date"]];
                        };
                    };
                };
                cell.label1.text = [NSString stringWithFormat:@"%.1f kg", floatOut];
                cell.label2.text = [NSString stringWithFormat:@"%@", strOut];
                break;
                
            case 1:
                cell.mainLabel.text = @"Min weight";
                floatOut = 0.0;
                strOut = @"";
                if([delegate.weightData count]>0){
                    floatOut = 1000.0;
                    for(NSDictionary *oneRec in delegate.weightData){
                        if([[oneRec objectForKey:@"weight"] floatValue]<floatOut){
                            floatOut = [[oneRec objectForKey:@"weight"] floatValue];
                            strOut = [dateFormat1 stringFromDate:[oneRec objectForKey:@"date"]];
                        };
                    };
                };
                cell.label1.text = [NSString stringWithFormat:@"%.1f kg", floatOut];
                cell.label2.text = [NSString stringWithFormat:@"%@", strOut];
                break;
                
            case 2:
                cell.mainLabel.text = @"Max trend";
                floatOut = 0.0;
                strOut = @"";
                if([delegate.weightData count]>0){
                    for(NSDictionary *oneRec in delegate.weightData){
                        if([[oneRec objectForKey:@"trend"] floatValue]>floatOut){
                            floatOut = [[oneRec objectForKey:@"trend"] floatValue];
                            strOut = [dateFormat1 stringFromDate:[oneRec objectForKey:@"date"]];
                        };
                    };
                };
                cell.label1.text = [NSString stringWithFormat:@"%.1f kg", floatOut];
                cell.label2.text = [NSString stringWithFormat:@"%@", strOut];
                break;
                
            case 3:
                cell.mainLabel.text = @"Min trend";
                floatOut = 0.0;
                strOut = @"";
                if([delegate.weightData count]>0){
                    floatOut = 1000.0;
                    for(NSDictionary *oneRec in delegate.weightData){
                        if([[oneRec objectForKey:@"trend"] floatValue]<floatOut){
                            floatOut = [[oneRec objectForKey:@"trend"] floatValue];
                            strOut = [dateFormat1 stringFromDate:[oneRec objectForKey:@"date"]];
                        };
                    };
                };
                cell.label1.text = [NSString stringWithFormat:@"%.1f kg", floatOut];
                cell.label2.text = [NSString stringWithFormat:@"%@", strOut];
                break;
                
            case 4:
                cell.mainLabel.text = @"Month with max weight-loss";
                floatOut = 0.0;
                strOut = @"";
                if([delegate.weightData count]>0){
                    NSDateComponents *dateComponents;
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDate *refDate;
                    
                    NSTimeInterval firstTimeInterval = [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
                    NSTimeInterval lastTimeInterval = [[[delegate.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
                    NSTimeInterval curTimeInterval = firstTimeInterval;
                    float curDiff;
                    do{
                        dateComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate dateWithTimeIntervalSince1970:curTimeInterval]];
                        [dateComponents setDay:1];
                        if(dateComponents.month==12){
                            dateComponents.month = 1;
                            dateComponents.year++;
                        }else{
                            dateComponents.month++;
                        };
                        refDate = [gregorian dateFromComponents:dateComponents];
                        if(refDate.timeIntervalSince1970>lastTimeInterval){
                            refDate = [NSDate dateWithTimeIntervalSince1970:lastTimeInterval];
                        };
                        
                        curDiff = [self getRecordValueAtTimeInterval:[refDate timeIntervalSince1970] forKey:@"trend"] - [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                        if(curDiff <= floatOut){
                            floatOut = curDiff;
                            strOut = [dateFormat2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:curTimeInterval]];
                        };
                        curTimeInterval = [refDate timeIntervalSince1970];
                    }while(curTimeInterval<lastTimeInterval);
                    [gregorian release];

                };
                cell.label1.text = [NSString stringWithFormat:@"%@", strOut];
                cell.label2.text = [NSString stringWithFormat:@"%.1f kg", floatOut];
                break;
                
            case 5:
                cell.mainLabel.text = @"Month with max weight-gain";
                floatOut = 0.0;
                strOut = @"";
                if([delegate.weightData count]>0){
                    NSDateComponents *dateComponents;
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDate *refDate;
                    
                    NSTimeInterval firstTimeInterval = [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
                    NSTimeInterval lastTimeInterval = [[[delegate.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
                    NSTimeInterval curTimeInterval = firstTimeInterval;
                    float curDiff;
                    do{
                        dateComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate dateWithTimeIntervalSince1970:curTimeInterval]];
                        [dateComponents setDay:1];
                        if(dateComponents.month==12){
                            dateComponents.month = 1;
                            dateComponents.year++;
                        }else{
                            dateComponents.month++;
                        };
                        refDate = [gregorian dateFromComponents:dateComponents];
                        if(refDate.timeIntervalSince1970>lastTimeInterval){
                            refDate = [NSDate dateWithTimeIntervalSince1970:lastTimeInterval];
                        };
                        
                        curDiff = [self getRecordValueAtTimeInterval:[refDate timeIntervalSince1970] forKey:@"trend"] - [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                        if(curDiff >= floatOut){
                            floatOut = curDiff;
                            strOut = [dateFormat2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:curTimeInterval]];
                        };
                        curTimeInterval = [refDate timeIntervalSince1970];
                    }while(curTimeInterval<lastTimeInterval);
                    [gregorian release];
                    
                };
                cell.label1.text = [NSString stringWithFormat:@"%@", strOut];
                cell.label2.text = [NSString stringWithFormat:@"%.1f kg", floatOut];
                break;
                
            case 6:
                cell.mainLabel.text = @"Month with max weight-loss in percents";
                floatOut = 0.0;
                strOut = @"";
                if([delegate.weightData count]>0){
                    NSDateComponents *dateComponents;
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDate *refDate;
                    
                    NSTimeInterval firstTimeInterval = [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
                    NSTimeInterval lastTimeInterval = [[[delegate.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
                    NSTimeInterval curTimeInterval = firstTimeInterval;
                    float curDiff;
                    do{
                        dateComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate dateWithTimeIntervalSince1970:curTimeInterval]];
                        [dateComponents setDay:1];
                        if(dateComponents.month==12){
                            dateComponents.month = 1;
                            dateComponents.year++;
                        }else{
                            dateComponents.month++;
                        };
                        refDate = [gregorian dateFromComponents:dateComponents];
                        if(refDate.timeIntervalSince1970>lastTimeInterval){
                            refDate = [NSDate dateWithTimeIntervalSince1970:lastTimeInterval];
                        };
                        
                        float w1, w2;
                        w1 = [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                        w2 = [self getRecordValueAtTimeInterval:[refDate timeIntervalSince1970] forKey:@"trend"];
                        curDiff = (w2 - w1) / w1;
                        if(curDiff <= floatOut){
                            floatOut = curDiff;
                            strOut = [dateFormat2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:curTimeInterval]];
                        };
                        curTimeInterval = [refDate timeIntervalSince1970];
                    }while(curTimeInterval<lastTimeInterval);
                    [gregorian release];
                    
                };
                cell.label1.text = [NSString stringWithFormat:@"%@", strOut];
                cell.label2.text = [NSString stringWithFormat:@"%.1f %%", floatOut*100.0];
                break;
                
            case 7:
                cell.mainLabel.text = @"Month with max weight-gain in percents";
                floatOut = 0.0;
                strOut = @"";
                if([delegate.weightData count]>0){
                    NSDateComponents *dateComponents;
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDate *refDate;
                    
                    NSTimeInterval firstTimeInterval = [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
                    NSTimeInterval lastTimeInterval = [[[delegate.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
                    NSTimeInterval curTimeInterval = firstTimeInterval;
                    float curDiff;
                    do{
                        dateComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate dateWithTimeIntervalSince1970:curTimeInterval]];
                        [dateComponents setDay:1];
                        if(dateComponents.month==12){
                            dateComponents.month = 1;
                            dateComponents.year++;
                        }else{
                            dateComponents.month++;
                        };
                        refDate = [gregorian dateFromComponents:dateComponents];
                        if(refDate.timeIntervalSince1970>lastTimeInterval){
                            refDate = [NSDate dateWithTimeIntervalSince1970:lastTimeInterval];
                        };
                        
                        float w1, w2;
                        w1 = [self getRecordValueAtTimeInterval:curTimeInterval forKey:@"trend"];
                        w2 = [self getRecordValueAtTimeInterval:[refDate timeIntervalSince1970] forKey:@"trend"];
                        curDiff = (w2 - w1) / w1;
                        if(curDiff >= floatOut){
                            floatOut = curDiff;
                            strOut = [dateFormat2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:curTimeInterval]];
                        };
                        curTimeInterval = [refDate timeIntervalSince1970];
                    }while(curTimeInterval<lastTimeInterval);
                    [gregorian release];
                    
                };
                cell.label1.text = [NSString stringWithFormat:@"%@", strOut];
                cell.label2.text = [NSString stringWithFormat:@"%.1f %%", floatOut*100.0];
                break;

                
            default:
                break;
        };
        
        [dateFormat1 release];
        [dateFormat2 release];
    }
    
    return cell;
    
};



@end

