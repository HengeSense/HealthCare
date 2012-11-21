//
//  WeightControlChartSmoothLabel.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 07.11.12.
//
//

#import "WeightControlChartSmoothLabel.h"

@implementation WeightControlChartSmoothLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundImage = nil;
        [self setColor:WeightControlChartSmoothLabelColorGreen];
    };
    
    return self;
};

- (id)initWithFrame:(CGRect)frame andBackgroundColor:(WeightControlChartSmoothLabelColor)newColor
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundImage = nil;
        [self setColor:newColor];
    };
    
    return self;
};

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        backgroundImage = nil;
        [self setColor:WeightControlChartSmoothLabelColorGreen];
    };
    
    return self;
};

- (void)dealloc{
    [backgroundImage release];
    
    [super dealloc];
}

- (void)setColor:(WeightControlChartSmoothLabelColor)newColor{
    NSString *imageFileName;
    switch (newColor) {
        case WeightControlChartSmoothLabelColorGreen:
            imageFileName = @"weightControlSmoothLabel_green.png";
            break;
        case WeightControlChartSmoothLabelColorRed:
            imageFileName = @"weightControlSmoothLabel_red.png";
            break;
        case WeightControlChartSmoothLabelColorYellow:
            imageFileName = @"weightControlSmoothLabel_yellow.png";
            break;
            
        default:
            imageFileName = nil;
            break;
    };
    
    if(imageFileName==nil) return;
    
    if(backgroundImage){
        [backgroundImage release];
        backgroundImage = nil;
    }
    backgroundImage = [[[UIImage imageNamed:imageFileName] stretchableImageWithLeftCapWidth:4 topCapHeight:4] retain];
    backgroundColor = newColor;
    
    CGSize textRealSize = [self.text sizeWithFont:self.font];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, textRealSize.width, textRealSize.height);
    [self setNeedsDisplay];
};

- (WeightControlChartSmoothLabelColor)getColor{
    return backgroundColor;
};

- (void)setText:(NSString *)text{
    [super setText:text];
    
    CGSize textRealSize = [self.text sizeWithFont:self.font];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, textRealSize.width, textRealSize.height);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [backgroundImage drawInRect:self.bounds];
    [self.text drawInRect:self.bounds withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
}




@end
