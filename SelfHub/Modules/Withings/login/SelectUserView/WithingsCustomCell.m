//
//  CustomCell.m
//  SelfHub
//
//  Created by ET on 08.10.12.
//
//

#import "WithingsCustomCell.h"


@implementation WithingsCustomCell


@synthesize label;
@synthesize inf;
@synthesize selectUserTarget; 


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


- (void)dealloc
{
    [inf release];
    [label release];
    [_puchLabel release];
    [_pushSwitch release];
    [super dealloc];
}


- (IBAction)pushSwitchStateChanged:(id)sender {
    if (_pushSwitch.on) {
        [selectUserTarget synchNotificationShouldOn:_pushSwitch];
    } else {
        [selectUserTarget synchNotificationShouldOff:_pushSwitch];
    }
}
@end
