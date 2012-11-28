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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    self.startPosition = [touch locationInView:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
   
    UITouch *touch = [touches anyObject];
    
	CGPoint currentPosition = [touch locationInView:self];
    if (self.startPosition.x < currentPosition.x) {
        [selectUserTarget moveButHide:gestureViewhide.tag];
    }        
}

- (IBAction)moveSelectButTap:(id)sender {
        [selectUserTarget selectCellToImport: [sender tag]];        
        CGSize viewSize = gestureView.bounds.size;
        UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
        [gestureView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIGraphicsEndImageContext();
        [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [gestureView setFrame:CGRectMake([gestureView frame].origin.x, [gestureView frame].origin.y, 0, [gestureView frame].size.height)];
        }completion:^(BOOL finished){            
        }];
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
