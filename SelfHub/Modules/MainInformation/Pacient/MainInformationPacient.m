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

@synthesize delegate, scrollView;
@synthesize block1Label, photo, sexLabel, sexValueLabel, ageLabel, ageValueLabel, surname, name, patronymic;
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
    
    [scrollView setScrollEnabled:YES];
    [scrollView setFrame:self.view.bounds];
    [scrollView setContentSize:CGSizeMake(310, 780)];
    
    [self.view addSubview:scrollView];
    
    //NSLog(@"Pacient page was loaded!");
}

- (void)viewDidUnload{
    delegate = nil;
    scrollView = nil;
    block1Label = nil;
    photo = nil;
    sexLabel = nil;
    sexValueLabel = nil;
    ageLabel = nil;
    ageValueLabel = nil;
    surname = nil;
    name = nil;
    patronymic = nil;
    block2Label = nil;
    heightLabel = nil;
    heightValueLabel = nil;
    heightStepper = nil;
    weightLabel = nil;
    weightValueLabel = nil;
    weightStepper = nil;
    block3Label = nil;
    additionalInfo = nil;
}

- (void)dealloc{
    delegate = nil;
    [scrollView release];
    [block1Label release];
    [photo release];
    [sexLabel release];
    [sexValueLabel release];
    [ageLabel release];
    [ageValueLabel release];
    [surname release];
    [name release];
    [patronymic release];
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
    photo.image = (pacientPhoto==nil ? [UIImage imageNamed:@"voidPhoto.png"] : pacientPhoto);
    
    NSNumber *pacientSex = [[delegate moduleData] objectForKey:@"sex"];
    if(pacientSex==nil) pacientSex = [NSNumber numberWithInt:0];
    sexValueLabel.text = ([pacientSex intValue]==0 ? @"Male" : @"Female");
    
    NSDate *pacientBirthday = [[delegate moduleData] objectForKey:@"birthday"];
    if(pacientBirthday==nil){
        ageValueLabel.text = @"unknown";
    }else{
        ageValueLabel.text = [NSString stringWithFormat:@"%d", [delegate getAgeByBirthday:pacientBirthday]];
    };
    
    NSNumber *pacientHeight = [[delegate moduleData] objectForKey:@"height"];
    heightStepper.minimumValue = floor(MIN_HEIGHT_CM * [delegate getSizeFactor]) / [delegate getSizeFactor];
    heightStepper.maximumValue = floor(MAX_HEIGHT_CM * [delegate getSizeFactor]) / [delegate getSizeFactor];
    heightStepper.stepValue = 1.0 / [delegate getSizeFactor];
    if(heightStepper.stepValue > 10.0) heightStepper.stepValue /= 10.0;
    if(pacientHeight==nil){
        heightValueLabel.text = @"unknown";
    }else{
        heightValueLabel.text = [NSString stringWithFormat:@"%.0f %@", [pacientHeight floatValue]*[delegate getSizeFactor], [delegate getSizeUnit]];
        heightStepper.value = [pacientHeight doubleValue];
    };
    
    NSNumber *pacientWeight = [[delegate moduleData] objectForKey:@"weight"];
    weightStepper.minimumValue = floor(MIN_WEIGHT_KG * [delegate getWeightFactor]) / [delegate getWeightFactor];
    weightStepper.maximumValue = floor(MAX_WEIGHT_KG * [delegate getWeightFactor]) / [delegate getWeightFactor];
    weightStepper.stepValue = 1.0 / [delegate getWeightFactor];
    if(weightStepper.stepValue > 2.0) weightStepper.stepValue /= 2.0;
    if(pacientWeight==nil){
        weightValueLabel.text = @"unknown";
    }else{
        weightValueLabel.text = [NSString stringWithFormat:@"%.0f %@", [pacientWeight floatValue]*[delegate getWeightFactor], [delegate getWeightUnit]];
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
    
    NSString *pacientPatronymic = [[delegate moduleData] objectForKey:@"patronymic"];
    if(pacientPatronymic!=nil){
        patronymic.text = pacientPatronymic;
    };
    
    NSString *pacientInfo = [[delegate moduleData] objectForKey:@"info"];
    if(pacientInfo!=nil){
        additionalInfo.text = pacientInfo;
    };
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressSelectPhoto:(id)sender{
    [self hideKeyboard:additionalInfo];
    [self hideKeyboard:name];
    [self hideKeyboard:surname];
    [self hideKeyboard:patronymic];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select photo:", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", @""), NSLocalizedString(@"Library", @""), NSLocalizedString(@"Album", @""), nil];
    [actionSheet showInView:self.view];
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
    [self hideKeyboard:patronymic];
    
    myPicker.okSelector = @selector(sexWasSelected:);
    NSNumber *pacientSex = [[delegate moduleData] objectForKey:@"sex"];
    if(pacientSex==nil) pacientSex = [NSNumber numberWithInt:0];
    
    myPicker.myPicker.tag = MainInformationPacientPickerTypeSex;
    [myPicker setSimplePickerDelegate:self];
    [myPicker.myPicker selectRow:[pacientSex integerValue] inComponent:0 animated:YES];
    myPicker.pickerTitle.text = @"Sex";
    [myPicker showPickerInView:delegate.view];
};

