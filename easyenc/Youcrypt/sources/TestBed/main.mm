//
//  main.m
//  TestBed
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "contrib/passwdqc/passwdqc.h"


int main(int argc, const char *argv[]) {
    @autoreleasepool {
        printf ("Hey!\n");
        
        char *reason = NULL;
        if(yc_check_pass("asdfgh", &reason)) {
            printf("badpass: %s\n", reason);
            if (reason) free(reason);
        }
    }
    return 0;
}


//int main_dirs_plis(int argc, const char * argv[])
//{
//    @autoreleasepool {
//        // Read config directory here.
//        /*
//        NSString *dirConfigPath = @"/Users/hr/.youcrypt/dirs.plist";
//        NSMutableArray *youcryptDirectories = [[NSMutableArray alloc] init];
//        YoucryptDirectory *directory = [[YoucryptDirectory alloc] init];    
//        [directory setPath:@"/Users/hr/tmp/sth.yc"];	
//        [directory setMountedPath:@""];    
//        [youcryptDirectories addObject:directory];
//        directory = [[YoucryptDirectory alloc] init];    
//        [directory setPath:@"/Users/hr/tmp/sthelse.yc"];
//        [directory setMountedPath:@"mounted path"];    
//        [youcryptDirectories addObject:directory];
//        directory = [[YoucryptDirectory alloc] init];    
//        [directory setPath:@"/Users/hr/tmp/sthmore.yc"];
//        [directory setMountedPath:@""];    
//        [youcryptDirectories addObject:directory];
//        printf ("Count: %lu\n", youcryptDirectories.count);
//        // Now, we write the data to config directory.
//        [NSKeyedArchiver archiveRootObject:youcryptDirectories toFile:dirConfigPath];
//        youcryptDirectories = [NSKeyedUnarchiver unarchiveObjectWithFile:dirConfigPath];
//
//         */
//    }
//    return 0;
//}


//int mainCheckEncfsPasswd(int argc, const char *argv[]) {
//    char passwd[1000];
//    @autoreleasepool {
//        do {
//            printf("Enter passwd:");
//            fgets(passwd, 900, stdin);
//            int len = strlen(passwd);
//            if (passwd[len-1] == '\n') passwd[len-1]=0;
//        }
//        while (![libFunctions mountEncFS:@"/Users/rajsekar/tmp/a" decryptedFolder:@"/Users/rajsekar/tmp/b" password:[NSString stringWithCString:passwd encoding:NSUTF8StringEncoding] volumeName:@"Vol" ]);
//
//    }
//    return 0;
//}
//
//
//int mainChangeEncFSPasswd(int argc, const char *argv[]) {
//    @autoreleasepool {
//        char passwd[1000], newpasswd[1000];
//        do {
//            printf("Enter passwd:");
//            fgets(passwd, 900, stdin);
//            int len = strlen(passwd);
//            if (passwd[len-1] == '\n') passwd[len-1]=0;
//            printf("Enter new passwd:");
//            fgets(newpasswd, 900, stdin);
//            len = strlen(newpasswd);
//            if (newpasswd[len-1] == '\n') newpasswd[len-1]=0;
//        }
//        while (![libFunctions changeEncFSPasswd:@"/Users/rajsekar/tmp/a"
//                                      oldPasswd:[NSString stringWithCString:passwd  encoding:NSUTF8StringEncoding]
//                                      newPasswd:[NSString stringWithCString:newpasswd encoding:NSUTF8StringEncoding]]);
//
//    }
//}
//

