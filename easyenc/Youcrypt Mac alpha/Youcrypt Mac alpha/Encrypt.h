
#import <Cocoa/Cocoa.h>

@interface Encrypt :NSWindowController{
	IBOutlet NSTextField *yourEmail;
	IBOutlet NSTextField *yourPassword;
	IBOutlet NSTextField *yourFriendsEmail;

    BOOL encryptionInProcess;
    BOOL lastEncryptionStatus;
	NSString *sourceFolderPath;
    NSString *destFolderPath;
}

@property (atomic, strong) NSString *sourceFolderPath;
@property (atomic, strong) NSString *destFolderPath;
@property (atomic, assign) BOOL lastEncryptionStatus;
@property (atomic, assign) BOOL encryptionInProcess;


-(IBAction)encrypt:(id)sender;
-(void)createDirectoryRecursivelyAtPath:(NSString*)path;
-(NSString*)createDestFolder:(NSString*)basepath sourcepath:(NSString*)srcpath;






@end
