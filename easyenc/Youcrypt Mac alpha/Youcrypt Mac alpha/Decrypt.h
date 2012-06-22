//
//  Decrypt.h
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Decrypt : NSWindowController {
	IBOutlet NSTextField *yourPassword;
	IBOutlet NSTextField *errorMessage;
    NSString *sourceFolderPath;
    NSString *destFolderPath;
    BOOL keychainHasPassphrase;
    NSString *passphraseFromKeychain;
}

- (IBAction)decrypt:(id)sender;

@property (atomic, strong) NSString *sourceFolderPath;
@property (atomic, strong) NSString *destFolderPath;

@end
