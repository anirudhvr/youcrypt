//
//  Decrypt.h
//  EasyEnc
//
//  Created by Anirudh Ramachandran on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Decrypt : NSObject {
	IBOutlet NSTextField *yourPassword;
}

-(IBAction)decrypt:(id)sender;

@end