- (IBAction)sexWasSelected:(MainInformationPickerSelector *)picker{
    NSInteger selectedSex = [picker.myPicker selectedRowInComponent:0];
    [delegate.moduleData setObject:[NSNumber numberWithInt:selectedSex] forKey:@"sex"];
    sexValueLabel.text = (selectedSex==0 ? @"Male" : @"Female");
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
    [self hideKeyboard:patronymic];
    myPicker.okSelector = @selector(birthdayWasSelected:);
    NSDate *pacientBirthday = [[delegate moduleData] objectForKey:@"birthday"];
    if(pacientBirthday==nil) pacientBirthday = [NSDate date];
    
    myPicker.pickerTitle.text = @"Your birthday";
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
    [self hideKeyboard:patronymic];
    
    myPicker.okSelector = @selector(heightWasSelected:);
    NSNumber *pacientHeight = [[delegate moduleData] objectForKey:@"height"];
    if(pacientHeight==nil) pacientHeight = [NSNumber numberWithFloat:170.0];
    
    myPicker.myPicker.tag = MainInformationPacientPickerTypeHeight;
    [myPicker setSimplePickerDelegate:self];
    [myPicker.myPicker selectRow:(NSInteger)(([pacientHeight floatValue]-heightStepper.minimumValue)/heightStepper.stepValue) inComponent:0 animated:YES];
    [myPicker.myPicker selectRow:[[delegate.moduleData objectForKey:@"sizeUnit"] intValue] inComponent:1 animated:YES];
    myPicker.pickerTitle.text = @"Height";
    [myPicker showPickerInView:delegate.view];
};

- (IBAction)heightWasSelected:(MainInformationPickerSelector *)picker{
    NSInteger selectedHeightRow = [picker.myPicker selectedRowInComponent:0];
    float selectedHeight = heightStepper.minimumValue + selectedHeightRow * heightStepper.stepValue;
    [delegate.moduleData setObject:[NSNumber numberWithFloat:selectedHeight] forKey:@"height"];
    heightValueLabel.text = [NSString stringWithFormat:@"%.0f %@", selectedHeight*[delegate getSizeFactor], [delegate getSizeUnit]];
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
    [self hideKeyboard:patronymic];
    
    myPicker.okSelector = @selector(weightWasSelected:);
    NSNumber *pacientWeight = [[delegate moduleData] objectForKey:@"weight"];
    if(pacientWeight==nil) pacientWeight = [NSNumber numberWithFloat:60.0];
    
    myPicker.myPicker.tag = MainInformationPacientPickerTypeWeight;
    [myPicker setSimplePickerDelegate:self];
    [myPicker.myPicker selectRow:(NSInteger)(([pacientWeight floatValue]-weightStepper.minimumValue)/weightStepper.stepValue) inComponent:0 animated:YES];
    [myPicker.myPicker selectRow:[[delegate.moduleData objectForKey:@"weightUnit"] intValue] inComponent:1 animated:YES];
    myPicker.pickerTitle.text = @"Weight";
    [myPicker showPickerInView:delegate.view];
};

- (IBAction)weightWasSelected:(MainInformationPickerSelector *)picker{
    NSInteger selectedWeightRow = [picker.myPicker selectedRowInComponent:0];
    float selectedWeight = weightStepper.minimumValue + selectedWeightRow * weightStepper.stepValue;
    [delegate.moduleData setObject:[NSNumber numberWithFloat:selectedWeight] forKey:@"weight"];
    weightValueLabel.text = [NSString stringWithFormat:@"%.0f %@", selectedWeight*[delegate getWeightFactor], [delegate getWeightUnit]];
    weightStepper.value = selectedWeight;
    [delegate saveModuleData];
};

- (IBAction)valueHeightStepped:(id)sender{
    [self hideKeyboard:additionalInfo];
    float curHeight = [(UIStepper *)sender value];
    heightValueLabel.text = [NSString stringWithFormat:@"%.0f %@", curHeight*[delegate getSizeFactor], [delegate getSizeUnit]];
    [delegate.moduleData setObject:[NSNumber numberWithFloat:curHeight] forKey:@"height"];
    [delegate saveModuleData];
}

