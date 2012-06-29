//
//  main.m
//  TestBed
//
//  Created by Rajsekar Manokaran on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YoucryptDirectory.h"
#import <stdio.h>
#import <unistd.h>
#import <sys/socket.h>
#import <sys/un.h>


int execWithSocket(NSString *path, NSArray *arguments) {
    int sockDescriptors[2];
    pid_t pid;
    
    if (socketpair(AF_LOCAL, SOCK_STREAM, 0, sockDescriptors) == -1)
    {
        perror("socketpair");
        return -1;
    }
    
    if ((pid = fork()) == -1)
    {
        perror("fork");
        return -1;
    }
    else if (pid == 0) { 
        // This is the child.  Use sockDescriptors[0] here.
        close(0);
        dup(sockDescriptors[0]);
        execl([path cStringUsingEncoding:NSUTF8StringEncoding],
              [path cStringUsingEncoding:NSUTF8StringEncoding],
              [[NSString stringWithFormat:@"%d", sockDescriptors[0]] cStringUsingEncoding:NSUTF8StringEncoding],
              (char *)0);
        perror("execl");
        return -1;
    }
    else { 
        // This is the parent
        // Write all the arguments to the socket.        
        // Use sockDescriptors[1] here.

        int argc = [arguments count];
        int sock = sockDescriptors[1];
        write (sock, &argc, sizeof(argc));
        for (int i=0; i<argc; i++) {
            const char *arg = [[arguments objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding];
            int len = strlen(arg);
            write (sock, &len, sizeof(len));
            write (sock, arg, len);
        }        
        return sock;   
    }
}




int main_dirs_plis(int argc, const char * argv[])
{
    @autoreleasepool {
        // Read config directory here.
        NSString *dirConfigPath = @"/Users/rajsekar/.youcrypt/config.plist";
        NSMutableArray *youcryptDirectories = [[NSMutableArray alloc] init];
        YoucryptDirectory *directory = [[YoucryptDirectory alloc] init];    
        [directory setPath:@"/Users/rajsekar/tmp/sth.yc"];
        [directory setMountedPath:@""];    
        [youcryptDirectories addObject:directory];
        directory = [[YoucryptDirectory alloc] init];    
        [directory setPath:@"/Users/rajsekar/tmp/sthelse.yc"];
        [directory setMountedPath:@"mounted path"];    
        [youcryptDirectories addObject:directory];
        directory = [[YoucryptDirectory alloc] init];    
        [directory setPath:@"/Users/rajsekar/tmp/sthmore.yc"];
        [directory setMountedPath:@""];    
        [youcryptDirectories addObject:directory];
        printf ("Count: %lu\n", youcryptDirectories.count);
        // Now, we write the data to config directory.
        [NSKeyedArchiver archiveRootObject:youcryptDirectories toFile:dirConfigPath];
        youcryptDirectories = [NSKeyedUnarchiver unarchiveObjectWithFile:dirConfigPath];
        printf ("Count: %lu\n", youcryptDirectories.count);
    }
    return 0;
}

int mainExecSocket(int argc, const char *argv[]) {
    @autoreleasepool {
        NSArray *array = [NSArray arrayWithObjects:@"whatevs",
                          @"another whatevs yo!", nil];
//        execWithSocket(@"/Users/rajsekar/tmp/read_args", array);
//        encfsCall(array);
        
    }
    return 0;
}



int main(int argc, const char *argv[]) {
    @autoreleasepool {
        return 0;
    }
}
