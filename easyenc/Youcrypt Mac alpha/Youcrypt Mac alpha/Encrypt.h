
#import <Cocoa/Cocoa.h>

@interface Encrypt :NSWindowController{
	IBOutlet NSTextField *yourEmail;
	IBOutlet NSTextField *yourPassword;
	IBOutlet NSTextField *yourFriendsEmail;
	NSString *type;
	NSString *filePath;
}

-(IBAction)encrypt:(id)sender;
-(void)createDirectoryRecursivelyAtPath:(NSString*)path;

@end
