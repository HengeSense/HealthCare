//
//  CustomCell.m
//  SelfHub
//
//  Created by Anton on 08.10.12.
//
//

#import "CustomCell.h"

@implementation CustomCell

@synthesize label;
@synthesize inf;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
    [inf dealloc];// допилить
    [label release];
    [super dealloc];
}

@end
