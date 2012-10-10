//
//  Login.m
//  SelfHub
//
//  Created by Anton on 04.10.12.
//
//

#import "Login.h"

@interface Login ()

@end

@implementation Login

@synthesize delegate;
@synthesize  headerLabel,errorIILabel;
@synthesize passwordLabel,passwordTextField,passwordView;
@synthesize loginLabel,loginTextField,loginView;
@synthesize actView,actLabel,activity;

@synthesize tableView;


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

     [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder];
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
        return (matches.count==0)? YES : NO;
    }
}

-(IBAction) registrButtonClick :(id)sender{
    
  ///  [self hideKeyboard];
       NSLog(@"click");
  //  self.loginTextField.text = @"bis@hintsolutions.ru";
  //  self.passwordTextField.text =  @"AllSystems1";
    
    if (![self.loginTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] &&![self checkCorrFillField:self.loginTextField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"]){
        
       // NSLog(@"проверка прошла");
        
        WorkWithWithings *user = [[WorkWithWithings alloc] init];
        user.account_email = self.loginTextField.text;
        user.account_password = self.passwordTextField.text;
        
        NSArray *AccountList = [[NSArray alloc] init ];
        
        AccountList = [user getUsersListFromAccount];
        // [user getNotificationStatus];
        if(AccountList == nil){
            NSLog(@"неверный логин или пароль");
            //CGPoint *point = [[CGPoint alloc ] init ];
            //self.loginButton.center.x = self.loginButton.center.x + 50 ;   //= [[CGpoint alloc] init]
            [AccountList release];
        }else{
           // NSLog(@"получили список");
             [AccountList release];
        }
    }

}

-(void) activityShow:(id)sender{

}

@end
