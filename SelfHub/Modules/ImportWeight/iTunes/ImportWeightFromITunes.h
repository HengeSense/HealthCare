//
//  ImportWeightFromITunes.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 14.11.12.
//
//

#import <UIKit/UIKit.h>
#import "ImportWeight.h"

@class ImportWeight;

@interface ImportWeightFromITunes : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>{
    NSMutableArray *iTunesFiles;    //One record - NSMutableDictionary with keys: filename, filepath, filetype, recordsnum, records, description
    int currentlySelectedFileNum;
};

@property (nonatomic, assign) ImportWeight *delegate;
@property (nonatomic, retain) IBOutlet UITableView *filesTable;
@property (nonatomic, retain) IBOutlet UIImageView *tableBackgroundImage;

- (void)loadFilesFromItunes;

//- (IBAction)showSlidingMenu:(id)sender;
//- (IBAction)hideSlidingMenu:(id)sender;
//- (IBAction)selectScreenFromMenu:(id)sender;
//- (void)moveScreenshot:(UIPanGestureRecognizer *)gesture;
//- (void)tapScreenshot:(UITapGestureRecognizer *)gesture;

@end
