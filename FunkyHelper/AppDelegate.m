//
//  AppDelegate.m
//  FunkyHelper
//
//  Created by Cătălin Stan on 17/05/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import "AppDelegate.h"

#define FKMainAppName                   @"Funky"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSString* mainBundleIdentifier = [NSBundle mainBundle].bundleIdentifier.stringByDeletingPathExtension;
    NSArray<NSRunningApplication *> *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    
#if DEBUG
    NSLog(@"Running apps:%@", [runningApps valueForKeyPath:@"bundleIdentifier"]);
#endif
    
    __block BOOL alreadyRunning = NO;
    [runningApps enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSRunningApplication * _Nonnull app, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([app.bundleIdentifier isEqualToString:mainBundleIdentifier]) {
            alreadyRunning = YES;
            *stop = YES;
        }
    }];
    
    
    NSLog(@"%@ is running ... %@", mainBundleIdentifier, alreadyRunning ? @"YES" : @"NO");
    
    if (!alreadyRunning) {
        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:[NSBundle mainBundle].bundlePath.pathComponents];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents addObject:@"MacOS"];
        [pathComponents addObject:FKMainAppName];
        NSString *executablePath = [NSString pathWithComponents:pathComponents];
        
        BOOL isDir = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:executablePath isDirectory:&isDir];
        
        NSLog(@"Attempting to launch: %@", executablePath);
        
        if ( !exists ) {
            NSLog(@"File does not exist.");
        } else if ( isDir ) {
            NSLog(@"File exists but is a directory");
        } else {
            [[NSWorkspace sharedWorkspace] launchApplication:executablePath];
        }
    }
    
    NSLog(@"Exiting");
    [NSApp terminate:nil];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    // Insert code here to tear down your application
}
@end
