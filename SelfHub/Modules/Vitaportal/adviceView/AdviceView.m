//
//  AdviceView.m
//  SelfHub
//
//  Created by Anton on 13.09.12.
//
//

#import "AdviceView.h"
#import <QuartzCore/QuartzCore.h>

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@implementation AdviceView

@synthesize button;
@synthesize title;
@synthesize description;
@synthesize iview;
@synthesize advice;
@synthesize starButton,usefulButton;
@synthesize sendButton;
@synthesize delegate, loading;
@synthesize m_id;//id новости
@synthesize usefulButonHide;
@synthesize AdviceViewScroll;

- (id)initWithFrame:(CGRect)frame user_string: (NSString*) str
{
    self = [super initWithFrame:frame];
    if (self)
    {
      //  NSLog(@"init");
        if(str.length > 0){
            self.usefulButonHide = NO;
        }else{
            self.usefulButonHide = YES;
        }

    }
    return self;
}

- (void)dealloc
{
    self.button = nil;
    self.iview = nil;
    self.title = nil;
    self.description = nil;
    self.advice = nil;
    self.loading = nil;
    self.sendButton = nil;
    self.starButton = nil;
    self.delegate = nil;
    self.m_id = nil;
    self.usefulButton = nil;
    self.AdviceViewScroll = nil;

    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    int shift = 0;
    
    int HightScrool = 0;//высота скрола, постепенно расчитываем и
    
    
    self.AdviceViewScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
   
    
    [self addSubview:self.AdviceViewScroll];
    
    self.m_id = advice.m_id; // id новости

    if(advice.imageURLString != nil)
    {
        shift = self.frame.size.height * 3 / 7;

        self.iview = [[UIImageView alloc]
                      initWithFrame:CGRectMake(0, 0, self.frame.size.width, shift)];

        if(advice.image != nil)
        {
            self.iview.image = advice.image;
        }
        [self.AdviceViewScroll addSubview:self.iview];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake( 0, shift - 3,self.frame.size.width, 10)];
        [line setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:109.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        
        [self.AdviceViewScroll addSubview: line];
    
       
        HightScrool = HightScrool + shift ;
       
    }else{
        HightScrool = HightScrool + 30 ; // + отступ у title от верхнего края
    }
    
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(30, 20 + shift, self.frame.size.width - 60, 30)];
    self.title.text = advice.title;
    self.title.textColor = [UIColor colorWithRed:10.0f/255.0f green:71.0f/255.0f blue:120.0f/255.0f alpha:1.0f];
    self.title.adjustsFontSizeToFitWidth = YES;
    //self.title.backgroundColor = [UIColor blackColor];
    self.title.font = [UIFont boldSystemFontOfSize:24.0];
    
  
    HightScrool = HightScrool + [AdviceView getHightOfText:advice.title width: self.frame.size.width - 60 Font:self.title.font];
      //NSLog(@"заголовок HightScrool = %d", HightScrool);
    
    [self.AdviceViewScroll addSubview:self.title];
  
    self.description = [[UITextView alloc] initWithFrame:CGRectMake(20, 50 + shift, self.frame.size.width - 30, 600 - shift)];
    self.description.text = advice.description;
    //self.description.textColor = [UIColor whiteColor];
    //self.description.backgroundColor = [UIColor blackColor];
    self.description.font = [UIFont systemFontOfSize:18];
    self.description.editable = NO;
    self.description.userInteractionEnabled = NO;
    [self.AdviceViewScroll addSubview:self.description];
    
    HightScrool = HightScrool + [AdviceView getHightOfText:advice.description width: self.frame.size.width - 30 Font:self.description.font];
    [ self.description setFrame:CGRectMake(20, 50 + shift, self.frame.size.width - 30, HightScrool) ];
    
    [self.AdviceViewScroll addSubview:self.title];
    
    HightScrool = HightScrool + 30;
    
    starButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    starButton.frame =  CGRectMake(self.frame.size.width - 70, HightScrool, 30 , 30);
    [starButton setTitle:@"Fav" forState:UIControlStateNormal];
    [starButton addTarget:self action:@selector(addToFavorites:) forControlEvents:UIControlEventTouchUpInside];
    [self.AdviceViewScroll addSubview:self.starButton];
    
    sendButton  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame = CGRectMake(self.frame.size.width - 120, HightScrool, 30, 30);
    [sendButton setTitle:@"A" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(openShareView:) forControlEvents:UIControlEventTouchUpInside];
    [self.AdviceViewScroll addSubview:self.sendButton];
    
    
    usefulButton = [UIButton buttonWithType:UIButtonTypeRoundedRect]; //кнопка отправки "полезный"
    usefulButton.frame = CGRectMake( 30, HightScrool, 30, 30);
    [usefulButton setTitle:@"Use" forState:UIControlStateNormal];
    [usefulButton addTarget:self action:@selector(sendUsefulMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    HightScrool = HightScrool + self.usefulButton.frame.size.height + 10;
    
    self.usefulButton.hidden = self.usefulButonHide; //так надо все ок
       
    [self.AdviceViewScroll addSubview:self.usefulButton];
    
     NSLog(@"Результат HightScrool = %d", HightScrool);
     NSLog(@"__________________");
     [self.AdviceViewScroll setContentSize:CGSizeMake(self.frame.size.width,HightScrool)];
    
    //Number label//
//    UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(20, shift + self.description.frame.size.height+ 10, 60, 60)];
//    number.backgroundColor = [UIColor blackColor];
//    number.text = [NSString stringWithFormat:@"%i",self.tag];
//    number.font = [UIFont boldSystemFontOfSize:50];
//    number.textColor = [UIColor whiteColor];
//    [self addSubview:number];
//    [number release];
    
    
}

+ (int)getHightOfText:(NSString*) cellText width: (int) minW Font: ( UIFont *) font // Функция возвращает высоту текста, задаем сам текст, шрифт размер, и ширину ячейки возврящает высоту текста (int)
{
   
    CGSize constraintSize = CGSizeMake(minW, MAXFLOAT); // MAXFLOAT как вариант можно поменять на другое максимальую высоту
    
    CGSize labelSize = [cellText sizeWithFont:font
                            constrainedToSize:constraintSize
                                lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height;
}
- (void)startLoadingAnimation
{
    self.loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.loading setColor:[UIColor colorWithRed:0.0f/255.0f green:109.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
    [self.loading setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 6)];
    [self addSubview:self.loading];
    [self.loading startAnimating];
}


- (IBAction)addToFavorites:(id)sender
{
    [delegate addToFavoritesArray:self];
}
-(IBAction)sendUsefulMessage:(id)sender{
     NSLog(@"клик 'Полезный'");
    [delegate sendToVitaportalUsefulMessage: self.m_id ];
};

- (IBAction)openShareView:(id)sender
{
   // NSLog(@"клик шара");
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:NULL delegate:self cancelButtonTitle:@"Отмена"destructiveButtonTitle:NULL otherButtonTitles:@"Facebook",@"Twiter",@"Вконтакте",nil];
    actSheet.tag = 1;
    [actSheet showInView:self ];
    [actSheet release];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 1) {
        NSLog(@"%@ (Кнопка по индексу %d)",[actionSheet buttonTitleAtIndex:buttonIndex],buttonIndex);
    
        
       if(buttonIndex == 0 ){
            //FaceBook
           //http://www.facebook.com/sharer/sharer.php?u=http://lenta.ru/news/2012/11/12/disqualify/
           NSString *str = [[NSString stringWithFormat:@"http://www.facebook.com/sharer/sharer.php?u=http://vitaportal.ru/services/iphone/advices?advice_id=%@", self.m_id ]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
           
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: str ]];
           
       }else if (buttonIndex == 1){
           //Twiter // http://twitter.com/intent/tweet?text=
           
           NSString *str = [[NSString stringWithFormat:@"http://twitter.com/intent/tweet?url=http://vitaportal.ru/services/iphone/advices?advice_id=%@", self.m_id ]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        

           [[UIApplication sharedApplication] openURL:[NSURL URLWithString: str ]];
           
       }else if (buttonIndex == 2){
           //Вконтакте
          /* http://vkontakte.ru/share.php?url
           url	Ссылка на страницу, которая будет публиковаться.
           title	Заголовок публикации. Если не указан, то будет браться со страницы публикации (см. Используемая информация).
           description	Описание публикации. Если не указано, то будет браться со страницы публикации (см. Используемая информация).
           image	Ссылка на иллюстрацию к публикации. Если не указана, то будет браться со страницы публикации (см. Используемая информация).
           noparse	Если значение true, то сервер ВКонтакте не будет делать дополнительный запрос для загрузки недостающей информации с публикуемой страницы (см. Используемая информация). Если же значение false, то запрос будет отправляться всегда.
           */
           NSString *url =[NSString stringWithFormat:@"http://vitaportal.ru/services/iphone/advices?advice_id=%@", self.m_id ];
           
           NSString *str = [[NSString stringWithFormat:@"http://vkontakte.ru/share.php?url=%@title=VitaPortal&description=%@\n%@",url,self.title.text,  self.description.text]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
           NSLog(@"%@",str);
           
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString: str ]];           
       }
        
    } else {
        //Если это другой UIActionSheet
    }
}

@end

