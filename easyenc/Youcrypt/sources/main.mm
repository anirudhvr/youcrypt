//]
//
//  main.m
//  Youcrypt Mac alpha
//
//  Created by Hardik Ruparel on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "libFunctions.h"
#include "testhttpclient.h"


int main(int argc, char *argv[])
{
    testServer();
    return NSApplicationMain(argc, (const char **)argv);
}

