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
@property (nonatomic, readwrite) int selectImpCell;
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
        return nil;
    }
    NSMutableArray *parsed_users = [[[NSMutableArray alloc] init] autorelease];
    
	for (int i=0; i < [massUsers count]; i++){
		id user_i_o = [massUsers objectAtIndex:i];
		if (![user_i_o isKindOfClass:[NSDictionary class]]) {
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

//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//}


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
    
    [loginButton addSubview:loginButtonLabl];
    [loginButtonLabl release]; 
    
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
    
    [self backgroundTouched:nil];
    NetworkStatus curStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(curStatus != NotReachable){     
        if (![self.loginTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] &&![self checkCorrFillField:self.loginTextField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"]){
            WorkWithWithings *user = [[[WorkWithWithings alloc] init] autorelease];
            user.account_email = self.loginTextField.text;
            user.account_password = self.passwordTextField.text;
            [self showActiveView];
            Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self action:@selector(handleResultOrError:) context:nil] autorelease];
            
            NSURLConnection *conn = [NSURLConnection connectionWithRequest:[user getUsersListFromAccountAsynch] delegate:network];
            [conn start];
            user.account_email = nil;
            user.account_password = nil;
        }else{
            [ErrorLabel setText: NSLocalizedString(@"Wrong username or password.", @"")];
            [ErrorLabel setHidden: false];
        }
    }else {
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];
    }
}

- (void)handleResultOrError:(id)resultOrError
{
    if (resultOrError==nil){
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"Query_fail",@"") delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];
		return; 
	}
    
	
    int status;
    NSError *myError = nil;
    NSData *data = [resultOrError objectForKey:@"data"];
    NSDictionary *repr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    if (repr==nil){
        [ErrorLabel setText: NSLocalizedString(@"db_connection_fail", @"")];
        [ErrorLabel setHidden: false];
        [self hideActiveView];
        return;
    }
    
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){
        if(status==100){
            [ErrorLabel setText: NSLocalizedString(@"Wrong username or password.", @"")];
        }else {
            [ErrorLabel setText: NSLocalizedString(@"db_connection_fail", @"")];
        }        
        [ErrorLabel setHidden: false];
        [self hideActiveView];
        return;
	} 
    
    NSArray *users = (NSArray *)[[repr objectForKey:@"body"] objectForKey:@"users"];
    
    if ([users count] < 1){
        [ErrorLabel setText: NSLocalizedString(@"No data", @"")];
        [ErrorLabel setHidden: false];
        [self hideActiveView];
        return; 
    }
    NSMutableArray *parsed_users = [[[NSMutableArray alloc] init] autorelease];
    
	for (int i=0; i < [users count]; i++){
		id user_i_o = [users objectAtIndex:i];
		if (![user_i_o isKindOfClass:[NSDictionary class]]) {
            [ErrorLabel setText: NSLocalizedString(@"db_connection_fail", @"")];
            [ErrorLabel setHidden: false];
            [self hideActiveView];
            return;
        }
		WBSAPIUser *singleUser = [[[WBSAPIUser alloc] init] autorelease];
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
	}
    
    self.Userlist = parsed_users;
    
    if(self.Userlist == NULL ||[self.Userlist count] == 0){
        [ErrorLabel setText: NSLocalizedString(@"db_connection_fail", @"")];
        [ErrorLabel setHidden: false];
        [self hideActiveView];
    }else{
        [ErrorLabel setHidden: true];
        [self.usersTableView reloadData];
        [self.view addSubview:mainSelectionUserView];
        [mainSelectionUserView setHidden:false];
        [mainHostLoginView setHidden:true];
        [delegate.rightBarBtn setEnabled:true];
        delegate.auth = @"1";
        delegate.listOfUsers = [self convertUserListToDict: self.Userlist];
        [delegate saveModuleData];
        [self hideActiveView];
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
    
    WithingsCustomCell *cell = (WithingsCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil){                
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"WithingsCustomCell" owner:self options:nil];
        for(id oneObject in nibs){
            if([oneObject isKindOfClass:[WithingsCustomCell class]] && [[oneObject reuseIdentifier] isEqualToString:cellID]){
                cell = (WithingsCustomCell *)oneObject;
            };
        };
    };
    
    if([indexPath row]==0){ // Branch fo header cell
        return cell;
    }
    
    UIImage *CellBackgroundImageBig;
    
    if(indexPath.row!=self.Userlist.count){
        CellBackgroundImageBig = [UIImage imageNamed:@"middle_tableImg@2x.png"];
    } else {
        CellBackgroundImageBig = [UIImage imageNamed:@"end_tableImg@2x.png"];
    }
    
    UIImage *CellBackgroundImage = [[UIImage alloc] initWithCGImage:[CellBackgroundImageBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    UIImageView *im = [[UIImageView alloc] initWithImage:CellBackgroundImage];
    cell.BackgroundView = im;
    [CellBackgroundImage release];
    [im release];
    
    if(self.Userlist){
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
        
        // geture------    
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveButView:)];
        [panGesture setMaximumNumberOfTouches:2];
        [cell.gestureView addGestureRecognizer:panGesture];
        cell.gestureView.tag = indexPath.row;
        [panGesture release];
        cell.gestureViewhide.tag = indexPath.row;
        //-------   
        
        WBSAPIUser *user = [self.Userlist objectAtIndex:indexPath.row-1];
        cell.label.text =[user firstname];
        cell.inf = user;
        
        // first row is header cell 
        cell.selectButton.tag=indexPath.row;
        cell.ImortButton.tag=indexPath.row;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectUserTarget = self;
        
        if(user.user_id==delegate.lastuser){
            selectImpCell = indexPath.row;
            [self selectDesignCell:cell];
        }
    }    
    
    return cell;
}


