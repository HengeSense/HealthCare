//
//  LoginWithingsViewController.m
//  SelfHub
//
//  Created by ET on 10.10.12.
//
//

#import "LoginWithingsViewController.h"

@interface LoginWithingsViewController () <TTTAttributedLabelDelegate>

@property (nonatomic, retain) NSArray *Userlist;
@property (nonatomic, readwrite) int selectImpCell;
-(NSDictionary*) convertUserListToDict: (NSArray*) userL;
-(NSMutableArray*) convertDictToUserList:(NSDictionary*)userL;
-(BOOL) checkCorrFillField:(NSString *)str : (NSString *)regExpr;
-(void) hideActivityAndShowErrorLabelText: (NSString*)text;

@end

@implementation LoginWithingsViewController
@synthesize ErrorLabel;
@synthesize singInLabel;
@synthesize passwordLabel, passwordTextField;
@synthesize actView, activity, actLabel;
@synthesize loginLabel, loginTextField, loginButton, mainLoginView;
@synthesize usersTableView, mainSelectionUserView, mainHostLoginView;
@synthesize delegate, Userlist, selectImpCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(NSDictionary*) convertUserListToDict: (NSArray*) userL
{
    NSMutableArray *arrayUsers = [[NSMutableArray alloc] init];
    NSMutableDictionary *usersDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    WBSAPIUser *userForS;
    NSDictionary *arrForSaveUsers;
    
    for (int i=0; i < userL.count; i++)
    {
        userForS = [userL objectAtIndex:i];
        arrForSaveUsers = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[userForS firstname],[NSNumber numberWithInt:[userForS user_id]],[userForS publickey] , nil]
                                                      forKeys:[NSArray arrayWithObjects:@"firstname",@"id", @"publickey", nil]];
        [arrayUsers addObject:arrForSaveUsers];
    }
    [usersDictionary setValue:arrayUsers forKey:@"data"];
    [arrayUsers release];
    return usersDictionary;
}

