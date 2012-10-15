//
//  LoginWithingsViewController.m
//  SelfHub
//
//  Created by Anton on 10.10.12.
//
//

#import "LoginWithingsViewController.h"

@interface LoginWithingsViewController ()
    @property (nonatomic, retain) NSArray *Userlist;
@end

@implementation LoginWithingsViewController

@synthesize headerLabel;
@synthesize passwordView, passwordLabel, passwordTextField;
@synthesize actView, activity, actLabel;
@synthesize loginView, loginLabel, loginTextField, loginButton;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [mainSelectionUserView setHidden:true];
    [mainHostLoginView setHidden:false];
}

- (void)viewDidUnload
{
    [self setHeaderLabel:nil];
    [self setLoginButton:nil];
    [self setPasswordView:nil];
    [self setPasswordLabel:nil];
    [self setPasswordTextField:nil];
    [self setLoginView:nil];
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
    [super viewDidUnload];
}



- (BOOL) checkCorrFillField:(NSString *)str : (NSString *)regExpr {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExpr options:NSRegularExpressionSearch error:&error];
    NSArray *matches = [regex matchesInString:str options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, str.length)];
    
    NSLog(@"match loc: %d", matches.count);
    
    if (error) {
        NSLog(@"%@", error);
        return NO;
    } else {
        return (matches.count==0)? YES : NO;
    }
}

- (IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder];
}


-(IBAction) registrButtonClick :(id)sender{
    
    ///  [self hideKeyboard];
    NSLog(@"click");
    //////////// удалить ////////////////
   // if(self.loginTextField.text == @""){
      self.loginTextField.text = @"bis@hintsolutions.ru";
      self.passwordTextField.text =  @"AllSystems1";
    // } ////////// удалить//////////
    if (![self.loginTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] &&![self checkCorrFillField:self.loginTextField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"]){
        
        WorkWithWithings *user = [[WorkWithWithings alloc] init];
        user.account_email = self.loginTextField.text;
        user.account_password = self.passwordTextField.text;
        
        self.Userlist = [user getUsersListFromAccount];

        if( self.Userlist == NULL ||[self.Userlist count] == 0){
            NSLog(@"неверный логин или пароль");
           //TODO : дописать обработку неверного ввода логина или пароля
            user.account_email = nil;
            user.account_password = nil;
            [user release];
        }else{

          //  open view table
            [self.view addSubview:mainSelectionUserView];
            [mainSelectionUserView setHidden:false];
            [mainHostLoginView setHidden:true];
            
            user.account_email = nil;
            user.account_password = nil;
            [user release];
        }
        // */
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.Userlist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell==nil){                
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        for(id oneObject in nibs){
            if([oneObject isKindOfClass:[CustomCell class]] && [[oneObject reuseIdentifier] isEqualToString:@"Cell"]){
                cell = (CustomCell *)oneObject;
            };
        };
    };
    
    
    WBSAPIUser *user = [self.Userlist objectAtIndex:indexPath.row];
    cell.label.text =[user firstname];
    cell.inf = user;
    return cell;
}


#pragma mark - UITableViewDelegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{    
    NSLog(@"didSelectRow %d atSection %d", [indexPath row], [indexPath section]);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([indexPath row]==0) {
       [delegate selectScreenFromMenu:cell];
    };
    return;
   
}

- (IBAction)exitButtonClick:(id)sender { 
    [mainSelectionUserView setHidden:true];
    [mainHostLoginView setHidden:false];
    [mainSelectionUserView removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [headerLabel release];
    [loginButton release];
    [passwordView release];
    [passwordLabel release];
    [passwordTextField release];
    [loginView release];
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
    [super dealloc];
}

@end
