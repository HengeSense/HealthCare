//
//  CustomCell.m
//  SelfHub
//
//  Created by Anton on 08.10.12.
//
//

#import "WithingsCustomCell.h"
#import <QuartzCore/QuartzCore.h>

#define kMinimumGestureLength 25

@implementation WithingsCustomCell

@synthesize gestureView;
@synthesize gestureViewhide;
@synthesize label;
@synthesize inf;
@synthesize ImortButton;
@synthesize selectButton;
@synthesize selectUserTarget; 
@synthesize startPosition, endPosition;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
           
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (IBAction)importButtonClick:(id)sender {
    [selectUserTarget clickCellImportButton:[sender tag]];
}
  

- (void)dealloc
{
    
    [inf dealloc];
    [label release];
    [ImortButton release];
    [selectButton release];
    [gestureView release];
    [gestureViewhide release];
    [super dealloc];
}


@end
