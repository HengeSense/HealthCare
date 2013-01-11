//
//  MainInformationPacient.m
//  SelfHub
//
//  Created by Mac on 16.11.12.
//
//

#import "MainInformationPacient.h"

@interface MainInformationPacient ()

@end

@implementation MainInformationPacient

@synthesize delegate, scrollView, backgroundImageView;
@synthesize block1Label, photo, sexLabel, sexValueLabel, ageLabel, ageValueLabel, surname, name;
@synthesize block2Label, heightLabel, heightValueLabel, heightStepper, weightLabel, weightValueLabel, weightStepper;
@synthesize block3Label, additionalInfo;

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
    
    [scrollView setScrollEnabled:YES];
    [scrollView setFrame:self.view.bounds];
    [scrollView setContentSize:CGSizeMake(310, 600)];
    
    [weightStepper addTargetForValueChangedEnvent:self withSelector:@selector(valueWeightStepped:)];
    [heightStepper addTargetForValueChangedEnvent:self withSelector:@selector(valueHeightStepped:)];
    
    block1Label.text = NSLocalizedString(@"Personal data", @"");
    sexLabel.text = NSLocalizedString(@"Sex", @"");
    ageLabel.text = NSLocalizedString(@"Age", @"");
    name.placeholder = NSLocalizedString(@"First Name", @"");
    surname.placeholder = NSLocalizedString(@"Last Name", @"");
    block2Label.text = NSLocalizedString(@"Physique", @"");
    heightLabel.text = NSLocalizedString(@"Height", @"");
    weightLabel.text = NSLocalizedString(@"Weight", @"");
    block3Label.text = NSLocalizedString(@"Info", @"");
    
    
    [self.view addSubview:scrollView];
    
    //NSLog(@"Pacient page was loaded!");
}

- (void)dealloc{
    delegate = nil;
    [backgroundImageView release];
    [scrollView release];
    [block1Label release];
    [photo release];
    [sexLabel release];
    [sexValueLabel release];
    [ageLabel release];
    [ageValueLabel release];
    [surname release];
    [name release];
    [block2Label release];
    [heightLabel release];
    [heightValueLabel release];
    [heightStepper release];
    [weightLabel release];
    [weightValueLabel release];
    [weightStepper release];
    [block3Label release];
    [additionalInfo release];
    
    if(myPicker){
        [myPicker release];
    };

    
    [super dealloc];
};

- (void)viewWillAppear:(BOOL)animated{
    UIImage *pacientPhoto = [UIImage imageWithData:[delegate.moduleData objectForKey:@"photo"]];
    photo.image = (pacientPhoto==nil ? [UIImage imageNamed:@"profileModulePacient_voidPhoto.png"] : pacientPhoto);
    
    NSNumber *pacientSex = [[delegate moduleData] objectForKey:@"sex"];
    if(pacientSex==nil) pacientSex = [NSNumber numberWithInt:0];
    sexValueLabel.text = ([pacientSex intValue]==0 ? NSLocalizedString(@"Male", @"") : NSLocalizedString(@"Female", @""));
    
    NSDate *pacientBirthday = [[delegate moduleData] objectForKey:@"birthday"];
    if(pacientBirthday==nil){
        ageValueLabel.text = NSLocalizedString(@"unknown", @"");
    }else{
        ageValueLabel.text = [NSString stringWithFormat:@"%d", [delegate getAgeByBirthday:pacientBirthday]];
    };
    
    NSNumber *pacientHeight = [[delegate moduleData] objectForKey:@"height"];
    heightStepper.minimumValue = floor(MIN_HEIGHT_CM * [delegate getSizeFactor]) / [delegate getSizeFactor];
    heightStepper.maximumValue = floor(MAX_HEIGHT_CM * [delegate getSizeFactor]) / [delegate getSizeFactor];
    heightStepper.stepValue = [delegate getSizePickerStep];
    if(pacientHeight==nil){
        heightValueLabel.text = NSLocalizedString(@"unknown", @"");
    }else{
        heightValueLabel.text = [delegate getCurHeightStrForHeightInCm:[pacientHeight floatValue] withUnit:YES];
        heightStepper.value = [pacientHeight doubleValue];
    };
    
    NSNumber *pacientWeight = [[delegate moduleData] objectForKey:@"weight"];
    weightStepper.minimumValue = floor(MIN_WEIGHT_KG * [delegate getWeightFactor]) / [delegate getWeightFactor];
    weightStepper.maximumValue = floor(MAX_WEIGHT_KG * [delegate getWeightFactor]) / [delegate getWeightFactor];
    weightStepper.stepValue = [delegate getWeightPickerStep];
    if(pacientWeight==nil){
        weightValueLabel.text = NSLocalizedString(@"unknown", @"");
    }else{
        weightValueLabel.text = [delegate getCurWeightStrForWeightInKg:[pacientWeight floatValue] withUnit:YES];
        weightStepper.value = [pacientWeight doubleValue];
    };
    
    NSString *pacientSurname = [[delegate moduleData] objectForKey:@"surname"];
    if(pacientSurname!=nil){
        surname.text = pacientSurname;
    };
    
    NSString *pacientName = [[delegate moduleData] objectForKey:@"name"];
    if(pacientName!=nil){
        name.text = pacientName;
    };
    
    NSString *pacientInfo = [[delegate moduleData] objectForKey:@"info"];
    if(pacientInfo!=nil){
        additionalInfo.text = pacientInfo;
    };
    
    [self changeScrollFrameBeforeKeyboardDisappear];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)changeScrollFrameBeforeKeyboardAppear{
    CGRect newScrollViewRect = self.view.bounds;
    newScrollViewRect.size.height -= 216.0;
    [UIView animateWithDuration:0.4 animations:^(void){
        [scrollView setFrame:newScrollViewRect];
    }];
};

