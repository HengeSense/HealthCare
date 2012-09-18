//
//  AdviceView.h
//  SelfHub
//
//  Created by Anton on 13.09.12.
//
//

#import <UIKit/UIKit.h>

#import "Advice.h"

@class adviceParse;
@interface AdviceView : UIView
{
    long m_id;
    
}

@property (retain, nonatomic) UIImageView *iview;
@property (retain, nonatomic) UILabel *title;
@property (retain, nonatomic) UIButton *button;
@property (retain, nonatomic) UITextView *description;
@property (retain, nonatomic) Advice *advice;

@end
