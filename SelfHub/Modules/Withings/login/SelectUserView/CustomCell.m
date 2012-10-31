//
//  CustomCell.m
//  SelfHub
//
//  Created by Anton on 08.10.12.
//
//

#import "CustomCell.h"
#import <QuartzCore/QuartzCore.h>

#define kMinimumGestureLength 25

@implementation CustomCell

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
	if (self.startPosition.x - currentPosition.x > 30) {
		NSLog(@"LEft swipe"); 
        [self performSelector:@selector(touchSelectBut:) withObject:nil afterDelay:2];
    }
    else if (self.startPosition.x < currentPosition.x) {
        NSLog(@"Right swipe"); 
        [self performSelector:@selector(touchImportBut:) withObject:nil afterDelay:2];
    }else if (self.startPosition.x == currentPosition.x){
        NSLog(@"Ravno"); 
        [selectUserTarget selectCellToImport: [ImortButton tag]]; 
    }        
//    if(ImortButton.isHidden==YES){
//        [ImortButton setHidden:NO];
//        [selectButton setHidden:TRUE]; 
//        [label setTextColor:[UIColor colorWithRed:235.0f/255.0f green:13.0f/255.0f blue:106.0f/255.0f alpha:1.0]];
//        [selectButton setImage:[UIImage imageNamed:@"Icon_swipe_active@2x.png"] forState:UIControlStateNormal];
//        [selectUserTarget selectCellToImport: [ImortButton tag]]; 
//        
//    }else {
//        [label setTextColor:[UIColor colorWithRed:89.0f/255.0f green:93.0f/255.0f blue:99.0f/255.0f alpha:1.0]];
//        [ImortButton setHidden:YES];
//        [selectButton setHidden:NO];
//        [selectButton setImage:[UIImage imageNamed:@"Icon_swipe_norm@2x.png"] forState:UIControlStateNormal];
//
      
//        
//    }
}


- (IBAction)importButtonClick:(id)sender {
    [selectUserTarget clickCellImportButton:[sender tag]];
}

- (IBAction)touchSelectBut:(id)sender {
    //if (self.startPosition.x > self.endPosition.x) {
        NSLog(@"Left swipe Touch");
        if(ImortButton.isHidden==YES){
            [ImortButton setHidden:NO];
            [selectButton setHidden:TRUE]; 
            [label setTextColor:[UIColor colorWithRed:235.0f/255.0f green:13.0f/255.0f blue:106.0f/255.0f alpha:1.0]];
            [selectButton setImage:[UIImage imageNamed:@"Icon_swipe_active@2x.png"] forState:UIControlStateNormal];
            [selectUserTarget selectCellToImport: [ImortButton tag]]; 
        }
//    } else if (self.startPosition.x < self.endPosition.x){
//        NSLog(@"Right swipe Touch");  
//    }
   // self.startPosition = CGPointMake(0, 0);
   // self.endPosition = CGPointMake(0, 0);
    

}

- (IBAction)touchImportBut:(id)sender {
//    if (self.startPosition.x < self.endPosition.x){
//        NSLog(@"Right swipe");
        if(ImortButton.isHidden==NO){ 
            [label setTextColor:[UIColor colorWithRed:89.0f/255.0f green:93.0f/255.0f blue:99.0f/255.0f alpha:1.0]];
            [ImortButton setHidden:YES];
            [selectButton setHidden:NO];
            [selectButton setImage:[UIImage imageNamed:@"Icon_swipe_norm@2x.png"] forState:UIControlStateNormal];
            
            //[selectUserTarget selectCellToImport: [ImortButton tag]]; 
            
        }
 //   }
   // self.startPosition = CGPointMake(0, 0);
   // self.endPosition = CGPointMake(0, 0);
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
