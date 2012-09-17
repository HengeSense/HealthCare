//
//  LoadViewController.h
//  SelfHub
//
//  Created by Igor Barinov on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Medarhiv.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Htppnetwork.h"
#import <CommonCrypto/CommonHMAC.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@class Medarhiv;

@interface LoadViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{
    
}


@property (nonatomic, assign) Medarhiv *delegate;

@property (nonatomic, retain) IBOutlet UILabel *fioLabel;
@property (nonatomic, retain) IBOutlet UITextField *typeDoc;
@property (nonatomic, retain) IBOutlet UIImageView *imageDoc;
@property (nonatomic, retain) IBOutlet UIButton *loadDocButton;
@property (nonatomic, retain) IBOutlet UIProgressView *progressDoc;
@property (nonatomic, retain) IBOutlet UIView *hostView;
@property (retain, nonatomic) IBOutlet UIImageView *tableViewImageView;
@property (retain, nonatomic) IBOutlet UIImageView *manTableviewImage;
@property (retain, nonatomic) IBOutlet UIImageView *docTableviewImage;
@property (retain, nonatomic) IBOutlet UILabel *uploadLabel;
@property (retain, nonatomic) IBOutlet UIImageView *cloudImage;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)loadDocPressed:(id)sender;
-(NSMutableData *) addParameterName:(NSString*)name andValue:(NSString*)val To:(NSMutableData*)body with:(NSString*) boundary;
- (NSString *)SHA256_HASH:(NSData*)img;
-(NSString*)sha256HashFor:(NSString*)input;
-(void) cleanup;



@end
