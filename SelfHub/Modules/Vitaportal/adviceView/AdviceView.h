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

@interface AdviceView : UIView <UIActionSheetDelegate>
{
    //long m_id;
}

- (id)initWithFrame:(CGRect)frame user_string: (NSString*) str;
//@property (retain, nonatomic) UIActionSheet *shareView;
@property (retain, nonatomic) UIScrollView *AdviceViewScroll;
@property (retain, nonatomic) UIImageView *iview;
@property (retain, nonatomic) UILabel *title;
@property (retain, nonatomic) UIButton *button;
@property (retain, nonatomic) UIButton *starButton;
@property (retain, nonatomic) UIButton *sendButton;
@property (retain, nonatomic) UIButton *usefulButton;
@property (retain, nonatomic) UITextView *description;
@property (retain, nonatomic) Advice *advice;
@property (retain, nonatomic) UIActivityIndicatorView *loading;
@property (assign) AllAdvicesView *delegate;
@property (assign) NSString *m_id;
@property (assign, nonatomic) BOOL *usefulButonHide;

- (void) startLoadingAnimation;
- (IBAction)sendUsefulMessage:(id)sender;
- (IBAction)addToFavorites:(id)sender;
- (IBAction)openShareView:(id)sender;
+ (int)getHightOfText:(NSString*) cellText width: (int) minW Font: ( UIFont *) font; // Функция возвращает высоту текста, задаем сам текст, шрифт размер, и ширину ячейки возврящает высоту текста (int)

@end
