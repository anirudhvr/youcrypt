//
//  AppDelegate.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferenceController.h"
#import "FileSystem.h"
#import "Decrypt.h"
#import "Encrypt.h"
#import "YoucryptService.h"
#import "YoucryptConfigDirectory.h"

#define prefsToolbar @"Prefs"
#define quitToolbar @"Quit"

@implementation AppDelegate

@synthesize window = _window;
@synthesize encryptController;
@synthesize decryptController;
@synthesize configDir;

- (id) init
{
    self = [super init];
    if(self){
        filesystems = [[NSMutableArray alloc] init];
    }
    
    configDir = [[YoucryptConfigDirectory alloc] init];
    youcryptService = [[YoucryptService alloc] init];
    [youcryptService setApp:self];
    
    return self;
}

+ (NSString *) getVolumeDirPath
{

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    // Insert code here to initialize your application
   
    [NSApp setServicesProvider:youcryptService];
    
    NSLog(@"This happened!");
}


- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    return [self processFile:filename];
}

- (BOOL)processFile:(NSString *)file
{
    NSLog(@"The following file has been dropped or selected: %@",file);
    
    [self showDecryptWindow:self];
  
    decryptController.sourceFolderPath = file;
    NSString *dest = [configDir.youCryptVolDir stringByAppendingPathComponent:file];
    decryptController.destFolderPath = dest;
    
    return  YES; // Return YES when file processed succesfull, else return NO.
}


-(void)awakeFromNib{
    
    // status icon
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"YC"];
    [statusItem setHighlightMode:YES];

    // toolbar
    toolbar = [[NSToolbar alloc] initWithIdentifier:@"tooltest"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES]; 
    
    [_window setToolbar:toolbar];
    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	NSString *type = [[NSString alloc] init];
    
	for (id arg in arguments) {
		if([arg isEqualToString:@"-d"]) {
			type = @"D"; // decrypt
		}
		else if([arg isEqualToString:@"-e"]) {
			type = @"E"; // encrypt
		}
        else if([arg isEqualToString:@"-m"]) {
            type = @"M";
        }
        else if([arg isEqualToString:@"-p"]) {
            type = @"P";
        }
        else type = @"M";
	}
    
    type = @"X";
    
    if([type isEqualToString:@"M"])
        [self showMainApp:self];
    
    else if([type isEqualToString:@"E"])
        [self showEncryptWindow:self];
    
    else if([type isEqualToString:@"D"])
        [self showDecryptWindow:self];
    
    else if ([type isEqualToString:@"P"])
        [self showPreferencePanel:self];
    
}


-(IBAction)windowShouldClose:(id)sender
{
    NSLog(@"Closing..");
}

-(IBAction)showMainApp:(id)sender
{
    [self.window makeKeyAndOrderFront:self];
}

- (IBAction)terminateApp:(id)sender
{
    [NSApp terminate:nil];
}

- (void)setFilesystems:(NSMutableArray *)f
{
    // This is an unusual setter method.  We are going to add a lot
    // of smarts to it in the next chapter.
    if (f == filesystems)
        return;
    filesystems = f;
}

- (IBAction)showPreferencePanel:(id)sender
{
    // Is preferenceController nil?
    if (!preferenceController) {
        preferenceController = [[PreferenceController alloc] init];
    }
    NSLog(@"showing %@", preferenceController);
    [preferenceController showWindow:self];
}

- (IBAction)showDecryptWindow:(id)sender
{
    // Is decryptController nil?
    if (!decryptController) {
        decryptController = [[Decrypt alloc] init];
    }
    NSLog(@"showing %@", decryptController);
    [decryptController showWindow:self];
}

- (IBAction)showEncryptWindow:(id)sender
{
    // Is encryptController nil?
    if (!encryptController) {
        encryptController = [[Encrypt alloc] init];
    }
    NSLog(@"showing %@", encryptController);
    [encryptController showWindow:self];
}

- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
                                       label:(NSString *)label
                                 paleteLabel:(NSString *)paletteLabel
                                     toolTip:(NSString *)toolTip
                                      target:(id)target
                                 itemContent:(id)imageOrView
                                      action:(SEL)action
{
    // here we create the NSToolbarItem and setup its attributes in line with the parameters
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    
    [item setLabel:label];
    [item setPaletteLabel:paletteLabel];
    [item setToolTip:toolTip];
    [item setTarget:target];
    [item setAction:action];
    
    if([imageOrView isKindOfClass:[NSImage class]]){
        [item setImage:imageOrView];
    } 
    else if ([imageOrView isKindOfClass:[NSView class]]){
        [item setView:imageOrView];
    }
    else {
        assert(!"Invalid itemContent: object");
    }
    return item;
}



- (void)toolbarWillAddItem:(NSNotification *)notif
{
    NSToolbarItem *addedItem = [[notif userInfo] objectForKey:@"item"];
    
    // Is this the printing toolbar item?  If so, then we want to redirect it's action to ourselves
    // so we can handle the printing properly; hence, we give it a new target.
    //
    if ([[addedItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier])
    {
        [addedItem setToolTip:@"Print your document"];
        [addedItem setTarget:self];
    }
}  

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
     itemForItemIdentifier:(NSString *)itemIdentifier 
 willBeInsertedIntoToolbar:(BOOL)flag

{
    NSToolbarItem *toolbarItem = nil;
    
    // We create and autorelease a new NSToolbarItem, and then go through the process of setting up its
    // attributes from the master toolbar item matching that identifier in our dictionary of items.
    if ([itemIdentifier isEqualToString:prefsToolbar]) {
            toolbarItem = [self toolbarItemWithIdentifier:prefsToolbar
                                                label:@"Preferences"
                                          paleteLabel:@"Preferences"
                                              toolTip:@"Open Preferences"
                                               target:self
                                          itemContent:[NSImage imageNamed:@"Settings.png"]
                                               action:@selector(showPreferencePanel:)
                           ];   
    }
    else if ([itemIdentifier isEqualToString:quitToolbar]) {
            toolbarItem = [self toolbarItemWithIdentifier:quitToolbar 
                                                label:@"Quit" 
                                          paleteLabel:@"Quit" 
                                              toolTip:@"Quit" 
                                               target:self 
                                          itemContent:[NSImage imageNamed:@"Cancel.png"] 
                                               action:@selector(terminateApp:)
                       ];
    }
    
    return toolbarItem;
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.  It returns an array holding identifiers for the default
// set of toolbar items.  It can also be called by the customization palette to display the default toolbar.  
//--------------------------------------------------------------------------------------------------
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:   prefsToolbar, 
                                        NSToolbarSeparatorItemIdentifier,
                                        quitToolbar,
            nil];
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.  It returns an array holding identifiers for all allowed
// toolbar items in this toolbar.  Any not listed here will not be available in the customization palette.
//--------------------------------------------------------------------------------------------------
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:   prefsToolbar, 
                                        NSToolbarSeparatorItemIdentifier,
                                        quitToolbar,
            nil];
}




@end
