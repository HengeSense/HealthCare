//
//  AdviceView.m
//  SelfHub
//
//  Created by Anton on 13.09.12.
//
//

#import "AdviceView.h"

@implementation AdviceView

@synthesize button;
@synthesize title;
@synthesize description;
@synthesize iview;
@synthesize advice;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        /*
        self.button = nil;
        self.title = nil;
        self.description = nil;
        self.iview = nil;
         */
        
    }
    return self;
}

- (void)dealloc
{
    self.button = nil;
    self.iview = nil;
    self.title = nil;
    self.description = nil;
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

-(void) insertInformation:(NSDictionary *)data
{
    //self.title.text = [data objectForKey:@"title"];
    //self.description.text = [data objectForKey:@"description"];
    //self.button.enabled = YES;
    
    if([[data objectForKey:@"image"] isEqualToString:@""])
    {
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, self.frame.size.width - 60, 30)];
        self.title.text = [data objectForKey:@"title"];
        self.title.textColor = [UIColor blueColor];
        //self.title.backgroundColor = [UIColor blackColor];
        self.title.font = [UIFont boldSystemFontOfSize:24.0];
        [self addSubview:self.title];
        self.description = [[UITextView alloc] initWithFrame:CGRectMake(20, 50, self.frame.size.width - 40, 300)];
        self.description.text = [data objectForKey:@"description"];
       // self.description.textColor = [UIColor whiteColor];
        //self.description.backgroundColor = [UIColor blackColor];
        self.description.font = [UIFont systemFontOfSize:18];
        self.description.editable = NO;
        self.description.userInteractionEnabled = NO;
        [self addSubview:self.description];
        
    }
    else
    {
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(30, 20 + self.frame.size.height/3, self.frame.size.width - 60, 30)];
        self.title.text = [data objectForKey:@"title"];
       // self.title.textColor = [UIColor whiteColor];
       // self.title.backgroundColor = [UIColor blackColor];
        self.title.font = [UIFont boldSystemFontOfSize:24.0];
        [self addSubview:self.title];
        
        self.description = [[UITextView alloc] initWithFrame:CGRectMake(20, 50 + self.frame.size.height/3, self.frame.size.width - 40, 180)];
        self.description.text = [data objectForKey:@"description"];
        //self.description.textColor = [UIColor whiteColor];
        //self.description.backgroundColor = [UIColor blackColor];
        self.description.font = [UIFont systemFontOfSize:18];
        self.description.editable = NO;
        self.description.userInteractionEnabled = NO;
        [self addSubview:self.description];
        

    }
}

@end

