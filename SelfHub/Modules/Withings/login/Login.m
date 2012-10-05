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

@synthesize  headerLabel, delegate;
@synthesize passwordLabel,passwordTextField,passwordView;
@synthesize loginLabel,loginTextField,loginView;
@synthesize actView,actLabel,activity;


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

-(IBAction) registrButtonClick :(id)sender{
   NSLog(@"click");
}

-(void) activityShow:(id)sender{

}

@end
