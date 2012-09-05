//
//  LoadViewController.m
//  SelfHub
//
//  Created by Elena Trishina on 7/13/12.
//  Copyright (c) 2012 __HintSolutions__. All rights reserved.
//

#import "LoadViewController.h"


@interface LoadViewController ()
- (void)requestFailed:(ASIFormDataRequest *)request;
- (void)request:(ASIHTTPRequest *)theRequest didSendBytes:(long long)newLength;
- (void)requestFailed:(ASIFormDataRequest *)request;
@end

@implementation LoadViewController
@synthesize tableViewImageView;
@synthesize manTableviewImage;
@synthesize docTableviewImage;
@synthesize uploadLabel;
//, receivedData, response, filesize;

@synthesize delegate;
@synthesize fioLabel, typeDoc;
@synthesize imageDoc, loadDocButton, progressDoc, hostView;

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
    
    [self.view addSubview:hostView];
    
    fioLabel.text = delegate.user_fio;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"medarhiv_background.png"]];
    hostView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"medarhiv_background.png"]];

    [self.loadDocButton setImage:[UIImage imageNamed:@"load_press@2x.png"] forState:UIControlStateHighlighted];
    [self.loadDocButton setImage:[UIImage imageNamed:@"load_disable@2x.png"] forState:UIControlStateDisabled];
    
}


-(void) viewDidAppear:(BOOL)animated{
    fioLabel.text = delegate.user_fio;
    
}

- (void)viewDidUnload
{
    [self setTableViewImageView:nil];
    [self setManTableviewImage:nil];
    [self setDocTableviewImage:nil];
    [self setUploadLabel:nil];
    [super viewDidUnload];
    delegate = nil;
    fioLabel = nil;
    typeDoc = nil;
    imageDoc = nil;
    loadDocButton = nil; 
    progressDoc = nil; 
    hostView = nil;
    
}

// touch imageView
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ([touch view] == imageDoc){
        [progressDoc setHidden:true];
        
        [imageDoc setFrame:CGRectMake(100, 131, 118, 175)];
        [imageDoc setImage:[UIImage imageNamed:@"voidFotoForLoadController.png"]];
        [uploadLabel setHidden:true];
        
        BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        if(hasCamera) {
            NSArray *media = [UIImagePickerController
                              availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
            
            if ([media containsObject:(NSString*)kUTTypeImage] == YES) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = hasCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary; 
                
                //picker.cameraCaptureMode = UIImagePickerControllerSourceTypePhotoLibrary;
                [picker setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeImage]];
                
                picker.delegate = self;
                [self presentModalViewController:picker animated:YES];
                //[picker release];
            }
            else {
                [[[[UIAlertView alloc] initWithTitle:@"Unsupported!"
                                             message:@"Camera does not support photo capturing."
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] autorelease] show];
            }
            
            
        } else {
            [[[[UIAlertView alloc] initWithTitle:@"Unavailable!"
                                         message:@"This device does not have a camera."
                                        delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil]autorelease] show];
            
        }
        
    }    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
       
        UIImage *photoTaken = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        //Save Photo to library only if it wasnt already saved i.e. its just been taken
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(photoTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            imageDoc.image = photoTaken; 
            [loadDocButton setEnabled:true];
            
        }
        
        
    }
    CGRect frame = self.view.frame;
    [picker dismissModalViewControllerAnimated:YES];
    self.view.frame = frame;
    [picker release];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [[[[UIAlertView alloc] initWithTitle:@"Error!"
                                     message:[error localizedDescription]
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]autorelease] show];
        
    }    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    CGRect frame = self.view.frame;
    [picker dismissModalViewControllerAnimated:YES];
    self.view.frame = frame;
    [picker release];
}



-(void)dealloc{
    [tableViewImageView release];
    [manTableviewImage release];
    [docTableviewImage release];
    [uploadLabel release];
    
    [fioLabel release];
    [typeDoc release];
    [imageDoc release];
    [loadDocButton release]; 
    [progressDoc release]; 
    [hostView release];
    
    [super dealloc];

};

- (IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder]; 
}

-(NSString*)sha256HashFor:(NSString*)input
{   
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}


- (NSString *)SHA256_HASH:(NSData*)img 
{
   
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    if ( CC_SHA256([img bytes], [img length], hash) ) {
        NSData *sha2 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH]; 
        
        // description converts to hex but puts <> around it and spaces every 4 bytes
        NSString *hash = [sha2 description];
        hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
        hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
        hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
                
        // Format SHA256 fingerprint like
        // 00:00:00:00:00:00:00:00:00
        int keyLength=[hash length];
        NSString *formattedKey = @"";
        for (int i=0; i<keyLength; i+=2) {
            NSString *substr=[hash substringWithRange:NSMakeRange(i, 2)];
            if (i!=keyLength-2) 
                substr=[substr stringByAppendingString:@":"];
            formattedKey = [formattedKey stringByAppendingString:substr];
        }
        
        return formattedKey;
    }
    return nil;
}

-(NSMutableData *) addParameterName:(NSString*)name andValue:(NSString*)val To:(NSMutableData*)body with:(NSString*) boundary
{
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSWindowsCP1251StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", name] dataUsingEncoding:NSWindowsCP1251StringEncoding]];
    [body appendData:[val dataUsingEncoding:NSWindowsCP1251StringEncoding]];
    [body appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSWindowsCP1251StringEncoding]];
    
    return body;
}