-(NSMutableArray*) convertDictToUserList:(NSDictionary*)userL
{
    NSArray *massUsers = (NSArray *)[userL objectForKey:@"data"];    
    if ([massUsers count] < 1) return nil;
    
    NSMutableArray *parsed_users = [[[NSMutableArray alloc] init] autorelease];    
	for (int i=0; i < [massUsers count]; i++)
    {
		id user_i_o = [massUsers objectAtIndex:i];
		if (![user_i_o isKindOfClass:[NSDictionary class]])
			return nil;
        
		WBSAPIUser *singleUser = [[WBSAPIUser alloc] init];
		NSDictionary *user_i = (NSDictionary *)user_i_o;
        singleUser.user_id = [[user_i objectForKey:@"id"] intValue];
        singleUser.firstname = [user_i objectForKey:@"firstname"];
        singleUser.publickey = [user_i objectForKey:@"publickey"];
        
        [parsed_users addObject:singleUser];
        [singleUser release];
    }
    return parsed_users;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([delegate.notify isEqualToString:@"1"])
    {
        WithingsCustomCell *cellForPuch = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cellForPuch.pushSwitch setOn:YES];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([delegate.auth isEqualToString:@"0"])
    {
        [mainSelectionUserView setHidden:YES];
        [mainHostLoginView setHidden:NO];
    }else
    {
        [mainSelectionUserView setHidden:NO];
        [mainHostLoginView setHidden:YES];
        [delegate.rightBarBtn setEnabled:YES];
        self.Userlist = (NSArray*)[self convertDictToUserList:delegate.listOfUsers];;
        [self.view addSubview:mainSelectionUserView];
        [self.usersTableView reloadData];
    }
    
    UIImage *BackgroundImageBig = [UIImage imageNamed:@"withings_background-568h@2x.png"];
    UIImage *BackgroundImage = [[UIImage alloc] initWithCGImage:[BackgroundImageBig CGImage]
                                                          scale:2.0
                                                    orientation:UIImageOrientationUp];
    float verticalPathHeight = [UIScreen mainScreen].bounds.size.height;
    self.mainHostLoginView.frame = CGRectMake(0, 0, self.view.frame.size.width, verticalPathHeight);
    self.mainSelectionUserView.frame = CGRectMake(0, 0, self.view.frame.size.width, verticalPathHeight);
    
    self.mainHostLoginView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mainSelectionUserView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.mainHostLoginView.backgroundColor = [UIColor colorWithPatternImage:BackgroundImage];
    self.mainSelectionUserView.backgroundColor = [UIColor colorWithPatternImage: BackgroundImage];
    [BackgroundImage release];
    
    [self.loginButton setImage:[UIImage imageNamed:@"login_norm-568h@2x.png"] forState:UIControlStateNormal];
    [self.loginButton setImage:[UIImage imageNamed:@"login_press-568h@2x.png"] forState:UIControlStateHighlighted];
    
    loginLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Login", @"")];
    passwordLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Password", @"")];
    
    self.actView.layer.cornerRadius = 10.0;
    actView.hidden = YES;
    
    singInLabel.text = NSLocalizedString(@"signin", @"");
    
    UILabel *loginButtonLabl = [[UILabel alloc] initWithFrame:CGRectMake(104, 8, 80, 30)];
    loginButtonLabl.backgroundColor = [UIColor clearColor];
    loginButtonLabl.text = NSLocalizedString(@"SignIn", @"");
    loginButtonLabl.textColor = [UIColor whiteColor];
    loginButtonLabl.shadowColor = [UIColor colorWithRed:132.0f/255.0f
                                                  green:8.0f/255.0f
                                                   blue:59.0f/255.0f
                                                  alpha:1.0];
    UIFont *myFontL = [UIFont fontWithName: @"Helvetica-Bold" size: 15.0];
    loginButtonLabl.font = myFontL;
    
    [loginButton addSubview:loginButtonLabl];
    [loginButtonLabl release];
    
    TTTAttributedLabel *registrLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(78.0, 370.0, 165.0, 34.0)];
    registrLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    registrLabel.textColor = [UIColor colorWithRed:141.0f/255.0f green:152.0f/255.0f blue:168.0f/255.0f alpha:1.0];
    registrLabel.numberOfLines = 0;
    registrLabel.backgroundColor = [UIColor clearColor];
    registrLabel.textAlignment = UITextAlignmentCenter;
    
    registrLabel.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                              forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:(id)[[UIColor colorWithRed:141.0f/255.0f
                                                                green:152.0f/255.0f
                                                                 blue:168.0f/255.0f
                                                                alpha:1.0] CGColor]
                                    forKey:(NSString*)kCTForegroundColorAttributeName];
    
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:YES]
                                    forKey:(NSString *)kCTUnderlineStyleAttributeName];
    registrLabel.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    
    registrLabel.delegate = self;
    registrLabel.text = NSLocalizedString(@"SignUp", @"");
    NSRange range = [registrLabel.text rangeOfString: NSLocalizedString(@"SignUp", @"")];
    [registrLabel addLinkToURL:[NSURL URLWithString:@"http://www.withings.com/en/account/register/"]
                     withRange:range];
    
    [mainHostLoginView addSubview:registrLabel];
    [registrLabel release];
    
    self.actLabel.text = NSLocalizedString(@"ConnectToServer", @"");
    
    selectImpCell = 0;
    self.usersTableView.dataSource = self;    
}

- (void)viewDidUnload
{
    [self setLoginButton:nil];
    [self setPasswordLabel:nil];
    [self setPasswordTextField:nil];
    [self setLoginLabel:nil];
    [self setLoginTextField:nil];
    [self setActView:nil];
    [self setActivity:nil];
    [self setActLabel:nil];
    [self setMainLoginView:nil];
    [self setUsersTableView:nil];
    [self setMainSelectionUserView:nil];
    [self setMainHostLoginView:nil];
    [self setErrorLabel:nil];
    
    [self setSingInLabel:nil];
    [self setUserlist:nil];
    [super viewDidUnload];
}

#pragma TTTAttributedLabel delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}


- (BOOL) checkCorrFillField:(NSString *)str : (NSString *)regExpr
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExpr
                                                                           options:NSRegularExpressionSearch
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:str options:NSRegularExpressionCaseInsensitive
                                        range:NSMakeRange(0, str.length)];
    if (error)
    {
        return NO;
    } else {
        return (matches.count==0)? YES : NO;
    }
}

- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}


