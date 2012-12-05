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
@synthesize cloudImage;
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

    [self.loadDocButton setImage:[UIImage imageNamed:@"load_press@2x.png"] forState:UIControlStateHighlighted];
    [self.loadDocButton setImage:[UIImage imageNamed:@"load_disable@2x.png"] forState:UIControlStateDisabled];
    
    UIView *springView  = [[UIView alloc] initWithFrame:CGRectMake(0, -2, 320, 13)];
    [self.view addSubview:springView];
    UIImage *springImBig = [UIImage imageNamed:@"spring@2x.png"];
    UIImage *springIm = [[UIImage alloc] initWithCGImage:[springImBig CGImage] scale:2.0 orientation:UIImageOrientationUp];
    [springView setBackgroundColor:[UIColor colorWithPatternImage:springIm]];
    [springIm release];
    [springView release];
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
    [self setCloudImage:nil];
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
        [loadDocButton setHidden:false];
        [imageDoc setFrame:CGRectMake(88, 138, 144, 184)];
        [imageDoc setImage:[UIImage imageNamed:@"voidFotoForLoadController.png"]];
        [uploadLabel setHidden:true];
        [cloudImage setHidden:true];
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select photo:", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", @""), NSLocalizedString(@"Library", @""), nil] autorelease];
        [actionSheet showInView:self.view];
        //[actionSheet showFromRect:CGRectMake(0, 44, 320, 44) inView:self.view.superview animated:YES];
        //UIView *v = self.view.superview;
    }    
}
#pragma mark UIActionSheet delegate functions

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //[actionSheet release];
    
    if(buttonIndex==2) return;
   
    UIImagePickerControllerSourceType imagePickType;
   
    switch(buttonIndex){
        case 0:
            imagePickType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            imagePickType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            imagePickType = UIImagePickerControllerSourceTypeCamera;
            break;
    };
    
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if(imagePickType == UIImagePickerControllerSourceTypeCamera && !hasCamera) {
        [[[[UIAlertView alloc] initWithTitle:@"Unavailable!"
                                     message:@"This device does not have a camera."
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]autorelease] show];
        return;
    }
    
    NSArray *media = [UIImagePickerController availableMediaTypesForSourceType: imagePickType];
    
    if (imagePickType == UIImagePickerControllerSourceTypeCamera && [media containsObject:(NSString*)kUTTypeImage] == NO) {
        [[[[UIAlertView alloc] initWithTitle:@"Unsupported!"
                                     message:@"Camera does not support photo capturing."
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] autorelease] show];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType = imagePickType; 
    picker.wantsFullScreenLayout = YES;
    [picker setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeImage]];
   
    //UINavigationBar *bar = picker.navigationBar;
    //[bar setHidden:NO];
    //UINavigationItem *top = bar.topItem;
    //UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(imagePickerControllerDidCancel:)];
    //[top setRightBarButtonItem:cancel];
        
    
    // Edited by Evgen: you present view controller at host view (which have 320x436 px sizes),
    // that's why top navigation bar (of presented view controller) is shown, but isn't interact with user.
    // And all events are delegates for undelayered view. You should present picker view controller at parent view controller
    [/*self*/delegate presentModalViewController:picker animated:YES];
};
  


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
       
        UIImage *photoTaken = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        //Save Photo to library only if it wasnt already saved i.e. its just been taken
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(photoTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        imageDoc.image = photoTaken; 
        [loadDocButton setHidden:false];
        
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
    
    [cloudImage release];
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
    [body appendData:[@"\r\n" dataUsingEncoding:NSWindowsCP1251StringEncoding]];
    
    return body;
}

- (IBAction)loadDocPressed:(id)sender {
    
    
    if([typeDoc.text isEqualToString:@""]){
       typeDoc.text = @" ";
    }
        [progressDoc setHidden:false];
        [progressDoc setProgress:0.0];
        
        [loadDocButton setHidden:true];
        [imageDoc setUserInteractionEnabled:false];
        [typeDoc setUserInteractionEnabled:false];
        
        [uploadLabel setHidden:false];
        [uploadLabel setText:@"Загрузка 0%"];
        [cloudImage setHidden:false];
        
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
        [imageDoc setFrame:CGRectMake(88, 138, 144, 145)];
        [imageDoc setImage:[UIImage imageNamed:@"succFotoForLoadController.png"]];
        [uploadLabel setText:@"Загрузка 100%"];
        [imageDoc setUserInteractionEnabled:true];
        [typeDoc setUserInteractionEnabled:true];
        
    } else { 
        NSLog(@"key: %@", res);
        [uploadLabel setText:@"Не удалось загрузить"];
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
        [loadDocButton setHidden:false];
        [progressDoc setHidden:true];
        [cloudImage setHidden:true];
        [imageDoc setFrame:CGRectMake(88, 138, 144, 184)];
        [imageDoc setImage:[UIImage imageNamed:@"voidFotoForLoadController.png"]];    
        [imageDoc setUserInteractionEnabled:true];
        [typeDoc setUserInteractionEnabled:true];
        [uploadLabel setHidden:true];
    }else {
        [self loadDocPressed:nil];
    }
}

-(void) cleanup {
    [loadDocButton setHidden:false];
    [progressDoc setHidden:true];
    [cloudImage setHidden:true];
    [imageDoc setFrame:CGRectMake(88, 138, 144, 184)];
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


