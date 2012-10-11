//
//  LoginWithingsViewController.m
//  SelfHub
//
//  Created by Anton on 10.10.12.
//
//

#import "LoginWithingsViewController.h"

@interface LoginWithingsViewController ()

@end

@implementation LoginWithingsViewController

@synthesize headerLabel;
@synthesize loginButton;
@synthesize passwordView;
@synthesize passwordLabel;
@synthesize passwordTextField;
@synthesize actView;
@synthesize activity;
@synthesize actLabel;
@synthesize loginView;
@synthesize loginLabel;
@synthesize loginTextField;

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    [super dealloc];
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
        
        
        NSArray *AccountList = [user getUsersListFromAccount];

        if( AccountList == NULL ||[AccountList count] == 0){
            NSLog(@"неверный логин или пароль");
           //TODO : дописать обработку неверного ввода логина или пароля
            user.account_email = nil;
            user.account_password = nil;
            [user release];
        }else{
           
            SelectionUserView *signupViewController = [[SelectionUserView alloc] initWithNibName:@"SelectionUserView" bundle:nil ];
            signupViewController.delegate = self;
        
            [self presentModalViewController:signupViewController animated:NO];
            [signupViewController release];
            
            user.account_email = nil;
            user.account_password = nil;
            [user release];
        }
        // */
    }
    
}

@end