- (void)changeScrollFrameBeforeKeyboardDisappear{
    [UIView animateWithDuration:0.4 animations:^(void){
        [scrollView setFrame:self.view.bounds];
    }];
};


- (IBAction)pressSelectPhoto:(id)sender{
    [self hideKeyboard:additionalInfo];
    [self hideKeyboard:name];
    [self hideKeyboard:surname];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select photo:", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", @""), NSLocalizedString(@"Library", @""), NSLocalizedString(@"Album", @""), nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
};

- (IBAction)pressSelectSex:(id)sender{
    if(myPicker){
        if([myPicker isSelectorInWork]) return;
        if([myPicker isDatePicker]==YES){
            [myPicker release];
            myPicker = nil;
        };
    };
    if(myPicker==nil){
        myPicker = [[MainInformationPickerSelector alloc] initSimplePickerWithDelegate:self andOkSelector:@selector(sexWasSelected:) andCancelSelector:nil];
        [myPicker loadView];
    }
    
    [self hideKeyboard:additionalInfo];
    [self hideKeyboard:name];
    [self hideKeyboard:surname];
    
    myPicker.okSelector = @selector(sexWasSelected:);
    NSNumber *pacientSex = [[delegate moduleData] objectForKey:@"sex"];
    if(pacientSex==nil) pacientSex = [NSNumber numberWithInt:0];
    
    myPicker.myPicker.tag = MainInformationPacientPickerTypeSex;
    [myPicker setSimplePickerDelegate:self];
    [myPicker.myPicker selectRow:[pacientSex integerValue] inComponent:0 animated:YES];
    myPicker.pickerTitle.text = NSLocalizedString(@"Sex", @"");
    [myPicker showPickerInView:delegate.view];
};

- (IBAction)sexWasSelected:(MainInformationPickerSelector *)picker{
    NSInteger selectedSex = [picker.myPicker selectedRowInComponent:0];
    [delegate.moduleData setObject:[NSNumber numberWithInt:selectedSex] forKey:@"sex"];
    sexValueLabel.text = (selectedSex==0 ? NSLocalizedString(@"Male", @"") : NSLocalizedString(@"Female", @""));
    [delegate saveModuleData];
};

- (IBAction)pressSelectBirthday:(id)sender{
    if(myPicker){
        if([myPicker isSelectorInWork]) return;
        if([myPicker isDatePicker]==NO){
            [myPicker release];
            myPicker = nil;
        };
    };
    if(myPicker==nil){
        myPicker = [[MainInformationPickerSelector alloc] initDatePickerWithDelegate:self andOkSelector:@selector(birthdayWasSelected:) andCancelSelector:nil];
        [myPicker loadView];
    }
    
    [self hideKeyboard:additionalInfo];
    [self hideKeyboard:name];
    [self hideKeyboard:surname];
    myPicker.okSelector = @selector(birthdayWasSelected:);
    NSDate *pacientBirthday = [[delegate moduleData] objectForKey:@"birthday"];
    if(pacientBirthday==nil) pacientBirthday = [NSDate date];
    
    myPicker.pickerTitle.text = NSLocalizedString(@"Your birthday", @"");
    [myPicker setDateForDatePicker:pacientBirthday];
    [myPicker showPickerInView:delegate.view];
};

