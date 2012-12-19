//
//  MainInformationUnits.m
//  SelfHub
//
//  Created by Mac on 16.11.12.
//
//

#import "MainInformationUnits.h"

@interface MainInformationUnits ()

@end

@implementation MainInformationUnits

@synthesize delegate, backgroundImageView;
@synthesize unitsLabel;
@synthesize weightLabel, weightValueLabel;
@synthesize sizeLabel, sizeValueLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([UIScreen mainScreen].bounds.size.height > 480.0){
        backgroundImageView.image = [UIImage imageNamed:@"profileModule_Background_retina4.png"];
    }else{
        backgroundImageView.image = [UIImage imageNamed:@"profileModule_Background.png"];
    };
    
    unitsLabel.text = @"Units";
    weightLabel.text = @"Weight";
    sizeLabel.text = @"Length";
}

- (void)viewWillAppear:(BOOL)animated{    
    NSNumber *weightUnit = [[delegate moduleData] objectForKey:@"weightUnit"];
    if(weightUnit==nil) weightUnit = [NSNumber numberWithInt:0];
    weightValueLabel.text = [self getWeightUnitStr:[weightUnit intValue]];
    
    NSNumber *sizeUnit = [[delegate moduleData] objectForKey:@"sizeUnit"];
    if(sizeUnit==nil) sizeUnit = [NSNumber numberWithInt:0];
    sizeValueLabel.text = [self getSizeUnitStr:[sizeUnit intValue]];
    
    [super viewWillAppear:animated];
}

- (void)dealloc{
    delegate = nil;
    [backgroundImageView release];
    [unitsLabel release];
    [weightLabel release];
    [weightValueLabel release];
    [sizeLabel release];
    [sizeValueLabel release];
    
    if(myPicker){
        [myPicker release];
    };
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeWeightUnits:(id)selector{
    if(myPicker){
        if([myPicker isSelectorInWork]) return;
        if([myPicker isDatePicker]==YES){
            [myPicker release];
            myPicker = nil;
        };
    };
    if(myPicker==nil){
        myPicker = [[MainInformationPickerSelector alloc] initSimplePickerWithDelegate:self andOkSelector:@selector(weightUnitWasSelected:) andCancelSelector:nil];
        [myPicker loadView];
    }
    
    myPicker.okSelector = @selector(weightUnitWasSelected:);
    NSNumber *weightUnit = [[delegate moduleData] objectForKey:@"weightUnit"];
    if(weightUnit==nil) weightUnit = [NSNumber numberWithInt:0];
    
    myPicker.myPicker.tag = MainInformationUnitsPickerTypeWeight;
    [myPicker setSimplePickerDelegate:self];
    [myPicker.myPicker selectRow:[weightUnit intValue] inComponent:0 animated:YES];
    myPicker.pickerTitle.text = @"Weight units";
    [myPicker showPickerInView:delegate.view];
};

- (IBAction)weightUnitWasSelected:(MainInformationPickerSelector *)picker{
    NSInteger selectedWeightUnitRow = [picker.myPicker selectedRowInComponent:0];
    [delegate.moduleData setObject:[NSNumber numberWithInt:selectedWeightUnitRow] forKey:@"weightUnit"];
    weightValueLabel.text = [self getWeightUnitStr:selectedWeightUnitRow];
    [delegate saveModuleData];
};

- (IBAction)changeSizeUnits:(id)selector{
    if(myPicker){
        if([myPicker isSelectorInWork]) return;
        if([myPicker isDatePicker]==YES){
            [myPicker release];
            myPicker = nil;
        };
    };
    if(myPicker==nil){
        myPicker = [[MainInformationPickerSelector alloc] initSimplePickerWithDelegate:self andOkSelector:@selector(sizeUnitWasSelected:) andCancelSelector:nil];
        [myPicker loadView];
    }
    
    myPicker.okSelector = @selector(sizeUnitWasSelected:);
    NSNumber *sizeUnit = [[delegate moduleData] objectForKey:@"sizeUnit"];
    if(sizeUnit==nil) sizeUnit = [NSNumber numberWithInt:0];
    
    myPicker.myPicker.tag = MainInformationUnitsPickerTypeSize;
    [myPicker setSimplePickerDelegate:self];
    [myPicker.myPicker selectRow:[sizeUnit intValue] inComponent:0 animated:YES];
    myPicker.pickerTitle.text = @"Size units";
    [myPicker showPickerInView:delegate.view];
};

- (IBAction)sizeUnitWasSelected:(MainInformationPickerSelector *)picker{
    NSInteger selectedSizeUnitRow = [picker.myPicker selectedRowInComponent:0];
    [delegate.moduleData setObject:[NSNumber numberWithFloat:selectedSizeUnitRow] forKey:@"sizeUnit"];
    sizeValueLabel.text = [self getSizeUnitStr:selectedSizeUnitRow];
    [delegate saveModuleData];
};

#pragma mark - units database

- (NSUInteger)getWeightUnitNum{
    return 2;
};

- (NSString *)getWeightUnitStr:(NSUInteger)weightUnitIndex{
    switch(weightUnitIndex){
        case 0:
            return @"kg";
            break;
        case 1:
            return @"lb";
            break;
        default:
            return @"";
            break;
    };
};

- (float)getWeightUnitKoef:(NSUInteger)weightUnitIndex{
    switch(weightUnitIndex){
        case 0:
            return 1.0;
            break;
        case 1:
            return 2.204622621848;
            break;
        default:
            return 0.0;
            break;
    };
};

- (float)getWeightUnitPickerStep:(NSUInteger)sizeUnitIndex{
    switch(sizeUnitIndex){
        case 0:
            return 0.1; //step 0.1 kg
            break;
        case 1:
            return 0.2 / [self getWeightUnitKoef:sizeUnitIndex];    //step 0.2 lb
            break;
        default:
            return 0.0;
            break;
    };
};

- (NSUInteger)getSizeUnitNum{
    return 2;
};

- (NSString *)getSizeUnitStr:(NSUInteger)sizeUnitIndex{
    switch(sizeUnitIndex){
        case 0:
            return @"cm";
            break;
        case 1:
            return @"ft";
            break;
        default:
            return @"";
            break;
    };
};

- (float)getSizeUnitKoef:(NSUInteger)sizeUnitIndex{
    switch(sizeUnitIndex){
        case 0:
            return 1.0;
            break;
        case 1:
            return 0.0328;
            break;
        default:
            return 0.0;
            break;
    };
};

- (float)getSizeUnitPickerStep:(NSUInteger)sizeUnitIndex{
    switch(sizeUnitIndex){
        case 0:
            return 1.0;     // step 1 cm
            break;
        case 1:
            return 2.54;    // step 1''
            break;
        default:
            return 0.0;
            break;
    };
};

#pragma mark -
#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch(pickerView.tag){
        case MainInformationUnitsPickerTypeWeight:
            return 1;
            break;
        case MainInformationUnitsPickerTypeSize:
            return 1;
            break;
        default:
            return 0;
            break;
    };
};

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch(pickerView.tag){
        case MainInformationUnitsPickerTypeWeight:
            return [self getWeightUnitNum];
            break;
        case MainInformationUnitsPickerTypeSize:
            return [self getSizeUnitNum];
            break;
        default:
            return 0;
            break;
    };
    
};

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch(pickerView.tag){
        case MainInformationUnitsPickerTypeWeight:
            return [self getWeightUnitStr:row];
            break;
        case MainInformationUnitsPickerTypeSize:
            return [self getSizeUnitStr:row];
            break;
            
        default:
            return @"";
            break;
    };
    
};


@end