- (IBAction)backgroundTouched:(id)sender
{
    [self.loginTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void) showActiveView
{
    actView.hidden=NO;
    [activity startAnimating];
}

- (void) hideActiveView
{
    actView.hidden=YES;
    [activity stopAnimating];
}


-(IBAction) registrButtonClick :(id)sender
{    
    [self backgroundTouched:nil];
    NetworkStatus curStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(curStatus != NotReachable)
    {
        if (![self.loginTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] &&![self checkCorrFillField:self.loginTextField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"])
        {
            WorkWithWithings *user = [[[WorkWithWithings alloc] init] autorelease];
            user.account_email = self.loginTextField.text;
            user.account_password = self.passwordTextField.text;
            [self showActiveView];
            Htppnetwork *network = [[Htppnetwork alloc] initWithTarget:self
                                                                action:@selector(handleResultOrError:)
                                                               context:nil];
            
            NSURLConnection *conn = [NSURLConnection connectionWithRequest:[user getUsersListFromAccountAsynch]
                                                                  delegate:network];
            [conn start];
            [network release];
            user.account_email = nil;
            user.account_password = nil;
        }else{
            [ErrorLabel setText: NSLocalizedString(@"Wrong username or password.", @"")];
            [ErrorLabel setHidden: NO];
            self.passwordTextField.text = @"";
        }
    }else {
        [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"didFailWithError"];
    }
}

-(void) hideActivityAndShowErrorLabelText: (NSString*)text{
    self.passwordTextField.text = @"";
    [ErrorLabel setText: NSLocalizedString(text, @"")];
    [ErrorLabel setHidden: NO];
    [self hideActiveView];
}

- (void)handleResultOrError:(id)resultOrError
{
    if (resultOrError==nil)
    {
        [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"Query_fail"];
		return;
	}
    
    int status;
    NSError *myError = nil;
    if([resultOrError isKindOfClass:[NSError class]] || [resultOrError objectForKey:@"data"]==nil)
    {
        [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"Query_fail"];
        return;
    }
   
    NSData *data = [resultOrError objectForKey:@"data"];
    NSDictionary *repr = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableLeaves
                                                           error:&myError];
    if (repr==nil)
    {
        [self hideActivityAndShowErrorLabelText:@"db_connection_fail"];
        return;
    }
    
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0)
    {        
        [self hideActivityAndShowErrorLabelText:(status==100)?@"Wrong username or password.":@"db_connection_fail"];
        return;
	}
    
    NSArray *users = (NSArray *)[[repr objectForKey:@"body"] objectForKey:@"users"];    
    if ([users count] < 1)
    {
        [self hideActivityAndShowErrorLabelText:@"No data"];
        return;
    }
   
    NSMutableArray *parsed_users = [[[NSMutableArray alloc] init] autorelease];
	for (int i=0; i < [users count]; i++)
    {
		id user_i_o = [users objectAtIndex:i];
		if (![user_i_o isKindOfClass:[NSDictionary class]])
        {
            [self hideActivityAndShowErrorLabelText:@"db_connection_fail"];
            return;
        }
		WBSAPIUser *singleUser = [[WBSAPIUser alloc] init];
		NSDictionary *user_i = (NSDictionary *)user_i_o;
        
        singleUser.user_id = [[user_i objectForKey:@"id"] intValue];
        singleUser.firstname = [user_i objectForKey:@"firstname"];
        singleUser.lastname = [user_i objectForKey:@"lastname"];
        singleUser.shortname = [user_i objectForKey:@"shortname"];
        singleUser.gender = [[user_i objectForKey:@"gender"] intValue];
        singleUser.fatmethod = [[user_i objectForKey:@"fatmethod"] intValue];
        singleUser.birthdate = [[user_i objectForKey:@"birthdate"] intValue];
        singleUser.ispublic = [[user_i objectForKey:@"ispublic"] boolValue];
        singleUser.publickey = [user_i objectForKey:@"publickey"];
        
		[parsed_users addObject:singleUser];
        [singleUser release];
	}
    
    self.Userlist = parsed_users;
    
    if(self.Userlist == nil ||[self.Userlist count] == 0)
    {
        [self hideActivityAndShowErrorLabelText:@"db_connection_fail"];
    }else
    {
        [ErrorLabel setHidden: YES];
        [self.usersTableView reloadData];
        [self.view addSubview:mainSelectionUserView];
        [mainSelectionUserView setHidden:NO];
        [mainHostLoginView setHidden:YES];
        [delegate.rightBarBtn setEnabled:NO];
        delegate.auth = @"1";
        delegate.listOfUsers = [self convertUserListToDict: self.Userlist];
        [delegate saveModuleData];
        [self hideActiveView];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (section==0)? 1:[self.Userlist count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = nil;
    if([indexPath section]==0){
        cellID = @"puchNotificationCell";
    }else{
        cellID = indexPath.row==0 ? @"HeaderCellID" : @"Cell";
    }
    
    WithingsCustomCell *cell = (WithingsCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"WithingsCustomCell" owner:self options:nil];
        for(id oneObject in nibs)
        {
            if([oneObject isKindOfClass:[WithingsCustomCell class]] && [[oneObject reuseIdentifier] isEqualToString:cellID]){
                cell = (WithingsCustomCell *)oneObject;
            }
        }
    }
    if ([indexPath section] ==0)
    {
        if(delegate.userID==0)
        {
            cell.hidden = YES;
            tableView.frame = CGRectMake(tableView.frame.origin.x, -70.0, tableView.frame.size.width, tableView.frame.size.height);
        }else
        {
            cell.hidden = NO;
            tableView.frame = CGRectMake(tableView.frame.origin.x, 0, tableView.frame.size.width, tableView.frame.size.height);
        }
        UIImage *CellBackgroundSynchPanelImageBig = [UIImage imageNamed:@"synchCellPanel-568h@2x.png"];
        UIImage *CellBackgroundSynchPanelImage = [[UIImage alloc] initWithCGImage:[CellBackgroundSynchPanelImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
        UIImageView *imSynchP = [[UIImageView alloc] initWithImage:CellBackgroundSynchPanelImage];
        cell.BackgroundView = imSynchP;
        [CellBackgroundSynchPanelImage release];
        [imSynchP release];
        cell.puchLabel.text = NSLocalizedString(@"push_notification", @"");
        cell.selectUserTarget = self;
        
        if([delegate.notify isEqualToString:@"0"])
        {
            [cell.pushSwitch setOn:NO];
        }else
        {            
            int time_Now = [[NSDate date] timeIntervalSince1970];
            if (delegate.expNotifyDate!=0 && delegate.expNotifyDate<time_Now)
            {
                if([delegate checkAndTurnOnNotification])
                {
                    [cell.pushSwitch setOn:YES];
                    delegate.notify = @"1";
                }else{
                    [cell.pushSwitch setOn:NO];
                    delegate.notify = @"0";
                }
                [delegate saveModuleData];
            }
        }
        return cell;
    }
    if([indexPath section]==1)
    {
        if([indexPath row]==0){ // Branch fo header cell
            return cell;
        }
                
        UIImage *CellBackgroundImageBig = [UIImage imageNamed:(indexPath.row!=self.Userlist.count)?@"middle_tableImg-568h.png":@"end_tableImg-568h.png"];
        UIImageView *im = [[UIImageView alloc] initWithImage:CellBackgroundImageBig];
        cell.BackgroundView = im;
        [im release];
        
        if(self.Userlist)
        {
            WBSAPIUser *user = [self.Userlist objectAtIndex:indexPath.row-1];
            cell.label.text =[user firstname];
            cell.inf = user;
            
            // first row is header cell
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectUserTarget = self;
            
            if(user.user_id == delegate.lastuser){
                selectImpCell = indexPath.row;
                [self selectDesignCell:cell];
            }
        }
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.section==0)?  58 :((indexPath.row!=self.Userlist.count || indexPath.row==0)? 44.0 : 53);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0; // ! NO Header
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([indexPath row]==0) return nil;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section]==1)
    {
        if([indexPath row]!=0)
        {
            WithingsCustomCell *cell = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];
            WBSAPIUser *user = cell.inf;
            UIAlertView *alertToConfirm = [[UIAlertView alloc] initWithTitle:@""  message: [NSString stringWithFormat:@"%@\n %@?", NSLocalizedString(@"ConfirmImport",@""), user.firstname]
                                                                    delegate: self
                                                           cancelButtonTitle: NSLocalizedString(@"Cancel",@"")
                                                           otherButtonTitles: NSLocalizedString(@"Import",@""), nil];
            [alertToConfirm setTag:[indexPath row]];
            [alertToConfirm show];
            [alertToConfirm release];
        }
    }
}

- (void) clickCellImportButton:(int) sender
{
    NetworkStatus curStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(curStatus != NotReachable)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender inSection:1];
        WithingsCustomCell *cell = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];        
        WBSAPIUser *user = cell.inf;
        
        if(delegate.lastuser!=0 && delegate.lastuser!=user.user_id)
        {
            [UIAlertView createAndShowAlertViewWithTitle:@"" message:@"Changed_user" titleOtherButton:@"Ok" delegate:self andTag:sender];
        }else
        {
            if(delegate.userID==0){
                [self.usersTableView reloadData];
            }
            delegate.userID = user.user_id;
            delegate.user_firstname = user.firstname;
            delegate.userPublicKey = user.publickey;
            [delegate selectScreenFromMenu:cell];
            delegate.auth = @"1";
            [delegate saveModuleData];
            if(selectImpCell!=0){
                [self unselectDesignCell];
            }
            [self selectDesignCell:cell];
            selectImpCell = sender;
            
        }
    }else {
        [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"didFailWithError"];
    }
}

