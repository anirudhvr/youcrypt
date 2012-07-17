//
//  ListDirTable.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 7/9/12.
//  Copyright (c) 2012 Nouvou Inc. All rights reserved.
//

#import "ListDirTable.h"
#import "AppDelegate.h"
#import "ListDirectoriesWindow.h"

@implementation ListDirTable

@synthesize listDirObj;


- (void) setListDir:(ListDirectoriesWindow *)listDirObject
{
    listDirObj = listDirObject;
}

- (void) keyDown:(NSEvent *)theEvent;
{
    [super keyDown:theEvent];	
    
    NSLog(@"keycode:%lu, modifierflags: %lu", theEvent.keyCode, theEvent.modifierFlags);

    switch (theEvent.keyCode) {
        case 125: // down
        case 126: // up
            [listDirObj setStatusToSelectedRow:[listDirObj.table selectedRow]];
            break;
        case 117: // delete
            [listDirObj removeFS:listDirObj.window];
            break;
        case 36: // enter
            [listDirObj doOpenProxy:[listDirObj.table selectedRow]];
            break;
        case 15: // Test for 'Cmd-Shift-R'
            if (theEvent.modifierFlags & NSCommandKeyMask) {
                [listDirObj doOpenProxy:[listDirObj.table selectedRow]];
            }
            break; 
        case 2: // Test for Cmd-shift-D or decryot
            if (theEvent.modifierFlags & NSCommandKeyMask) {
                [listDirObj removeFS:listDirObj.window];
            }
            break;
        case 8:  // Test for Cmd-shift-C or close
            if (theEvent.modifierFlags & NSCommandKeyMask) {
                [listDirObj close:listDirObj.window];
            }
            break;

        default:
            break;
        
	}    
}

- (void) setImageViewUnderTable:(NSImageView*)imgView
{
    backgroundImageView = imgView;

}

- (void) setDefaultImage
{
    [backgroundImageView setImage:defaultImage];
}

- (void) setOtherImage
{
    [backgroundImageView setImage:otherImage];
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [[self enclosingScrollView] setDrawsBackground: NO];
    defaultImage = [NSImage imageNamed:@"Grey_Add_Folder.png"];
    otherImage = [NSImage imageNamed:@"Grey_Open_Folder.png"];
}

- (BOOL)isOpaque {
    
    return NO;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
    
    // don't draw a background rect
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    NSDragOperation ret = [super draggingEntered:sender];

    NSPasteboard *pb = [sender draggingPasteboard];
    
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {
        NSString *path = [[NSURL URLFromPasteboard:pb] path];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            //   NSLog(@"Dragging entered");
            if (backgroundImageView != nil) {
                [backgroundImageView setImage:otherImage];
            }
            
        }
    }
    
    return ret;
}


- (void)draggingExited:(id < NSDraggingInfo >)sender
{
    [super draggingExited:sender];

    NSPasteboard *pb = [sender draggingPasteboard];

    
    // Check if the pboard contains a URL that's a diretory.
    if ([[pb types] containsObject:NSURLPboardType]) {
        NSString *path = [[NSURL URLFromPasteboard:pb] path];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            //NSLog(@"Dragging exited");
            if (backgroundImageView != nil) {
                [backgroundImageView setImage:defaultImage];
            }
            
        }
    }
}



@end