- (IBAction)birthdayWasSelected:(MainInformationPickerSelector *)picker{
    //NSLog(@"Birthday were changed to: %@", [picker getDateFromDatePicker]);
    [[delegate moduleData] setObject:[picker getDateFromDatePicker] forKey:@"birthday"];
    ageValueLabel.text = [NSString stringWithFormat:@"%d", [delegate getAgeByBirthday:[picker getDateFromDatePicker]]];
    [delegate saveModuleData];
};

- (IBAction)pressSelectHeight:(id)sender{
    if(myPicker){
        if([myPicker isSelectorInWork]) return;
        if([myPicker isDatePicker]==YES){
            [myPicker release];
            myPicker = nil;
        };
    };
    if(myPicker==nil){
        myPicker = [[MainInformationPickerSelector alloc] initSimplePickerWithDelegate:self andOkSelector:@selector(heightWasSelected:) andCancelSelector:nil];
        [myPicker loadView];
    }
    
    [self hideKeyboard:additionalInfo];
    [self hideKeyboard:name];
    [self hideKeyboard:surname];
    
    myPicker.okSelector = @selector(heightWasSelected:);
    NSNumber *pacientHeight = [[delegate moduleData] objectForKey:@"height"];
    if(pacientHeight==nil) pacientHeight = [NSNumber numberWithFloat:170.0];
    curSelectedHeightCm = [pacientHeight floatValue];
    
    myPicker.myPicker.tag = MainInformationPacientPickerTypeHeight;
    [myPicker setSimplePickerDelegate:self];
    NSInteger newSelectedRow = (NSInteger)[self roundFloat:(([pacientHeight floatValue]-heightStepper.minimumValue)/heightStepper.stepValue) forStep:1.0];
    [myPicker.myPicker selectRow:newSelectedRow inComponent:0 animated:YES];
    [myPicker.myPicker selectRow:[[delegate.moduleData objectForKey:@"sizeUnit"] intValue] inComponent:1 animated:YES];
    myPicker.pickerTitle.text = NSLocalizedString(@"Height", @"");
    [myPicker showPickerInView:delegate.view];
};

- (IBAction)heightWasSelected:(MainInformationPickerSelector *)picker{
    float selectedHeight = curSelectedHeightCm;
    [delegate.moduleData setObject:[NSNumber numberWithFloat:selectedHeight] forKey:@"height"];
    heightValueLabel.text = [delegate getCurHeightStrForHeightInCm:selectedHeight withUnit:YES];
    heightStepper.value = selectedHeight;
    [delegate saveModuleData];
};


- (IBAction)pressSelectWeight:(id)sender{
    if(myPicker){
        if([myPicker isSelectorInWork]) return;
        if([myPicker isDatePicker]==YES){
            [myPicker release];
            myPicker = nil;
        };
    };
    if(myPicker==nil){
        myPicker = [[MainInformationPickerSelector alloc] initSimplePickerWithDelegate:self andOkSelector:@selector(weightWasSelected:) andCancelSelector:nil];
        [myPicker loadView];
    }
    
    [self hideKeyboard:additionalInfo];
    [self hideKeyboard:name];
    [self hideKeyboard:surname];
    
    myPicker.okSelector = @selector(weightWasSelected:);
    NSNumber *pacientWeight = [[delegate moduleData] objectForKey:@"weight"];
    if(pacientWeight==nil) pacientWeight = [NSNumber numberWithFloat:60.0];
    curSelectedWeightKg = [pacientWeight floatValue];
    
    myPicker.myPicker.tag = MainInformationPacientPickerTypeWeight;
    [myPicker setSimplePickerDelegate:self];
    NSInteger newSelectedRow = (NSInteger)[self roundFloat:(([pacientWeight floatValue]-weightStepper.minimumValue)/weightStepper.stepValue) forStep:1.0];
    [myPicker.myPicker selectRow:newSelectedRow inComponent:0 animated:YES];
    [myPicker.myPicker selectRow:[[delegate.moduleData objectForKey:@"weightUnit"] intValue] inComponent:1 animated:YES];
    myPicker.pickerTitle.text = NSLocalizedString(@"Weight", @"");
    [myPicker showPickerInView:delegate.view];
};

- (IBAction)weightWasSelected:(MainInformationPickerSelector *)picker{
    float selectedWeight = curSelectedWeightKg;
    [delegate.moduleData setObject:[NSNumber numberWithFloat:selectedWeight] forKey:@"weight"];
    weightValueLabel.text = [delegate getCurWeightStrForWeightInKg:selectedWeight withUnit:YES];
    weightStepper.value = selectedWeight;
    [delegate saveModuleData];
};

