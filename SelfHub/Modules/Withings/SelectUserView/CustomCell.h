//
//  CustomCell.h
//  SelfHub
//
//  Created by Anton on 08.10.12.
//
//

#import <UIKit/UIKit.h>
#import "WBSAPIUser.h"

@interface CustomCell : UITableViewCell{
     UILabel *label;
    WBSAPIUser *inf;
}
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (readwrite, nonatomic) 	WBSAPIUser *inf;
@end
