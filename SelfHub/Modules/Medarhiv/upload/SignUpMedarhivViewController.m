//
//  SignUpMedarhivViewController.m
//  SelfHub
//
//  Created by Igor Barinov on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpMedarhivViewController.h"

@interface SignUpMedarhivViewController ()

@end

@implementation SignUpMedarhivViewController

@synthesize navBar;
@synthesize tableViewReg;
@synthesize activityReg;
@synthesize registrationLabel;
@synthesize birthdaySelectorView;
@synthesize birthdayPicker;
@synthesize doneBirthButton;
@synthesize cancelBirthButton, realBirthday;
@synthesize  delegate;
@synthesize scrollView, doneButton;


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
    
    UIView *springView  = [[UIView alloc] initWithFrame:CGRectMake(0, -2, 320, 13)];
    [scrollView addSubview:springView];
    UIImage *springImBig = [UIImage imageNamed:@"spring@2x.png"];
    UIImage *springIm = [[UIImage alloc] initWithCGImage:[springImBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    [springView setBackgroundColor:[UIColor colorWithPatternImage:springIm]];
    [springIm release];
    [springView release];
    
    UIImage *navBarBackgroundImageBig = [UIImage imageNamed:@"DesktopNavBarBackground@2x.png"];
    UIImage *navBarBackgroundImage = [[UIImage alloc] initWithCGImage:[navBarBackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    [self.navBar setBackgroundImage:navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [navBarBackgroundImage release];
    
    
    UIButton *slideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    slideButton.frame = CGRectMake(0.0, 0.0, 42.0, 32.0);
    [slideButton setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton.png"] forState:UIControlStateNormal];
    [slideButton setImage:[UIImage imageNamed:@"DesktopSlideRightNavBarButton_press.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:slideButton];
    self.navBar.topItem.rightBarButtonItem = rightBarButtonItem;
    rightBarButtonItem.enabled = false;
    [rightBarButtonItem release];
    
    UIButton *BackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    BackButton.frame = CGRectMake(0.0, 0.0, 62.0, 32.0);
    [BackButton setImage:[UIImage imageNamed:@"DesktopBackButton.png"] forState:UIControlStateNormal];
    [BackButton setImage:[UIImage imageNamed:@"DesktopBackButton_press.png"] forState:UIControlStateHighlighted];
    [BackButton addTarget:self action:@selector(BackButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:BackButton];
    self.navBar.topItem.leftBarButtonItem = leftBarButtonItem;
    [leftBarButtonItem release];
    
    [tableViewReg setFrame:CGRectMake(0, 60, 320, 410)];
    
    [scrollView setScrollEnabled:YES];
    [scrollView setFrame:CGRectMake(0, 0, 320, 515)];
    [scrollView setContentSize:CGSizeMake(320, 670)]; 
    
       
    registrationLabel.text = NSLocalizedString(@"Registration",@"");
    
    [doneButton setTitle:NSLocalizedString(@"Done",@"") forState:UIControlStateNormal];
    
    [self.view addSubview:scrollView];
    
    [tableViewReg scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    birthdaySelectorView.center = CGPointMake(160, 720);
    [self.view addSubview:birthdaySelectorView];
    
//    tableViewReg.delegate = self;
//    tableViewReg.dataSource = self;
    
}

- (void)viewDidUnload
{
    delegate = nil;
    scrollView = nil;
    [self setTableViewReg:nil];
    [self setActivityReg:nil];
    [self setNavBar:nil];
    [self setRegistrationLabel:nil];
    [self setBirthdaySelectorView:nil];
    [self setBirthdayPicker:nil];
    [self setDoneButton:nil];
    [self setCancelBirthButton:nil];
    [self setDoneBirthButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [tableViewReg reloadData];
};

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
};

- (IBAction)BackButtonAction {
    [self dismissModalViewControllerAnimated:true];
}

- (IBAction)doneButtonClick:(id)sender {
    birthdaySelectorView.center = CGPointMake(160, 240);
    [UIView animateWithDuration:0.4f animations:^{
        birthdaySelectorView.center = CGPointMake(160, 720);
    }];
    
    if([(UIButton *)sender tag]==1){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
        
        UILabel *birthdayField = (UILabel*)[self.view viewWithTag:7];
        //birthdayField.text = [NSString stringWithFormat:[dateFormatter stringFromDate:birthdayPicker.date]];
        // Edited by Evgen: this is no format string. [dateFormatter stringFromDate:birthdayPicker.date] is a regular string.
        birthdayField.text = [dateFormatter stringFromDate:birthdayPicker.date];
        [dateFormatter release];
        
        if(realBirthday) [realBirthday release];
        realBirthday = [birthdayPicker.date retain];    // Edited by Evgen: it's need to retain birthdayPicker.date !
    };

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    [UIView animateWithDuration:0.4f animations:^(void){
//        [scrollView setFrame:CGRectMake(0, 44, 320, 300)];
//    }];
    
    CGRect fieldRect = [[self.view viewWithTag:textField.tag] convertRect:[textField frame] toView:self.view];
    if(textField.tag>3 && textField.tag<7){
        [scrollView setContentSize:CGSizeMake(310, 800)];
        [scrollView scrollRectToVisible:CGRectMake(0, [textField frame].origin.y, 320, 700) animated:YES];
    };
    if(textField.tag>6){
        [scrollView setContentSize:CGSizeMake(310, 800)];
        [scrollView scrollRectToVisible:CGRectMake(0, fieldRect.origin.y, 320, 700) animated:YES];
    }
    return YES;    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [UIView animateWithDuration:0.4f animations:^(void){
        [scrollView setFrame:CGRectMake(0, 44, 320, 520)];
        [scrollView setContentSize:CGSizeMake(310, 670)];
    }];    
    return [textField resignFirstResponder]; 
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
};
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (section==0 || section==1)? 3:1;
};

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier;
    
    if([indexPath section]==2){
        CellIdentifier = @"RegistrationCellLID"; 
    }else{
        CellIdentifier = @"RegistrationCellTFID"; 
    }
       
    RegistrationCell *cell = (RegistrationCell *)[tableViewReg dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){                
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"RegistrationCell" owner:self options:nil];
        for(id oneObject in nibs){
            if([oneObject isKindOfClass:[RegistrationCell class]] && [[oneObject reuseIdentifier] isEqualToString:CellIdentifier]){
                cell = (RegistrationCell *)oneObject;
            };
        };
    };
   
    if([indexPath section]==0){
        cell.regFiled.delegate = self;
        switch ([indexPath row]) {
            case 0:
                cell.nameLabel.text = @"e-mail";
                [cell.regFiled setTag:1];
                cell.regFiled.keyboardType = UIKeyboardTypeEmailAddress;
                break;
            case 1: 
                cell.nameLabel.text = NSLocalizedString(@"Password",@"");
                [cell.regFiled setTag:2];
                cell.regFiled.secureTextEntry = true;
                break;                
            case 2:
                cell.nameLabel.text = NSLocalizedString(@"Confirm Password",@"");
                [cell.regFiled setTag:3];
                cell.regFiled.secureTextEntry = true;
                break;
            default:
                break;
        }
    };
    if([indexPath section]==1){
        cell.regFiled.delegate = self;
        switch ([indexPath row]) {
            case 0:
                //cell.regFiled.placeholder =
                cell.nameLabel.text =NSLocalizedString(@"Surname",@"");
                [cell.regFiled setTag:4];
                break;
            case 1:
                cell.nameLabel.text = NSLocalizedString(@"Name",@"");
                [cell.regFiled setTag:5];
                break;                
            case 2:
                cell.nameLabel.text = NSLocalizedString(@"Patronymic", @"");
                [cell.regFiled setTag:6];
                break;
            default:
                break;
        }
    };
    if([indexPath section]==2){
        cell.nameLabel.text = NSLocalizedString(@"Select birthday",@"");
        [cell.birthLabel setTag:7];
         cell.accessoryType = UITableViewCellAccessoryNone;
        cell.changeDateTarget = self;
        //cell.regFiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    };
    if([indexPath section]==3){
        cell.regFiled.delegate = self;
        cell.nameLabel.text = NSLocalizedString(@"Telephone",@"");
        [cell.regFiled setTag:8];
        cell.regFiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    };
    
    return cell;
};

- (IBAction)pressSelectBirthday{
    
   // [ resignFirstResponder];
    
    birthdaySelectorView.center = CGPointMake(160, 720);
    birthdaySelectorView.hidden = NO;
    
    if(realBirthday){
        [birthdayPicker setDate:realBirthday];
    };
    
    [UIView animateWithDuration:0.4f animations:^{
        birthdaySelectorView.center = CGPointMake(160, 240);
    }];
};

#pragma mark - UITableViewDelegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{    
    
      if([indexPath section]==2){
        if ([indexPath row]==0) {
            [self pressSelectBirthday];
        };
        return;
    };
}

- (BOOL) checkCorrFillField:(NSString *)str : (NSString *)regExpr {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExpr
                                                                           options:NSRegularExpressionSearch 
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:str options:NSRegularExpressionCaseInsensitive 
                                                    range:NSMakeRange(0, str.length)]; 
    
       
    if (error) {
        
        return NO;
    } else {    
        return (matches.count==0)? NO : YES;
    }    
}
    

- (IBAction)doneButtonPressed:(id)sender {    
    BOOL flagCheckEmpty = false;
    for (int a=0; a<6; a++) {
        UITextField *textField = (UITextField*)[self.view viewWithTag:a+1];
        if([textField.text isEqualToString:@""]){
            flagCheckEmpty = true;
        }
    }
    if(flagCheckEmpty){
        
        // TODO: изменить алерт
         [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") 
                                      message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",@"") otherButtonTitles:nil] autorelease] show];
    } else{
        NSString *alert = @" ";
        UITextField *emailField = (UITextField*)[self.view viewWithTag:1];
    
        UITextField *passField = (UITextField*)[self.view viewWithTag:2];
        UITextField *confpassField = (UITextField*)[self.view viewWithTag:3];
        UITextField *surnameField = (UITextField*)[self.view viewWithTag:4];
        UITextField *nameField = (UITextField*)[self.view viewWithTag:5];
        UITextField *secnameField = (UITextField*)[self.view viewWithTag:6];
        
       // UITextField *birthdayField = (UITextField*)[self.view viewWithTag:7];
        UILabel *birthdayField = (UILabel*)[self.view viewWithTag:7];
        UITextField *telephoneField = (UITextField*)[self.view viewWithTag:8];
        
        NSString *fioForUrl = [[[[surnameField.text stringByAppendingString:@"%20"] stringByAppendingString:nameField.text] stringByAppendingString:@"%20"] stringByAppendingString:secnameField.text];
        
        
        // check password
        if(![self checkCorrFillField:passField.text : @"^[а-яА-ЯёЁa-zA-Z0-9]{6,32}$"]){
            alert = [alert stringByAppendingFormat:@"- %@ \n", NSLocalizedString(@"unvalid Password", @"")];
            flagCheckEmpty = true;
        } 
        
       // check confirm Password
        if(![passField.text isEqualToString: confpassField.text]){
            alert = [alert stringByAppendingFormat:@"- %@ \n", NSLocalizedString(@"Make sure you fill correctly fields Password and Confirm Password.", @"")];
            flagCheckEmpty = true;
        }
        
        // check Birthday field
        if(![self checkCorrFillField:birthdayField.text : @"^(0[1-9]|[12][0-9]|3[01])\\.(0[1-9]|1[012])\\.(19|20)\\d\\d$"]){
            alert = [alert stringByAppendingFormat:@"- %@ \n", NSLocalizedString(@"unvalid Birthday", @"")];
            flagCheckEmpty = true;            
        }
        
        // check Email field
        if(![self checkCorrFillField:emailField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"]){
             alert = [alert stringByAppendingFormat:@"- %@ \n", NSLocalizedString(@"unvalid Email", @"")];
             flagCheckEmpty = true;
         }
        

        // if all right!
        if(!flagCheckEmpty){
            [activityReg setHidden: false];
            [activityReg startAnimating];
            
            NSURL *signinrUrl = [NSURL URLWithString:@"https://medarhiv.ru"];
            id	context = nil;
            NSMutableURLRequest *requestSigninMedarhiv = [NSMutableURLRequest requestWithURL:signinrUrl 
                                                                                 cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                                             timeoutInterval:30.0];                        
            [requestSigninMedarhiv setHTTPMethod:@"POST"];
            [requestSigninMedarhiv setHTTPBody:[[NSString stringWithFormat:@"cmd=srv&action=reg&email=%@&pass=%@&fio=%@&phone=%@&birthdate=%@", emailField.text, passField.text, fioForUrl, telephoneField.text, birthdayField.text] dataUsingEncoding:NSWindowsCP1251StringEncoding]]; 
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self
                                                                 action:@selector(handleResultOrError:withContext:)
                                                                context:context] autorelease];
            
            NSURLConnection* conn = [NSURLConnection connectionWithRequest:requestSigninMedarhiv delegate:network];
            [conn start];
            
            delegate.user_login =  emailField.text;
            delegate.user_pass = passField.text;
            delegate.user_fio = [NSString stringWithFormat:@"%@ %@ %@", surnameField.text, nameField.text, secnameField.text];
        }else{
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") 
                                   message:alert delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",@"") otherButtonTitles:nil] autorelease] show];
        }
        
    }
    
}

- (void)handleResultOrError:(id)resultOrError withContext:(id)context
{
    if ([resultOrError isKindOfClass:[NSError class]])
	{
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease] show];
        delegate.user_login = @"";
        delegate.user_pass = @"";
        delegate.user_fio  = @"";
        [activityReg stopAnimating];
        [activityReg setHidden:true];
        return;
	}
    
	//NSURLResponse* response = [resultOrError objectForKey:@"response"];
	NSData* data = [resultOrError objectForKey:@"data"];
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    if ([[res objectForKey:@"result"] intValue]==1){
       
        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"",@"") 
                                     message:NSLocalizedString(@"Registration success",@"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
                
        delegate.user_id = [res objectForKey:@"userID"];
        delegate.auth = [res objectForKey:@"result"];
        [delegate saveModuleData];
        [delegate.slideButton setEnabled:TRUE];
        [delegate.hostView setHidden:FALSE];
        [self dismissModalViewControllerAnimated:true];        
        //[[[viewControllers lastObject] fioLabel] setText:[res objectForKey:@"fio"]]; //TODO
        
    } else { 
        
        NSString *errorsForAlert= @" ";
        NSArray *listOfErrors = (NSArray *)[res objectForKey:@"error"];
        for (NSString *err in listOfErrors) {
            errorsForAlert = [[errorsForAlert stringByAppendingString:NSLocalizedString(err,@"")] stringByAppendingString:@"\n "];
        }
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") 
                                     message:errorsForAlert delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
        delegate.user_login = @"";
        delegate.user_pass = @"";
        delegate.user_fio  = @"";
    }
    [activityReg stopAnimating]; 
    [activityReg setHidden:true];
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    
    [scrollView release];
    [tableViewReg release];
    [activityReg release];
    [navBar release];
    [registrationLabel release];
    [birthdaySelectorView release];
    [birthdayPicker release];
    [doneButton release];
    [cancelBirthButton release];
    [doneBirthButton release];
    [super dealloc];
}

@end
