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
@synthesize starButton;
@synthesize sendButton;
@synthesize delegate, loading;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {


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
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    //NSLog(@"DRaw rect");
    int shift = 0;

    if(advice.imageURLString != nil)
    {
        shift = self.frame.size.height / 3;

        self.iview = [[UIImageView alloc]
                      initWithFrame:CGRectMake(0, 0, self.frame.size.width, shift)];

        if(advice.image != nil)
        {
            self.iview.image = advice.image;
        }
        [self addSubview:self.iview];
        
        CGContextRef context    = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f/255.0f green:109.0f/255.0f blue:154.0f/255.0f alpha:1.0f].CGColor);
        CGContextSetLineWidth(context, 12.0);
        CGContextMoveToPoint(context, 0, shift);
        CGContextAddLineToPoint(context, self.frame.size.width, shift);
        CGContextStrokePath(context);        
    }

    self.title = [[UILabel alloc] initWithFrame:CGRectMake(30, 20 + shift, self.frame.size.width - 60, 30)];
    self.title.text = advice.title;
    self.title.textColor = [UIColor colorWithRed:10.0f/255.0f green:71.0f/255.0f blue:120.0f/255.0f alpha:1.0f];
    self.title.adjustsFontSizeToFitWidth = YES;
    //self.title.backgroundColor = [UIColor blackColor];
    self.title.font = [UIFont boldSystemFontOfSize:24.0];
    [self addSubview:self.title];
     
    
    self.description = [[UITextView alloc] initWithFrame:CGRectMake(20, 50 + shift, self.frame.size.width - 40, 300 - shift)];
    self.description.text = advice.description;
    //self.description.textColor = [UIColor whiteColor];
    //self.description.backgroundColor = [UIColor blackColor];
    self.description.font = [UIFont systemFontOfSize:18];
    self.description.editable = NO;
    self.description.userInteractionEnabled = NO;
    [self addSubview:self.description];
    
    starButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    starButton.frame =  CGRectMake(self.frame.size.width - 70, self.frame.size.height - 40, 30 , 30);
    [starButton setTitle:@"Fav" forState:UIControlStateNormal];
    [starButton addTarget:self action:@selector(addToFavorites:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.starButton];
    
    sendButton  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame = CGRectMake(self.frame.size.width - 120, self.frame.size.height - 40, 30, 30);
    [sendButton setTitle:@"A" forState:UIControlStateNormal];
    [self addSubview:self.sendButton];
    
    //Number label//
    UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(20, shift + self.description.frame.size.height+ 10, 60, 60)];
    number.backgroundColor = [UIColor blackColor];
    number.text = [NSString stringWithFormat:@"%i",self.tag];
    number.font = [UIFont boldSystemFontOfSize:50];
    number.textColor = [UIColor whiteColor];
    [self addSubview:number];
    [number release];
            
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


@end