- (IBAction)valueHeightStepped:(id)sender{
    [self hideKeyboard:additionalInfo];
    float curHeight = [(MainInformationStepper *)sender value];
    heightValueLabel.text = [delegate getCurHeightStrForHeightInCm:curHeight withUnit:YES];
    [delegate.moduleData setObject:[NSNumber numberWithFloat:curHeight] forKey:@"height"];
    [delegate saveModuleData];
}

- (IBAction)valueWeightStepped:(id)sender{
    [self hideKeyboard:additionalInfo];
    float curWeight = [(MainInformationStepper *)sender value];
    weightValueLabel.text = [delegate getCurWeightStrForWeightInKg:curWeight withUnit:YES];
    [delegate.moduleData setObject:[NSNumber numberWithFloat:curWeight] forKey:@"weight"];
    [delegate saveModuleData];
};

- (IBAction)textFieldDidBeginEditing:(id)sender{
    [self hideKeyboard:additionalInfo];
    [self changeScrollFrameBeforeKeyboardAppear];
};

- (IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder];
    [self changeScrollFrameBeforeKeyboardDisappear];
};

- (IBAction)saveStrings:(id)sender{
    UITextField *myTextField = (UITextField *)sender;
    myTextField.text = [myTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    switch ([myTextField tag]) {
        case 0:
            [delegate.moduleData setObject:myTextField.text forKey:@"surname"];
            break;
        case 1:
            [delegate.moduleData setObject:myTextField.text forKey:@"name"];
            break;
            
        default:
            break;
    }
    //NSLog(@"object saved: %@", myTextField.text);
    [delegate saveModuleData];
};




#pragma mark -
#pragma mark UIActionSheet delegate functions

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==3) return;
    
    UIImagePickerController *imagePick;
    imagePick = [[UIImagePickerController alloc] init];
    UIImagePickerControllerSourceType imagePickType;
    
    switch(buttonIndex){
        case 0:
            imagePickType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            imagePickType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            imagePickType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        default:
            imagePickType = UIImagePickerControllerSourceTypeCamera;
            break;
    };
    
    if(![UIImagePickerController isSourceTypeAvailable:imagePickType]){
        [imagePick release];
        return;
    };
    
    imagePick.sourceType = imagePickType;
    [imagePick setDelegate:self];
    imagePick.allowsEditing = YES;
    
    [self.delegate presentModalViewController:imagePick animated:YES];
    
};

#pragma mark -
#pragma mark UIImagePickerController delegate functions

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [self.delegate dismissModalViewControllerAnimated:YES];
    [picker release];
    
    photo.image = image;
    [delegate.moduleData setObject:UIImagePNGRepresentation(photo.image) forKey:@"photo"];
};

#pragma mark -
#pragma mark UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch(pickerView.tag){
        case MainInformationPacientPickerTypeSex:
            return 1;
            break;
        case MainInformationPacientPickerTypeHeight:
            return 2;
            break;
        case MainInformationPacientPickerTypeWeight:
            return 2;
            break;
            
        default:
            return 0;
            break;
    };
};

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch(pickerView.tag){
        case MainInformationPacientPickerTypeSex:
            return 2;
            break;
        case MainInformationPacientPickerTypeHeight:
            if(component==0) return (heightStepper.maximumValue-heightStepper.minimumValue)/heightStepper.stepValue;
            if(component==1){
                MainInformationUnits *unitPage = [delegate.modulePagesArray objectAtIndex:1];
                return [unitPage getSizeUnitNum];
            };
            return 0;
            break;
        case MainInformationPacientPickerTypeWeight:
            if(component==0) return (weightStepper.maximumValue-weightStepper.minimumValue)/weightStepper.stepValue;
            if(component==1){
                MainInformationUnits *unitPage = [delegate.modulePagesArray objectAtIndex:1];
                return [unitPage getWeightUnitNum];
            };
            return 0;
            break;
            
        default:
            return 0;
            break;
    };

};

