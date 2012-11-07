//
//  LoginWithingsViewController.m
//  SelfHub
//
//  Created by Anton on 10.10.12.
//
//

#import "LoginWithingsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginWithingsViewController ()
    @property (nonatomic, retain) NSArray *Userlist;
@end

@implementation LoginWithingsViewController
@synthesize ErrorLabel;
@synthesize singInLabel;

@synthesize passwordLabel, passwordTextField;
@synthesize actView, activity, actLabel;
@synthesize loginLabel, loginTextField, loginButton;
@synthesize mainLoginView;
@synthesize exitButton, usersTableView;
@synthesize mainSelectionUserView, mainHostLoginView;
@synthesize delegate, Userlist;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSDictionary*) convertUserListToDict: (NSArray*) userL{
              
    
    NSMutableArray *arrayUsers = [[[NSMutableArray alloc] init] autorelease];
    NSMutableDictionary *usersDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    WBSAPIUser *userForS;
    NSDictionary *arrForSaveUsers;
    for (int i=0; i < userL.count; i++) {
        userForS = [userL objectAtIndex:i];
        arrForSaveUsers = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[userForS firstname],[NSNumber numberWithInt:[userForS user_id]],[userForS publickey] , nil] forKeys:[NSArray arrayWithObjects:@"firstname",@"id", @"publickey", nil]];
        [arrayUsers addObject:arrForSaveUsers];
    }
    [usersDictionary setValue:arrayUsers forKey:@"data"];
    return usersDictionary;
}

-(NSMutableArray*) convertDictToUserList:(NSDictionary*)userL{
    NSArray *massUsers = (NSArray *)[userL objectForKey:@"data"];
    if ([massUsers count] < 1){
        NSLog(@"userslist: 'users' array empty");
        return nil;
    }
    NSMutableArray *parsed_users = [[[NSMutableArray alloc] init] autorelease];
    
	for (int i=0; i < [massUsers count]; i++){
		id user_i_o = [massUsers objectAtIndex:i];
		if (![user_i_o isKindOfClass:[NSDictionary class]]) {
			NSLog(@"userslist: user #%d not a dict", i);
			return nil;
        }
        
		WBSAPIUser *singleUser = [[[WBSAPIUser alloc] init] autorelease];
		NSDictionary *user_i = (NSDictionary *)user_i_o;
        
        singleUser.user_id = [[user_i objectForKey:@"id"] intValue];
        singleUser.firstname = [user_i objectForKey:@"firstname"];
        singleUser.publickey = [user_i objectForKey:@"publickey"];
        
        [parsed_users addObject:singleUser];
    }
    return parsed_users;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([delegate.auth isEqualToString:@"0"]){
        [mainSelectionUserView setHidden:true];
        [mainHostLoginView setHidden:false];
    }
    else{
        [mainSelectionUserView setHidden:false];
        [mainHostLoginView setHidden:true];
        [delegate.rightBarBtn setEnabled:true];
        self.Userlist = (NSArray*)[self convertDictToUserList:delegate.listOfUsers];;
        [self.view addSubview:mainSelectionUserView];
        [self.usersTableView reloadData];
    }
    
    UIImage *BackgroundImageBig = [UIImage imageNamed:@"withings_background@2x.png"];
    UIImage *BackgroundImage = [[UIImage alloc] initWithCGImage:[BackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    self.mainHostLoginView.backgroundColor = [UIColor colorWithPatternImage:BackgroundImage];
    self.mainSelectionUserView.backgroundColor = [UIColor colorWithPatternImage: BackgroundImage];
    [BackgroundImage release];
    
    
    [self.loginButton setImage:[UIImage imageNamed:@"login_norm@2x.png"] forState:UIControlStateNormal];
    [self.loginButton setImage:[UIImage imageNamed:@"login_press@2x.png"] forState:UIControlStateHighlighted];
    
    loginLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Login", @"")];
    passwordLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Password", @"")];
    
    self.actView.layer.cornerRadius = 10.0;
    actView.hidden = YES;
    
    singInLabel.text = NSLocalizedString(@"signin", @"");
    
    UILabel *loginButtonLabl = [[UILabel alloc] initWithFrame:CGRectMake(104, 8, 80, 30)];
    loginButtonLabl.backgroundColor = [UIColor clearColor];
    loginButtonLabl.text = NSLocalizedString(@"SignIn", @"");
    loginButtonLabl.textColor = [UIColor whiteColor];
    loginButtonLabl.shadowColor = [UIColor colorWithRed:132.0f/255.0f green:8.0f/255.0f blue:59.0f/255.0f alpha:1.0];
    UIFont *myFontL = [UIFont fontWithName: @"Helvetica-Bold" size: 15.0];
    loginButtonLabl.font = myFontL;
    //loginButtonLabl.shadowOffset = CGSizeMake(2, 1);
    [loginButton addSubview:loginButtonLabl];
    [loginButtonLabl release]; 

    
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
    [self setExitButton:nil];
    [self setUsersTableView:nil];
    [self setMainSelectionUserView:nil];
    [self setMainHostLoginView:nil];
    [self setErrorLabel:nil];
   
    [self setSingInLabel:nil];
    [super viewDidUnload];
}


- (BOOL) checkCorrFillField:(NSString *)str : (NSString *)regExpr {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExpr options:NSRegularExpressionSearch error:&error];
    NSArray *matches = [regex matchesInString:str options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, str.length)];

    if (error) {
        return NO;
    } else {
        return (matches.count==0)? YES : NO;
    }
}

