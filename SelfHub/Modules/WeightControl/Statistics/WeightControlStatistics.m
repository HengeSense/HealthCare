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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
};
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Trends statistic";
            break;
        case 1:
            return @"Data base statistic";
            break;
            
        case 2:
            return @"Weight statistic";
            break;
            
        default:
            return @"";
            break;
    };
};

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
        
        switch ([indexPath row]) {
            case 0:
                cell.mainLabel.text = @"Last...";
                cell.label1.text = @"kg/week";
                cell.label2.text = @"kcal/day";
                break;
            case 1:
                cell.mainLabel.text = @"Week";
                cell.label1.text = @"xx.x";
                cell.label2.text = @"xx.x";
                break;
                
            case 2:
                cell.mainLabel.text = @"15 days";
                cell.label1.text = @"xx.x";
                cell.label2.text = @"xx.x";
                break;
                
            case 3:
                cell.mainLabel.text = @"Month";
                cell.label1.text = @"xx.x";
                cell.label2.text = @"xx.x";
                break;
                
            case 4:
                cell.mainLabel.text = @"3 month";
                cell.label1.text = @"xx.x";
                cell.label2.text = @"xx.x";
                break;
                
            case 5:
                cell.mainLabel.text = @"6 month";
                cell.label1.text = @"xx.x";
                cell.label2.text = @"xx.x";
                break;
                
            case 6:
                cell.mainLabel.text = @"Year";
                cell.label1.text = @"xx.x";
                cell.label2.text = @"xx.x";
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
                cell.label1.text = [NSString stringWithFormat:@"%.1f kg (%.1f %)", weightChangeKg, weightChangePercents];
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
                cell.label1.text = @"xx.x kg";
                cell.label2.text = @"dd MMMM YYYY";
                break;
                
            case 3:
                cell.mainLabel.text = @"Min trend";
                cell.label1.text = @"xx.x kg";
                cell.label2.text = @"dd MMMM YYYY";
                break;
                
            case 4:
                cell.mainLabel.text = @"Month with max weight-loss";
                cell.label1.text = @"MMMM YYYY";
                cell.label2.text = @"xx.x kg";
                break;
                
            case 5:
                cell.mainLabel.text = @"Month with max weight-gain";
                cell.label1.text = @"MMMM YYYY";
                cell.label2.text = @"xx.x kg";
                break;
                
            case 6:
                cell.mainLabel.text = @"Month with max weight-loss in percents";
                cell.label1.text = @"MMMM YYYY";
                cell.label2.text = @"xx.x %%";
                break;
                
            case 7:
                cell.mainLabel.text = @"Month with max weight-gain in percents";
                cell.label1.text = @"MMMM YYYY";
                cell.label2.text = @"xx.x %%";
                break;

                
            default:
                break;
        };
        
        [dateFormat1 release];
    }
    
    return cell;
    
};



@end
