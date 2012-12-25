//
//  ImportWeight.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 13.11.12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "ModuleHelper.h"
#import "ImportWeightFromITunes.h"
#import "ModuleTableCell.h"

typedef enum {
	ImportFileTypeUnknown = 0,
    ImportFileTypeLibra2 = 1
} ImportFileType;


@protocol ModuleProtocol;

@interface ImportWeight : UIViewController <ModuleProtocol>{
    NSIndexPath *lastSelectedIndexPath;
    
    UIImage *tutorialBackgroundImage1;
}

@property (nonatomic, assign) id <ServerProtocol> delegate;
@property (nonatomic, retain) NSMutableArray *modulePagesArray;

@property (nonatomic, retain) IBOutlet UITableView *rightSlideBarTable;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIView *hostView;
@property (nonatomic, retain) IBOutlet UIView *moduleView;
@property (nonatomic, retain) IBOutlet UIView *slidingMenu;
@property (nonatomic, retain) IBOutlet UIImageView *slidingImageView;

@property (nonatomic, retain) UIButton *tutorialButton;

- (NSInteger)numOfRecordsFromFileAsCVS:(NSString *)filePath;
- (NSArray *)recordsFromFileAsCVS:(NSString *)filePath;

- (void)addRecordsToBase:(NSArray *)newRecords;
- (void)clearBaseAndAddRecords:(NSArray *)newRecords;

- (IBAction)showTutorial:(id)sender;

@end
