//
//  WeightControlChartSmoothLabel.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 07.11.12.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    WeightControlChartSmoothLabelColorGreen = 0,
    WeightControlChartSmoothLabelColorRed = 1,
    WeightControlChartSmoothLabelColorYellow = 2
} WeightControlChartSmoothLabelColor;

@interface WeightControlChartSmoothLabel : UILabel {
    WeightControlChartSmoothLabelColor backgroundColor;
    UIImage *backgroundImage;
}

- (id)initWithFrame:(CGRect)frame andBackgroundColor:(WeightControlChartSmoothLabelColor)newColor;

- (void)setColor:(WeightControlChartSmoothLabelColor)newColor;
- (WeightControlChartSmoothLabelColor)getColor;
@end
