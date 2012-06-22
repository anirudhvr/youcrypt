
#import <Cocoa/Cocoa.h>

@interface Encrypt :NSWindowController{
	IBOutlet NSTextField *yourPassword;
	IBOutlet NSTextField *yourFriendsEmail;

    BOOL encryptionInProcess;
    BOOL lastEncryptionStatus;
	NSString *sourceFolderPath;
    NSString *destFolderPath;

    IBOutlet NSButton *shareCheckBox;
	NSString *filePath;
    IBOutlet NSProgressIndicator *encryptProgress;
    BOOL keychainHasPassphrase;
    NSString *passphraseFromKeychain;
}

@property (atomic, strong) IBOutlet NSTextField *yourPassword;
@property (atomic, strong) NSString *sourceFolderPath;
@property (atomic, strong) NSString *destFolderPath;
@property (atomic, assign) BOOL lastEncryptionStatus;
@property (atomic, assign) BOOL encryptionInProcess;
@property (atomic, assign) BOOL keychainHasPassphrase;


-(IBAction)encrypt:(id)sender;
-(void)createDirectoryRecursivelyAtPath:(NSString*)path;
-(NSString*)createDestFolder:(NSString*)basepath sourcepath:(NSString*)srcpath;

-(IBAction)shareCheckClicked:(id)sender;
-(IBAction)startIt:(id)sender;
- (NSString*) getPassphraseFromKeychain;
- (BOOL)registerWithKeychain:(NSString*)passphrase;

@end