- (IBAction)valueWeightStepped:(id)sender{
    [self hideKeyboard:additionalInfo];
    float curWeight = [(UIStepper *)sender value];
    weightValueLabel.text = [NSString stringWithFormat:@"%.0f %@", curWeight*[delegate getWeightFactor], [delegate getWeightUnit]];
    [delegate.moduleData setObject:[NSNumber numberWithFloat:curWeight] forKey:@"weight"];
    [delegate saveModuleData];
};

- (IBAction)textFieldDidBeginEditing:(id)sender{
    [self hideKeyboard:additionalInfo];
};

- (IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder];
};

- (IBAction)saveStrings:(id)sender{
    UITextField *myTextField = (UITextField *)sender;
    switch ([myTextField tag]) {
        case 0:
            [delegate.moduleData setObject:myTextField.text forKey:@"surname"];
            break;
        case 1:
            [delegate.moduleData setObject:myTextField.text forKey:@"name"];
            break;
        case 2:
            [delegate.moduleData setObject:myTextField.text forKey:@"patronymic"];
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
    [actionSheet release];
    
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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch(pickerView.tag){
        case MainInformationPacientPickerTypeSex:
            switch(row){
                case 0:
                    return @"Male";
                    break;
                case 1:
                    return @"Female";
                    break;
                    
                default:
                    return @"";
                    break;
            };
            break;
        case MainInformationPacientPickerTypeHeight:
            if(component==0){
                return [NSString stringWithFormat:@"%.1f", (heightStepper.minimumValue + heightStepper.stepValue * row)*[delegate getSizeFactor]];
            };
            if(component==1){
                MainInformationUnits *unitPage = [delegate.modulePagesArray objectAtIndex:1];
                return [unitPage getSizeUnitStr:row];
            }
            return @"";
            break;
        case MainInformationPacientPickerTypeWeight:
            if(component==0){
                return [NSString stringWithFormat:@"%.1f", (weightStepper.minimumValue + weightStepper.stepValue * row)*[delegate getWeightFactor]];
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
    switch(pickerView.tag){
        case MainInformationPacientPickerTypeSex:
            break;
        case MainInformationPacientPickerTypeHeight:
            if(component==1 && [[delegate.moduleData objectForKey:@"sizeUnit"] intValue]!=row){
                NSInteger selectedHeightRow = [pickerView selectedRowInComponent:0];
                float selectedHeight = heightStepper.minimumValue + selectedHeightRow * heightStepper.stepValue;
                
                [delegate.moduleData setObject:[NSNumber numberWithInt:row] forKey:@"sizeUnit"];
                heightStepper.minimumValue = ceil(MIN_HEIGHT_CM * [delegate getSizeFactor] * 10) / ([delegate getSizeFactor] *10);
                heightStepper.maximumValue = ceil(MAX_HEIGHT_CM * [delegate getSizeFactor]) / [delegate getSizeFactor];
                heightStepper.stepValue = 1.0 / [delegate getSizeFactor];
                if(heightStepper.stepValue > 10.0) heightStepper.stepValue /= 10.0;
                [pickerView reloadComponent:0];
                [pickerView selectRow:(NSInteger)((selectedHeight-heightStepper.minimumValue)/heightStepper.stepValue) inComponent:0 animated:YES];
            };
            break;
        case MainInformationPacientPickerTypeWeight:
            if(component==1 && [[delegate.moduleData objectForKey:@"weightUnit"] intValue]!=row){
                NSInteger selectedWeightRow = [pickerView selectedRowInComponent:0];
                float selectedWeight = weightStepper.minimumValue + selectedWeightRow * weightStepper.stepValue;
                
                [delegate.moduleData setObject:[NSNumber numberWithInt:row] forKey:@"weightUnit"];
                weightStepper.minimumValue = floor(MIN_WEIGHT_KG * [delegate getWeightFactor]) / [delegate getWeightFactor];
                weightStepper.maximumValue = floor(MAX_WEIGHT_KG * [delegate getWeightFactor]) / [delegate getWeightFactor];
                weightStepper.stepValue = 1.0 / [delegate getWeightFactor];
                if(weightStepper.stepValue > 2.0) weightStepper.stepValue /= 2.0;
                [pickerView reloadComponent:0];
                [pickerView selectRow:(NSInteger)((selectedWeight-weightStepper.minimumValue)/weightStepper.stepValue) inComponent:0 animated:YES];
            };
            break;
            
        default:
            break;
    };

};



#pragma mark -
#pragma mark UITextView delegate functions

- (void)textViewDidBeginEditing:(UITextView *)textView{
    CGRect rectToVis = textView.frame;
    rectToVis.origin.y += (self.view.frame.size.height / 2.0);
    [scrollView scrollRectToVisible:rectToVis animated:YES];
};

- (void)textViewDidEndEditing:(UITextView *)textView{
    [delegate.moduleData setObject:textView.text forKey:@"info"];
    [textView resignFirstResponder];
};



@end
