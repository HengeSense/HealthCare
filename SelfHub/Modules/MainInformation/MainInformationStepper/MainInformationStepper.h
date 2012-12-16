//
//  MainInformationStepper.h
//  HealthCare
//
//  Created by Eugine Korobovsky on 15.12.12.
//
//

#import <UIKit/UIKit.h>

@interface MainInformationStepper : UIView {
    NSTimeInterval startClock;
    float secsBetweenRepeat;
    BOOL isRepeatMode;
    
    NSTimer *repeatTimer;
    
    id delegate;
    SEL valueChangeSelector;
}

@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float stepValue;
@property (nonatomic) float value;

- (void)addTargetForValueChangedEnvent:(id)obj withSelector:(SEL)selector;

- (void)decrementValue;
- (void)incrementValue;

- (IBAction)onTouchDecrementButton:(id)sender;
- (IBAction)onUntouchDecrementButton:(id)sender;

- (IBAction)onTouchIncrementButton:(id)sender;
- (IBAction)onUntouchIncrementButton:(id)sender;

- (void)timerFuncDecrement:(NSTimer *)theTimer;


@end
