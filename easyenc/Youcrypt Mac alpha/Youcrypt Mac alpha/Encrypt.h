
#import <Cocoa/Cocoa.h>

@interface Encrypt :NSWindowController{
	IBOutlet NSTextField *yourPassword;
	IBOutlet NSTextField *yourFriendsEmail;
    IBOutlet NSButton *shareCheckBox;
	NSString *filePath;
    IBOutlet NSProgressIndicator *encryptProgress;
}

-(IBAction)encrypt:(id)sender;
-(void)createDirectoryRecursivelyAtPath:(NSString*)path;
-(IBAction)shareCheckClicked:(id)sender;
-(IBAction)startIt:(id)sender;

@end