- (void) moveButHide:(int)gestureTag{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:gestureTag inSection:0];
    WithingsCustomCell *custCell = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];
    
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
    [custCell.gestureView.layer renderInContext:UIGraphicsGetCurrentContext()];    
    UIGraphicsEndImageContext();
    
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [custCell.gestureView setFrame:CGRectMake([custCell.gestureView frame].origin.x, 0, 165, custCell.gestureView.frame.size.height)];
    }completion:^(BOOL finished){            
    }]; 
};

-(void)moveButView:(UIPanGestureRecognizer *)gesture
{
    UIView *piece = [gesture view];
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        [self selectCellToImport: gesture.view.tag];
        CGSize viewSize = piece.bounds.size;
        UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
        [piece.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIGraphicsEndImageContext();
        [piece setCenter:CGPointMake([piece center].x,[piece center].y)];
        [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [piece setFrame:CGRectMake([piece frame].origin.x, [piece frame].origin.y, 0, [piece frame].size.height)];
        }completion:^(BOOL finished){
            
        }];
        [gesture setTranslation:CGPointZero inView:[piece superview]];
    }
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


- (void)selectCellToImport:(int) t{
    for (int j=1; j<[usersTableView numberOfRowsInSection:0]; j++) {
        if(j!=t){            
            [self moveButHide:j];
        }
    }
}



- (void) clickCellImportButton:(int) sender{
    NetworkStatus curStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(curStatus != NotReachable){   
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender inSection:0];
        WithingsCustomCell *cell = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];
        
        WBSAPIUser *user = cell.inf;
          
        if(delegate.lastuser!=0 && delegate.lastuser!=user.user_id){
            UIAlertView *alert1 = [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Changed_user",@"") delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel",@"") otherButtonTitles: NSLocalizedString(@"Ok",@""), nil] autorelease];
            [alert1 show];
            [alert1 setTag:sender];
        }else {
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
    }else{
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];
    }
}

-(void) unselectDesignCell{
    WithingsCustomCell *cellUncheck = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectImpCell inSection:0]];
    [cellUncheck.label setTextColor:[UIColor colorWithRed:89.0f/255.0f green:93.0f/255.0f blue:99.0f/255.0f alpha:1.0]];
    [cellUncheck.selectButton setImage:[UIImage imageNamed:@"Icon_swipe_norm@2x.png"] forState:UIControlStateNormal];
}

-(void) selectDesignCell: (WithingsCustomCell*) cell{
    [cell.label setTextColor:[UIColor colorWithRed:235.0f/255.0f green:13.0f/255.0f blue:106.0f/255.0f alpha:1.0]];
    [cell.selectButton setImage:[UIImage imageNamed:@"Icon_swipe_active@2x.png"] forState:UIControlStateNormal];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1){
        UIButton *button = [[UIButton alloc] init];
        button.tag = 1;
        [delegate selectScreenFromMenu:button];
        [button release];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
        WithingsCustomCell *cell = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];
        
        if(selectImpCell!=0){
           [self unselectDesignCell];
        }
        
        [self selectDesignCell:cell];
        selectImpCell = alertView.tag;
        
        if ([delegate.notify isEqualToString:@"1"]){
            [delegate revokeUserNotify];
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
}

-(void) cleanup {  
    [mainHostLoginView setHidden:false];
    [mainSelectionUserView setHidden:true];
    [mainSelectionUserView removeFromSuperview];
    passwordTextField.text = @"";
    delegate.auth = @"0";
    
    for (int j=1; j<[usersTableView numberOfRowsInSection:0]; j++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
        WithingsCustomCell *custCell = (WithingsCustomCell*)[usersTableView cellForRowAtIndexPath:indexPath];
        [self moveButHide:j];
        [custCell.label setTextColor:[UIColor colorWithRed:89.0f/255.0f green:93.0f/255.0f blue:99.0f/255.0f alpha:1.0]];
        [custCell.selectButton setImage:[UIImage imageNamed:@"Icon_swipe_norm@2x.png"] forState:UIControlStateNormal];        
    }
    selectImpCell = 0;
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
    [usersTableView release];
    [mainSelectionUserView release];
    [mainHostLoginView release];
    [ErrorLabel release];
    [singInLabel release];
    [super dealloc];
}

@end