-(void) unselectDesignCell
{
    WithingsCustomCell *cellUncheck = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectImpCell inSection:1]];
    [cellUncheck.label setTextColor:[UIColor colorWithRed:89.0f/255.0f green:93.0f/255.0f blue:99.0f/255.0f alpha:1.0]];
}

-(void) selectDesignCell: (WithingsCustomCell*) cell
{
    [cell.label setTextColor:[UIColor colorWithRed:235.0f/255.0f green:13.0f/255.0f blue:106.0f/255.0f alpha:1.0]];
}

-(void) changeUserConfirmation:(int) tagSelUser
{
    [delegate selectScreenProgrammatically:1];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tagSelUser inSection:1];
    WithingsCustomCell *cell = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];
    
    if(selectImpCell!=0)
    {
        [self unselectDesignCell];
    }
    
    [self selectDesignCell:cell];
    selectImpCell = tagSelUser;
    
    if(delegate.userID==0)
    {
        [self.usersTableView reloadData];
    }
    if ([delegate.notify isEqualToString:@"1"])
    {
        [self revokeUserNotify];
    }
    
    WBSAPIUser *user = cell.inf;
    delegate.userID = user.user_id;
    delegate.user_firstname = user.firstname;
    delegate.userPublicKey = user.publickey;
    delegate.auth = @"1";
    delegate.lastTime = 0;
    
    //?
    // delegate.notify = @"0";
    // delegate.expNotifyDate = 0;
    // delegate.synchNotificationImView.image = [UIImage imageNamed:@"synch_off@2x.png"];
    [delegate saveModuleData];
    
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonNamePressed = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttonNamePressed isEqualToString:NSLocalizedString(@"Import",@"")])
    {
        if(buttonIndex == 1){
            [self clickCellImportButton:alertView.tag];
        }
    }else
    {
        if(buttonIndex == 1){
            [self changeUserConfirmation:alertView.tag];
        }
    }
}

