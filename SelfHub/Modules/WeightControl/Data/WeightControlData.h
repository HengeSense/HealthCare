//
//  WeightControlData.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightControl.h"
#import "WeightControlAddRecordView.h"

@class WeightControl;
@class WeightControlAddRecordView;

@interface WeightControlData : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, WeightControlAddRecordProtocol>{
    WeightControlAddRecordView *detailView;
    NSIndexPath *deletedRow;
    NSUInteger editingRecordIndex;
};

@property (nonatomic, assign) WeightControl *delegate;
@property (nonatomic, retain) IBOutlet UITableView *dataTableView;
@property (nonatomic, retain) IBOutlet WeightControlAddRecordView *detailView;

- (IBAction)addDataRecord;
- (IBAction)pressEdit;

@end
