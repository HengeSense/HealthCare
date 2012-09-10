//
//  AllAdvicesView.h
//  SelfHub
//
//  Created by Igor Barinov on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "Vitaportal.h"

@class Vitaportal; 
@interface AllAdvicesView : UIViewController{
    
}

@property (nonatomic, assign) Vitaportal *delegate;
@property (retain, nonatomic) IBOutlet UIView *mainAdviceView;



@end
