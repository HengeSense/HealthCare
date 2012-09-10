//
//  AllAdvicesView.m
//  SelfHub
//
//  Created by Igor Barinov on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AllAdvicesView.h"

@interface AllAdvicesView ()

@end

@implementation AllAdvicesView
@synthesize delegate;
@synthesize mainAdviceView;


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
    mainAdviceView.layer.cornerRadius = 10.0;
//   UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://vitaportal.ru/sites/default/files/81266444.jpg"]]];
//     
//    [mainAdviceView addSubview:[[UIImageView alloc] initWithImage:image]];
    
    
}

- (void)viewDidUnload
{
    delegate = nil;
    [self setMainAdviceView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    
    [mainAdviceView release];
    [super dealloc];
}

@end