-(void) notificationGuiWith: (NSString*)notyfId andAlert: (NSString*) alertmsg
{
    delegate.notify = notyfId;
    if([notyfId isEqualToString:@"0"])
    {
        delegate.expNotifyDate = 0;
        [UAPush shared].alias = @"";
    }else
    {
        [UAPush shared].alias = [NSString stringWithFormat:@"%d", delegate.userID];
    }
    [[UAPush shared] registerDeviceToken:(NSData*)[UAPush shared].deviceToken];
    [delegate saveModuleData];
    [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"" AndMessage:alertmsg];
}

-(void) synchNotificationShouldOn: (UISwitch *)pushSwitch
{
    if(delegate.userID!=0)
    {
        NetworkStatus curStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        if(curStatus != NotReachable)
        {
            WorkWithWithings *notifyWork = [[WorkWithWithings alloc] init];
            notifyWork.user_id = delegate.userID;
            notifyWork.user_publickey = delegate.userPublicKey;
            
            NSDictionary *resultOfCheck = [notifyWork getNotificationStatus];
            if (resultOfCheck!=nil && [delegate.notify isEqualToString:@"0"])
            {
                [pushSwitch setOn:YES];
                [self notificationGuiWith:@"1" andAlert:@"Subscribe_notify"];
                delegate.expNotifyDate = [[resultOfCheck objectForKey:@"date"] intValue];
            }else
            {
                BOOL resultNotify = [notifyWork getNotificationSibscribeWithComment:@"test" andAppli:1];
                if(resultNotify)
                {
                    [pushSwitch setOn:YES];
                    [self notificationGuiWith:@"1" andAlert:@"Subscribe_notify"];
                    NSDictionary *resultOfCheckStatus = [notifyWork getNotificationStatus];
                    if (resultOfCheckStatus!=nil)
                    {
                        delegate.expNotifyDate = [[resultOfCheckStatus objectForKey:@"date"] intValue];
                    }
                } else
                {
                    [pushSwitch setOn:NO];
                    [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"Query_fail"];
                }
            }
            [notifyWork release];
        }else
        {
            [pushSwitch setOn:NO];
            [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"didFailWithError"];
        }
    }else
    {
        [pushSwitch setOn:NO];
        [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"needImportUserWithings"];
    }
}