- (IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder];
}


- (IBAction)backgroundTouched:(id)sender
{
    [self.loginTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void) showActiveView{
    actView.hidden=NO;
    [activity startAnimating];
}

- (void) hideActiveView{
    actView.hidden=YES;
    [activity stopAnimating];
}


-(IBAction) registrButtonClick :(id)sender{
       
    [self backgroundTouched: sender];
    
//     dispatch_async(dispatch_get_main_queue(), ^{            
//    });    
// if(self.loginTextField.text == @""){
//      self.loginTextField.text = @"bis@hintsolutions.ru";
//      self.passwordTextField.text =  @"AllSystems1";
// }      
    if (![self.loginTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] &&![self checkCorrFillField:self.loginTextField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"]){
        WorkWithWithings *user = [[WorkWithWithings alloc] init];
        user.account_email = self.loginTextField.text;
        user.account_password = self.passwordTextField.text;
        [self performSelectorInBackground:@selector(showActiveView) withObject:nil];
        self.Userlist = [user getUsersListFromAccount];
        if( self.Userlist == NULL ||[self.Userlist count] == 0){
            [ErrorLabel setText: NSLocalizedString(@"db_connection_fail", @"")];
            [ErrorLabel setHidden: false];
          
            user.account_email = nil;
            user.account_password = nil;
            [user release];
            [self hideActiveView];
           // [self performSelectorInBackground:@selector(hideActiveView) withObject:nil];
        }else{
            [ErrorLabel setHidden: true];
            [self.usersTableView reloadData];
            [self.view addSubview:mainSelectionUserView];
            [mainSelectionUserView setHidden:false];
            [mainHostLoginView setHidden:true];
            [delegate.rightBarBtn setEnabled:true];
            delegate.auth = @"1";
            delegate.listOfUsers = [self convertUserListToDict: self.Userlist];
            user.account_email = nil;
            user.account_password = nil;
            [delegate saveModuleData];
            [user release]; 
            [self hideActiveView];
            //[self performSelectorInBackground:@selector(hideActiveView) withObject:nil];
        }
       
    }else{
        [ErrorLabel setText: NSLocalizedString(@"Wrong username or password.", @"")];
        [ErrorLabel setHidden: false];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.Userlist count] + 1;   // ! one row for header cell
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = indexPath.row==0 ? @"HeaderCellID" : @"Cell";
    
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil){                
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        for(id oneObject in nibs){
            if([oneObject isKindOfClass:[CustomCell class]] && [[oneObject reuseIdentifier] isEqualToString:cellID]){
                cell = (CustomCell *)oneObject;
            };
        };
    };
   
    if([indexPath row]==0){ // Branch fo header cell
        return cell;
    }
    
    UIImage *CellBackgroundImageBig;
   
    if(indexPath.row!=self.Userlist.count/*-1*/){
         CellBackgroundImageBig = [UIImage imageNamed:@"middle_tableImg@2x.png"];
    } else {
         CellBackgroundImageBig = [UIImage imageNamed:@"end_tableImg@2x.png"];
    }
   
    UIImage *CellBackgroundImage = [[UIImage alloc] initWithCGImage:[CellBackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    UIImageView *im = [[UIImageView alloc] initWithImage:CellBackgroundImage];
    cell.BackgroundView = im;
    [CellBackgroundImage release];
    [im release];
    
    
    [cell.ImortButton setImage:[UIImage imageNamed:@"Btn_import_press@2x.png"] forState:UIControlStateHighlighted]; 
    
    UILabel *importButtonLabl = [[UILabel alloc] initWithFrame:CGRectMake(33, 8, 130, 25)];
    importButtonLabl.backgroundColor = [UIColor clearColor];
    importButtonLabl.text = NSLocalizedString(@"Import", @"");
    importButtonLabl.textColor = [UIColor whiteColor];
    importButtonLabl.textAlignment = UITextAlignmentCenter;
    UIFont *myFontIL = [UIFont fontWithName: @"Helvetica" size: 15.0];
    importButtonLabl.font = myFontIL;
    [cell.ImortButton addSubview:importButtonLabl];
    [importButtonLabl release];
    
    if(self.Userlist){
        WBSAPIUser *user = [self.Userlist objectAtIndex:indexPath.row-1];
        cell.label.text =[user firstname];
        cell.inf = user;
        
        //!!! first row is header cell !!!
        cell.selectButton.tag=indexPath.row-1;
        cell.ImortButton.tag=indexPath.row-1;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectUserTarget = self;
        
        if(delegate.userID==delegate.lastuser && delegate.userID==user.user_id){
            [cell.label setTextColor:[UIColor colorWithRed:235.0f/255.0f green:13.0f/255.0f blue:106.0f/255.0f alpha:1.0]];
            [cell.selectButton setImage:[UIImage imageNamed:@"Icon_swipe_active@2x.png"] forState:UIControlStateNormal];
        }
    }    
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row!=self.Userlist.count || indexPath.row==0)? 44.0 : 53;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0; // ! NO Header
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row]==0) return nil;
    
    return indexPath;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{    
    NSLog(@"didSelectRow %d atSection %d", [indexPath row], [indexPath section]);

//    CustomCell *cell = (CustomCell*)[tableView cellForRowAtIndexPath:indexPath];
//    
//    WBSAPIUser *user = cell.inf;
//    delegate.userID = user.user_id;
//    delegate.userPublicKey = user.publickey;  // publicKey= user.publickey;
//    if(delegate.lastuser!=0 && delegate.lastuser!=delegate.userID){
//         [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"")  message:NSLocalizedString(@"Changed_user",@"")  delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel",@"") otherButtonTitles: NSLocalizedString(@"Ok",@""), nil] autorelease] show];
//    }else {
//        [delegate selectScreenFromMenu:cell];
//        delegate.auth = @"1";
//        [delegate saveModuleData];
//    }

    return;
   
}
 */




- (void)selectCellToImport:(int) t{
    for (int j=0; j<[usersTableView numberOfRowsInSection:0]; j++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j-1 inSection:0];
        CustomCell *custCell = (CustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];
        if(t!=j){ 
            [custCell.ImortButton setHidden:TRUE];
            [custCell.selectButton setHidden:FALSE];
            [custCell.label setTextColor:[UIColor colorWithRed:89.0f/255.0f green:93.0f/255.0f blue:99.0f/255.0f alpha:1.0]];
            [custCell.selectButton setImage:[UIImage imageNamed:@"Icon_swipe_norm@2x.png"] forState:UIControlStateNormal];
        }
    }
}

