
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
    
    NSString *tempFolder;
    NSString *yourFriendsEmailString;
	NSString *combinedPasswordString;
	int numberOfUsers;
	int yourFriendsPassphrase;	
	NSString *yourFriendsPassphraseString;

}

//@property (atomic, strong) IBOutlet NSTextField *yourPassword;
@property (atomic, strong) NSString *sourceFolderPath;
@property (atomic, strong) NSString *destFolderPath;
@property (atomic, assign) BOOL lastEncryptionStatus;
@property (atomic, assign) BOOL encryptionInProcess;
@property (atomic, assign) BOOL keychainHasPassphrase;
@property (atomic, strong) NSString *passphraseFromKeychain;

-(IBAction)encrypt:(id)sender;
-(IBAction)shareCheckClicked:(id)sender;
-(IBAction)startIt:(id)sender;
-(void)setPassphraseTextField:(NSString*)string;


@end
