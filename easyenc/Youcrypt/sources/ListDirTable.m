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

    NSLog(@"KEY! : %d",theEvent.keyCode);
    switch (theEvent.keyCode) {
        case 125: // down
        case 126: // up
            NSLog(@"ROW: %ld",[listDirObj.table selectedRow]);
            [listDirObj setStatusToSelectedRow:[listDirObj.table selectedRow]];
            break;
        case 117: // delete
            [listDirObj removeFS:listDirObj.window];
            break;
        case 36: // enter
            [listDirObj doOpenProxy:[listDirObj.table selectedRow]];
            break;
        default:
            break;
        
	}    
}

- (void) setImageViewUnderTable:(NSImageView*)imgView
{
    backgroundImageView = imgView;
    defaultImage = [NSImage imageNamed:@"Grey_Add_Folder.png"];
    otherImage = [NSImage imageNamed:@"Grey_Open_Folder.png"];

}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [[self enclosingScrollView] setDrawsBackground: NO];
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