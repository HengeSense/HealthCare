//
//  ImportWeightFromITunes.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 14.11.12.
//
//

#import "ImportWeightFromITunes.h"

@interface ImportWeightFromITunes ()

@end

@implementation ImportWeightFromITunes

@synthesize delegate, filesTable;

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
    iTunesFiles = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    [self loadFilesFromItunes];
    [filesTable reloadData];
};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    delegate = nil;
    [filesTable release];
    if(iTunesFiles) [iTunesFiles release];
    
    [super dealloc];
};

- (void)loadFilesFromItunes{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    ImportFileType filetype;
    
    [iTunesFiles removeAllObjects];
    NSMutableDictionary *curFileDescriptor;
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:documentsPath];
    for(NSString *path in enumerator){
        curFileDescriptor = [[NSMutableDictionary alloc] init];
        [curFileDescriptor setObject:[path lastPathComponent] forKey:@"filename"];
        [curFileDescriptor setObject:[documentsPath stringByAppendingPathComponent:path] forKey:@"filepath"];
        
        NSArray *fileRecords = [delegate recordsFromFileAsCVS:[documentsPath stringByAppendingPathComponent:path]];
        if([fileRecords count]>0){
            filetype = ImportFileTypeLibra2;
        }else{
            filetype = ImportFileTypeUnknown;
        };
        [curFileDescriptor setObject:[NSNumber numberWithInt:filetype] forKey:@"filetype"];
        [curFileDescriptor setObject:[NSNumber numberWithInt:[fileRecords count]] forKey:@"recordsnum"];
        [curFileDescriptor setObject:fileRecords forKey:@"records"];
        
        float recordsWeight = 0.0;
        for(NSDictionary *curRecord in fileRecords){
            recordsWeight += [[curRecord objectForKey:@"weight"] floatValue];
        };
        if([fileRecords count]>0){
            recordsWeight /= [fileRecords count];
        };
        
        NSString *descriptionStr;
        if(filetype==ImportFileTypeLibra2){
            descriptionStr = [NSString stringWithFormat:@"Format: Libra database v.2, recs: %d (%.1f kg)", [fileRecords count], recordsWeight];
        }else{
            descriptionStr = @"Format: unknown";
        }
        
        [curFileDescriptor setObject:descriptionStr forKey:@"description"];
        
        [iTunesFiles addObject:curFileDescriptor];
        [curFileDescriptor release];
    }
    
};

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
};

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [iTunesFiles count];
};


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier;
    CellIdentifier = @"ImportWeightFromITunesTableCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    };
    
    NSDictionary *curFileDict = [iTunesFiles objectAtIndex:[indexPath row]];
    cell.textLabel.text = [curFileDict objectForKey:@"filename"];
    cell.detailTextLabel.text = [curFileDict objectForKey:@"description"];
    
    return cell;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    currentlySelectedFileNum = [indexPath row];
    
    UIActionSheet *actionSheet;
    if([[[iTunesFiles objectAtIndex:currentlySelectedFileNum] objectForKey:@"filetype"] integerValue]==ImportFileTypeUnknown){
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove file" otherButtonTitles:nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove file" otherButtonTitles:@"Add to base", @"Clear base & add", nil];
    };

    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet delegate functions

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [actionSheet release];
    
    if(buttonIndex==3) return;
    
    NSDictionary *curFileDict = [iTunesFiles objectAtIndex:currentlySelectedFileNum];
    
    UIAlertView *alert;
    switch(buttonIndex){
        case 0:
            [[NSFileManager defaultManager] removeItemAtPath:[curFileDict objectForKey:@"filepath"] error:nil];
            [iTunesFiles removeObjectAtIndex:currentlySelectedFileNum];
            [filesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:currentlySelectedFileNum inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case 1:
            if([actionSheet numberOfButtons]<=2) break;
            [delegate addRecordsToBase:[curFileDict objectForKey:@"records"]];
            alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Records are imported to weight databese! You can show results now" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show results", nil];
            [alert show];
            [alert release];
            break;
        case 2:
            if([actionSheet numberOfButtons]<=2) break;
            [delegate clearBaseAndAddRecords:[curFileDict objectForKey:@"records"]];
            alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Records are imported to weight databese! You can show results now" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show results", nil];
            [alert show];
            [alert release];
            break;
        default:
            break;
    };
    
    
    //[self.delegate presentModalViewController:imagePick animated:YES];
    
};

#pragma mark - UIAlertView delegate functions

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1){
        [delegate.delegate switchToModuleWithID:@"selfhub.weight"];
    };
}




@end