- (void) checkAndTurnOnNotification{
    WorkWithWithings *notifyWork = [[WorkWithWithings alloc] init];
    notifyWork.user_id = delegate.userID;
    notifyWork.user_publickey = delegate.userPublicKey;
    NSDictionary *resultOfCheck = [notifyWork getNotificationStatus];
    BOOL resultRevokeNotify;
    
    if (resultOfCheck!=nil){
        int expires = [[resultOfCheck objectForKey:@"date"] intValue];
        int status = [[resultOfCheck objectForKey:@"status"] intValue];
        int time_Now = [[NSDate date] timeIntervalSince1970];
        if(status == 434 || expires < time_Now){
            resultRevokeNotify = [notifyWork getNotificationSibscribeWithComment:@"" andAppli:1];
            if(resultRevokeNotify){
                //notify = @"1";
                [[[[UIAlertView alloc] initWithTitle: @"" message:@"Рассылка нотификаций успешно включена" delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease] show]; 
            }
        }
    }
    [notifyWork release];
}



- (void) clickCellImportButton:(int) sender{
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender+1 inSection:0];
    CustomCell *cell = (CustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];
    
    WBSAPIUser *user = cell.inf;
    delegate.userID = user.user_id;
    delegate.user_firstname = user.firstname;
    delegate.userPublicKey = user.publickey;  // publicKey= user.publickey;
    // [self checkAndTurnOnNotification];
    if(delegate.lastuser!=0 && delegate.lastuser!=delegate.userID){
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"")  message:NSLocalizedString(@"Changed_user",@"")  delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel",@"") otherButtonTitles: NSLocalizedString(@"Ok",@""), nil] autorelease] show];
    }else {
        [delegate selectScreenFromMenu:cell];
        delegate.auth = @"1";
        [delegate saveModuleData];
    }
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0){
       
    }else {
        UIButton *button = [[UIButton alloc] init];
        button.tag = 1;
        [delegate selectScreenFromMenu:button];
        [button release];
        delegate.auth = @"1";
        [delegate saveModuleData];
    }
}

