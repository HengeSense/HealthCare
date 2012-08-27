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
    [scrollView setContentSize:CGSizeMake(310, 670)]; 
    
       
    registrationLabel.text = NSLocalizedString(@"Registration",@"");
    
    [doneButton setTitle:NSLocalizedString(@"Done",@"") forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"medarhiv_background.png"]];
    
    [self.view addSubview:scrollView];
    
    [tableViewReg scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

- (void)viewDidUnload
{
    delegate = nil;
    scrollView = nil;
    doneButton = nil;
    [self setTableViewReg:nil];
    [self setActivityReg:nil];
    [self setNavBar:nil];
    [self setRegistrationLabel:nil];
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
        [scrollView scrollRectToVisible:CGRectMake(0, fieldRect.origin.y, 320, 2500) animated:YES];
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
    CellIdentifier = @"RegistrationCellTFID";    
    //    NSUInteger curRecIndex = [delegate.weightData count] - [indexPath row] - 1;
    RegistrationCell *cell = (RegistrationCell *)[tableViewReg dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){                
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"RegistrationCell" owner:self options:nil];
        for(id oneObject in nibs){
            if([oneObject isKindOfClass:[RegistrationCell class]] && [[oneObject reuseIdentifier] isEqualToString:CellIdentifier]){
                cell = (RegistrationCell *)oneObject;
            };
        };
    };
    cell.regFiled.delegate = self;
    if([indexPath section]==0){
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
        [cell.regFiled setTag:7];
        cell.regFiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    };
    if([indexPath section]==3){
        cell.nameLabel.text = NSLocalizedString(@"Telephone",@"");
        [cell.regFiled setTag:8];
        cell.regFiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    };
    
    return cell;
};


#pragma mark - UITableViewDelegate

//- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 47.0;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if([indexPath section]==1){
        switch ([indexPath row]) {
            case 0:
                
             
                
                //[self addDataRecord];
//                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
                
                break;
            case 1:
               // [self pressEdit];  
                break;
            case 2:
               // [self removeAllDatabase];
                break;
            case 3:
                //[self testFillDatabase];
                break;      
            default:
                break;
        };
        return;
    };
    
//    NSUInteger curRecIndex = [delegate.weightData count] - [indexPath row] - 1;
//    
//    detailView.curWeight = [[[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"weight"] floatValue];
//    detailView.datePicker.date = [[delegate.weightData objectAtIndex:curRecIndex] objectForKey:@"date"];
//    editingRecordIndex = curRecIndex;
    
//    [detailView showView];
}

- (BOOL) checkCorrFillField:(NSString *)str : (NSString *)regExpr {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExpr
                                                                           options:NSRegularExpressionSearch 
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:str options:NSRegularExpressionCaseInsensitive 
                                                    range:NSMakeRange(0, str.length)]; 
    
    NSLog(@"match loc: %d", matches.count);
    
    if (error) {
        NSLog(@"%@", error);
        return NO;
    } else {    
        return (matches.count==0)? NO : YES;
    }    
}
    
    


- (IBAction)doneButtonPressed:(id)sender {    
    BOOL flagCheckEmpty = false;
    for (int a=0; a<9; a++) {
        UITextField *textField = (UITextField*)[self.view viewWithTag:a+1];
        if([textField.text isEqualToString:@""]){
            flagCheckEmpty = true;
        }
    }
    if(flagCheckEmpty){
         [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") 
                                      message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
    } else{
        
        UITextField *emailField = (UITextField*)[self.view viewWithTag:1];
    
        UITextField *passField = (UITextField*)[self.view viewWithTag:2];
        UITextField *confpassField = (UITextField*)[self.view viewWithTag:3];
        UITextField *surnameField = (UITextField*)[self.view viewWithTag:4];
        UITextField *nameField = (UITextField*)[self.view viewWithTag:5];
        UITextField *secnameField = (UITextField*)[self.view viewWithTag:6];
        
        UITextField *birthdayField = (UITextField*)[self.view viewWithTag:7];
        UITextField *telephoneField = (UITextField*)[self.view viewWithTag:8];
        
        NSString *fioForUrl = [[[[surnameField.text stringByAppendingString:@"%20"] stringByAppendingString:nameField.text] stringByAppendingString:@"%20"] stringByAppendingString:secnameField.text];
        
        
        // check password
        if(![self checkCorrFillField:passField.text : @"^[а-яА-ЯёЁa-zA-Z0-9]{6,32}$"]){
            
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") 
                                         message:NSLocalizedString(@"unvalid Password", @"")  delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
            flagCheckEmpty = true;
            
        } 
        
       // check confirm Password
        if(![passField.text isEqualToString: confpassField.text]){
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") 
                                         message:NSLocalizedString(@"Make sure you fill correctly fields Password and Confirm Password.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
            flagCheckEmpty = true;
        }
        
        // check Birthday field
        if(![self checkCorrFillField:birthdayField.text : @"^(0[1-9]|[12][0-9]|3[01])\\.(0[1-9]|1[012])\\.(19|20)\\d\\d$"]){
           
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") 
                                         message:NSLocalizedString(@"unvalid Birthday", @"")  delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
            flagCheckEmpty = true;
            
        }
        
        // check Email field
        if(![self checkCorrFillField:emailField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"]){
             
             [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") 
                                          message:NSLocalizedString(@"unvalid Email", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
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
//            delegate.user_fio  = [[[[surnameField.text stringByAppendingString:@" "] stringByAppendingString:nameField.text] stringByAppendingString:@" "] stringByAppendingString:secnameField.text];
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
    
    
    NSString *valueOfResult = (NSString *)[[res objectForKey:@"result"]stringValue];   
    if ([[res objectForKey:@"result"] intValue]==1){
        NSLog(@"key: %@", res);
        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"",@"") 
                                     message:NSLocalizedString(@"Registration success",@"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
                
        delegate.user_id = [[res objectForKey:@"userID"] stringValue];
        delegate.auth = valueOfResult;
        [delegate saveModuleData];
        [delegate.slideButton setEnabled:TRUE];
        [delegate.hostView setHidden:FALSE];
        [self dismissModalViewControllerAnimated:true];        
        //[[[viewControllers lastObject] fioLabel] setText:[res objectForKey:@"fio"]]; //TODO
        
    } else { 
         NSLog(@"key: %@", res);
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
    
    [doneButton release];
    [scrollView release];
    [tableViewReg release];
    [activityReg release];
    [navBar release];
    [registrationLabel release];
    [super dealloc];
}

@end
