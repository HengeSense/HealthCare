//
//  AdviceView.h
//  SelfHub
//
//  Created by Anton on 13.09.12.
//
//

#import <UIKit/UIKit.h>

#import "Advice.h"
#import "AllAdvicesView.h"

@class adviceParse;
@class AllAdvicesView;

@interface AdviceView : UIView
{
    long m_id;
    
}

@property (retain, nonatomic) UIImageView *iview;
@property (retain, nonatomic) UILabel *title;
@property (retain, nonatomic) UIButton *button;
@property (retain, nonatomic) UIButton *starButton;
@property (retain, nonatomic) UIButton *sendButton;
@property (retain, nonatomic) UITextView *description;
@property (retain, nonatomic) Advice *advice;
@property (retain, nonatomic) UIActivityIndicatorView *loading;
@property (assign) AllAdvicesView *delegate;

- (void) startLoadingAnimation;
- (IBAction)addToFavorites:(id)sender;
@end
