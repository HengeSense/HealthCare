//
//  DesktopTableCell.m
//  HealthCare
//
//  Created by Eugine Korobovsky on 16.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModuleTableCell.h"

@implementation ModuleTableCell

@synthesize searchBar = _searchBar, backgroundImage = _backgroundImage, moduleName = _moduleName, moduleDescription = _moduleDescription, moduleIcon = _moduleIcon, moduleMessage = _moduleMessage;

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
    [_backgroundImage setHighlighted:selected];
    
    
}

- (void)dealloc
{
    [_searchBar release];
    [_backgroundImage release];
    [_moduleName release];
    [_moduleDescription release];
    [_moduleIcon release];
    [_moduleMessage release];
    
    [super dealloc];
}

@end