- (IBAction)exitButtonClick:(id)sender { 
    [mainSelectionUserView setHidden:true];
    [mainHostLoginView setHidden:false];
    [mainSelectionUserView removeFromSuperview];
    delegate.auth = @"0";
}

-(void) cleanup {  
    [mainHostLoginView setHidden:false];
    [mainSelectionUserView setHidden:true];
    [mainSelectionUserView removeFromSuperview];
    passwordTextField.text = @"";
    delegate.auth = @"0";
    
    [(NSMutableArray*)delegate.listOfUsers removeAllObjects];
    delegate.listOfUsers = nil;    
    [delegate saveModuleData];
    
    NSMutableArray *deletedRows = [[NSMutableArray alloc] init];
    for(int i=0;i<[self.usersTableView numberOfRowsInSection:0]-1;i++){
        [deletedRows addObject:[NSIndexPath indexPathForRow:i+1 inSection:0]];
    }
    [(NSMutableArray*)self.Userlist removeAllObjects];
    self.Userlist = nil;
    [self.usersTableView deleteRowsAtIndexPaths:deletedRows withRowAnimation:UITableViewRowAnimationNone];
    [deletedRows release];
    [self.usersTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    [exitButton release];
    [usersTableView release];
    [mainSelectionUserView release];
    [mainHostLoginView release];
    [ErrorLabel release];
    [singInLabel release];
    [super dealloc];
}

@end