- (void)synchNotificationShouldOff: (UISwitch *)pushSwitch
{
    if(delegate.userID!=0)
    {
        NetworkStatus curStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        if(curStatus != NotReachable)
        {
            WorkWithWithings *notifyWork = [[WorkWithWithings alloc] init];
            notifyWork.user_id = delegate.userID;
            notifyWork.user_publickey = delegate.userPublicKey;
            
            NSDictionary *resultOfCheck = [notifyWork getNotificationStatus];
            if (resultOfCheck==nil && [delegate.notify isEqualToString:@"1"])
            {
                [pushSwitch setOn:NO];
                [self notificationGuiWith:@"0" andAlert:@"Revoke_notify"];
                [UAPush shared].alias = @"";
                [[UAPush shared] registerDeviceToken:(NSData*)[UAPush shared].deviceToken];
            } else
            {
                BOOL resultNotify;
                if ([delegate.notify isEqualToString:@"1"])
                {
                    resultNotify = [notifyWork getNotificationRevoke:1];
                    if(resultNotify)
                    {
                        [pushSwitch setOn:NO];
                        [self notificationGuiWith:@"0" andAlert:@"Revoke_notify"];
                    }else
                    {
                        [pushSwitch setOn:YES];
                        [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"Query_fail"];
                    }
                }
            }
            [notifyWork release];
        } else
        {
            [pushSwitch setOn:YES];
            [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"didFailWithError"];
        }
    }else
    {
        [pushSwitch setOn:NO];
        [UIAlertView createAndShowSimpleAlertWithLocalizedTitle:@"Error" AndMessage:@"needImportUserWithings"];
    }
}

- (BOOL) revokeUserNotify
{
    BOOL resultNotify = NO;
    WorkWithWithings *notifyWork = [[WorkWithWithings alloc] init];
    notifyWork.user_id = delegate.userID;
    notifyWork.user_publickey = delegate.userPublicKey;
    resultNotify = [notifyWork getNotificationRevoke:1];
    if(resultNotify)
    {
        WithingsCustomCell *cell = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.pushSwitch setOn:NO];
        [UAPush shared].alias = @"";
        [[UAPush shared] registerDeviceToken:(NSData*)[UAPush shared].deviceToken];
        delegate.notify = @"0";
        delegate.expNotifyDate = 0;
        [delegate saveModuleData];
        resultNotify = YES;
    }else
    {
        resultNotify = NO;
    }
    [notifyWork release];
    
    return resultNotify;
}


-(void) cleanup
{
    [mainHostLoginView setHidden:NO];
    [mainSelectionUserView setHidden:YES];
    [mainSelectionUserView removeFromSuperview];
    passwordTextField.text = @"";
    delegate.auth = @"0";
    
    for (int j=1; j<[usersTableView numberOfRowsInSection:1]; j++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:1];
        WithingsCustomCell *custCell = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];
        [custCell.label setTextColor:[UIColor colorWithRed:89.0f/255.0f green:93.0f/255.0f blue:99.0f/255.0f alpha:1.0]];
    }
    selectImpCell = 0;
    [(NSMutableArray*)delegate.listOfUsers removeAllObjects];
    delegate.listOfUsers = nil;
    [delegate saveModuleData];
    
    NSMutableArray *deletedRows = [[NSMutableArray alloc] init];
    for(int i=0;i<[self.usersTableView numberOfRowsInSection:1]-1;i++)
    {
        [deletedRows addObject:[NSIndexPath indexPathForRow:i+1 inSection:1]];
    }
    [(NSMutableArray*)self.Userlist removeAllObjects];
    self.Userlist = nil;
    [self.usersTableView deleteRowsAtIndexPaths:deletedRows withRowAnimation:UITableViewRowAnimationNone];
    [deletedRows release];
    [self revokeUserNotify];
    [self.usersTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [loginButton release];
    [passwordLabel release];
    [passwordTextField release];
    [loginLabel release];
    [loginTextField release];
    [actView release];
    [activity release];
    [actLabel release];
    [mainLoginView release];
    [usersTableView release];
    [mainSelectionUserView release];
    [mainHostLoginView release];
    [ErrorLabel release];
    [singInLabel release];
    [Userlist release];
    
    [super dealloc];
}

@end
