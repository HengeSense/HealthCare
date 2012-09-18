//
//  AdviceView.m
//  SelfHub
//
//  Created by Anton on 13.09.12.
//
//

#import "AdviceView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AdviceView

@synthesize button;
@synthesize title;
@synthesize description;
@synthesize iview;
@synthesize advice;

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
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"DRaw rect");
    int shift = 0;
    
    if(advice.imageURLString != nil)
    {
        shift = self.frame.size.height / 3;

        self.iview = [[UIImageView alloc]
                      initWithFrame:CGRectMake(0, 0, self.frame.size.width, shift)];
        self.iview.backgroundColor = [UIColor lightGrayColor];

        //iview.layer.borderColor = [[UIColor colorWithRed:51.0f/255.0f green:102.0f/255.0f blue:153.0f/255.0f alpha:1.0f] CGColor];
        //iview.layer.borderWidth = 4.0;
        //iview.layer.cornerRadius = 10.0;
        
        if(advice.image != nil)
        {
            NSLog(@"inside");
            self.iview.image = advice.image;
        }
        [self addSubview:self.iview];
        
        CGContextRef context    = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:51.0f/255.0f green:102.0f/255.0f blue:153.0f/255.0f alpha:1.0f].CGColor);
        CGContextSetLineWidth(context, 8.0);
        CGContextMoveToPoint(context, 0 /*self.frame.origin.x*/, shift);
        CGContextAddLineToPoint(context, self.frame.size.width, shift);
        CGContextStrokePath(context);        
    }

    self.title = [[UILabel alloc] initWithFrame:CGRectMake(30, 20 + shift, self.frame.size.width - 60, 30)];
    self.title.text = advice.title;
    self.title.textColor = [UIColor colorWithRed:51.0f/255.0f green:102.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
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
        
}

@end

