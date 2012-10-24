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
@synthesize ImortButton;
@synthesize selectButton;
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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(ImortButton.isHidden==YES){
        [ImortButton setHidden:NO];
        [selectButton setHidden:TRUE]; 
        [label setTextColor:[UIColor colorWithRed:235.0f/255.0f green:13.0f/255.0f blue:106.0f/255.0f alpha:1.0]];
        [selectButton setImage:[UIImage imageNamed:@"Icon_swipe_active@2x.png"] forState:UIControlStateNormal];
        [selectUserTarget selectCellToImport: [ImortButton tag]]; 
        
    }else {
        [label setTextColor:[UIColor colorWithRed:89.0f/255.0f green:93.0f/255.0f blue:99.0f/255.0f alpha:1.0]];
        [ImortButton setHidden:YES];
        [selectButton setHidden:NO];
        [selectButton setImage:[UIImage imageNamed:@"Icon_swipe_norm@2x.png"] forState:UIControlStateNormal];

        //[selectUserTarget selectCellToImport: [ImortButton tag]]; 
        
    }
}


- (IBAction)selectButtonClick:(id)sender {
    
    if(ImortButton.isHidden==YES){
        [ImortButton setHidden:NO];
        [selectButton setHidden:TRUE];
    }
    [selectUserTarget selectCellToImport: [sender tag]]; 
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
    [super dealloc];
}


@end
