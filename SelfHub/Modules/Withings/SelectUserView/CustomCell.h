//
//  CustomCell.h
//  SelfHub
//
//  Created by Anton on 08.10.12.
//
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell{
     UILabel *name;
}
@property (retain, nonatomic) IBOutlet UILabel *label;
//@property (nonatomic, retain) IBOutlet UILabel *name;
@end