- (IBAction)loadDocPressed:(id)sender {
    [progressDoc setHidden:false];
    [progressDoc setProgress:0.0];
    
    if([typeDoc.text isEqualToString:@""]){
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"")
                                     message:NSLocalizedString(@"shot_title_empty", @"")
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]autorelease] show];
    }else {
       
        
        [loadDocButton setEnabled:false];
        [imageDoc setUserInteractionEnabled:false];
        [typeDoc setUserInteractionEnabled:false];
        
        [uploadLabel setHidden:false];
        [uploadLabel setText:@"Загрузка 0%"];
       
        
        NSURL *signinrUrl = [NSURL URLWithString:@"https://medarhiv.ru"];

        ASIFormDataRequest *requestLoadImMedarhiv = [ASIFormDataRequest requestWithURL:signinrUrl];
        NSString *boundary = @"---------------------------168072824752491622650073"; 
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [requestLoadImMedarhiv addRequestHeader:@"Content-Type" value:contentType];
        [requestLoadImMedarhiv setTimeOutSeconds:60];
        
        [requestLoadImMedarhiv setDelegate:self];
        [requestLoadImMedarhiv setDidFailSelector:@selector(requestFailed:)];
        [requestLoadImMedarhiv setDidFinishSelector:@selector(requestFinished:)];
      
        
        NSData *imageData = UIImagePNGRepresentation(imageDoc.image);        
    
        
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
        [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
        
      
        [requestLoadImMedarhiv setPostValue:@"srv" forKey:@"cmd"];
        [requestLoadImMedarhiv setPostValue:@"shot" forKey:@"action"];
        [requestLoadImMedarhiv setPostValue:delegate.user_id forKey:@"userID"];
        [requestLoadImMedarhiv setPostValue:[self sha256HashFor:[delegate.user_login stringByAppendingString:delegate.user_pass]] forKey:@"userHash"];
        [requestLoadImMedarhiv setData:imageData withFileName:@"image.jpg" andContentType:@"image/png" forKey:@"imgData"];
        [requestLoadImMedarhiv setPostValue:[self SHA256_HASH:imageData] forKey:@"imgHash"];
        [requestLoadImMedarhiv setPostValue:@"1" forKey:@"utf8"];
        [requestLoadImMedarhiv setPostValue:[[typeDoc.text stringByAppendingString:@"_"] stringByAppendingString:[dateFormatter stringFromDate:currentDate]]  forKey:@"title"];
        [requestLoadImMedarhiv setPostValue:[dateFormatter stringFromDate:currentDate] forKey:@"time"];

       
        [requestLoadImMedarhiv setRequestMethod:@"POST"];
        [requestLoadImMedarhiv setUploadProgressDelegate: self];
        [requestLoadImMedarhiv setShowAccurateProgress:YES];

        [requestLoadImMedarhiv startAsynchronous];
        
    }
}

- (void)request:(ASIHTTPRequest *)theRequest didSendBytes:(long long)newLength {
        
    if ([theRequest totalBytesSent] > 0) {
        float progressAmount = ((float)[theRequest totalBytesSent]/(float)[theRequest postLength]);
        progressDoc.progress = progressAmount;
        
        int forLoadLabel = (int)((progressAmount*100) - 0.5);
        [uploadLabel setText:[NSString stringWithFormat:@"Загрузка %@%@",[NSString stringWithFormat:@"%i", forLoadLabel],@"%"]];
    }
} 


- (void)requestFinished:(ASIFormDataRequest *)request
{
   
    NSData *responseData = [request responseData];
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    if ([[res objectForKey:@"result"] intValue]==1){
        NSLog(@"key: %@", res);
        [imageDoc setFrame:CGRectMake(80, 131, 144, 145)];
        [imageDoc setImage:[UIImage imageNamed:@"succFotoForLoadController.png"]];
        [uploadLabel setText:@"Загрузка 100%"];
        [imageDoc setUserInteractionEnabled:true];
        [typeDoc setUserInteractionEnabled:true];
        
    } else { 
        NSLog(@"key: %@", res);
        NSString *errorsForAlert= @"\n ";
        NSArray *listOfErrors = (NSArray *)[res objectForKey:@"error"];
        for (NSString *err in listOfErrors) {
            errorsForAlert = [NSLocalizedString(@"Upload_fail",@"") stringByAppendingString: [[errorsForAlert stringByAppendingString:NSLocalizedString(err,@"")] stringByAppendingString:@"\n "]];
        }
        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"")  message:errorsForAlert  delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel",@"") otherButtonTitles: NSLocalizedString(@"Try again",@""), nil] autorelease] show];
        return;         
    }
}

- (void)requestFailed:(ASIFormDataRequest *)request
{
  //  NSError *error = [request error];
    [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"")  message:NSLocalizedString(@"Upload_fail",@"")  delegate: self cancelButtonTitle: NSLocalizedString(@"Cancel",@"") otherButtonTitles: NSLocalizedString(@"Try again",@""), nil] autorelease] show];
    return; 
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0){
        [progressDoc setHidden:true];
        [uploadLabel setHidden:false];
        [imageDoc setFrame:CGRectMake(100, 131, 118, 175)];
        [imageDoc setImage:[UIImage imageNamed:@"voidFotoForLoadController.png"]];    
        [imageDoc setUserInteractionEnabled:true];
        [typeDoc setUserInteractionEnabled:true];
        [uploadLabel setHidden:true];
    }else {
        [self loadDocPressed:nil];
    }
}

-(void) cleanup {
    [progressDoc setHidden:true];
    [uploadLabel setHidden:false];
    [imageDoc setFrame:CGRectMake(100, 131, 118, 175)];
    [imageDoc setImage:[UIImage imageNamed:@"voidFotoForLoadController.png"]];    
    [imageDoc setUserInteractionEnabled:true];
    [typeDoc setUserInteractionEnabled:true];
    typeDoc.text = @"";
    fioLabel.text = @"";
    [uploadLabel setHidden:true];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end