- (float)roundFloat:(float)num forStep:(float)step{
    float a = floor(num/step);
    float b = num - a * step;
    if(b >= (step/2)) a++;
    
    return a*step;
};

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch(pickerView.tag){
        case MainInformationPacientPickerTypeSex:
            switch(row){
                case 0:
                    return NSLocalizedString(@"Male", @"");
                    break;
                case 1:
                    return NSLocalizedString(@"Female", @"");
                    break;
                    
                default:
                    return @"";
                    break;
            };
            break;
        case MainInformationPacientPickerTypeHeight:
            if(component==0){
                float curSizeValueCm = (heightStepper.minimumValue + heightStepper.stepValue * row);
                return [delegate getCurHeightStrForHeightInCm:curSizeValueCm withUnit:YES];
            };
            if(component==1){
                MainInformationUnits *unitPage = [delegate.modulePagesArray objectAtIndex:1];
                return [unitPage getSizeUnitStr:row];
            }
            return @"";
            break;
        case MainInformationPacientPickerTypeWeight:
            if(component==0){
                return [delegate getCurWeightStrForWeightInKg:(weightStepper.minimumValue + weightStepper.stepValue * row) withUnit:YES];
            };
            if(component==1){
                MainInformationUnits *unitPage = [delegate.modulePagesArray objectAtIndex:1];
                return [unitPage getWeightUnitStr:row];
            }
            return @"";
            break;
            
        default:
            return @"";
            break;
    };

};

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSInteger selectedFirsrComponentRow = [pickerView selectedRowInComponent:0];
    
    switch(pickerView.tag){
        case MainInformationPacientPickerTypeSex:
            break;
        case MainInformationPacientPickerTypeHeight:
            if(component==0){
                curSelectedHeightCm = heightStepper.minimumValue + selectedFirsrComponentRow * heightStepper.stepValue;
                //NSLog(@"Setting height: %.2f", curSelectedHeightCm);
            };
            if(component==1 && [[delegate.moduleData objectForKey:@"sizeUnit"] intValue]!=row){
                float selectedHeight = curSelectedHeightCm; //heightStepper.minimumValue + selectedHeightRow * heightStepper.stepValue;
                
                [delegate.moduleData setObject:[NSNumber numberWithInt:row] forKey:@"sizeUnit"];
                heightStepper.minimumValue = ceil(MIN_HEIGHT_CM * [delegate getSizeFactor] * 10) / ([delegate getSizeFactor] *10);
                heightStepper.maximumValue = ceil(MAX_HEIGHT_CM * [delegate getSizeFactor]) / [delegate getSizeFactor];
                heightStepper.stepValue = [delegate getSizePickerStep];
                [pickerView reloadComponent:0];
                NSInteger newSelectedRow = (NSInteger)[self roundFloat:((selectedHeight-heightStepper.minimumValue)/heightStepper.stepValue) forStep:1.0];
                [pickerView selectRow:newSelectedRow inComponent:0 animated:YES];
            };
            break;
        case MainInformationPacientPickerTypeWeight:
            if(component==0){
                curSelectedWeightKg = weightStepper.minimumValue + selectedFirsrComponentRow * weightStepper.stepValue;
            }
            if(component==1 && [[delegate.moduleData objectForKey:@"weightUnit"] intValue]!=row){
                //NSInteger selectedWeightRow = [pickerView selectedRowInComponent:0];
                float selectedWeight = curSelectedWeightKg; //weightStepper.minimumValue + selectedWeightRow * weightStepper.stepValue;
                
                [delegate.moduleData setObject:[NSNumber numberWithInt:row] forKey:@"weightUnit"];
                weightStepper.minimumValue = floor(MIN_WEIGHT_KG * [delegate getWeightFactor]) / [delegate getWeightFactor];
                weightStepper.maximumValue = floor(MAX_WEIGHT_KG * [delegate getWeightFactor]) / [delegate getWeightFactor];
                weightStepper.stepValue = [delegate getWeightPickerStep];
                //NSLog(@"stepValue = %.5f", [delegate getWeightPickerStep]);
                [pickerView reloadComponent:0];
                NSInteger newSelectedRow = (NSInteger)[self roundFloat:((selectedWeight-weightStepper.minimumValue)/weightStepper.stepValue) forStep:1.0];
                [pickerView selectRow:newSelectedRow inComponent:0 animated:YES];
            };
            break;
            
        default:
            break;
    };

};



#pragma mark -
#pragma mark UITextView delegate functions

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    };
    
    return YES;
};

- (void)textViewDidBeginEditing:(UITextView *)textView{
    //CGRect rectToVis = textView.frame;
    //rectToVis.origin.y += (self.view.frame.size.height / 2.0);
    //[scrollView scrollRectToVisible:rectToVis animated:YES];
    [self changeScrollFrameBeforeKeyboardAppear];
};

- (void)textViewDidEndEditing:(UITextView *)textView{
    [delegate.moduleData setObject:textView.text forKey:@"info"];
    [textView resignFirstResponder];
    
    [self changeScrollFrameBeforeKeyboardDisappear];
    
};



@end
