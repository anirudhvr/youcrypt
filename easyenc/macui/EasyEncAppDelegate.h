
#import <Cocoa/Cocoa.h>

@interface SpeakLineAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSTextField *yourEmail;
	IBOutlet NSTextField *yourPassword;
	IBOutlet NSTextField *yourFriendsEmail;
	NSString *type;
	NSString *filePath;
	
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)apply:(id)sender;

@end
