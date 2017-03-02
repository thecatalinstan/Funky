//
//  FKAppDelegate.m
//  Funky
//
//  Created by Cătălin Stan on 01/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import "FKAppDelegate.h"
#import "FKHelper.h"

@interface FKAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation FKAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSArray<NSString *> *bundleIds = @[@"com.apple.Safari"];
    
    [[NSWorkspace sharedWorkspace].notificationCenter addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        NSRunningApplication *app = note.userInfo[NSWorkspaceApplicationKey];
        BOOL state = [bundleIds containsObject:app.bundleIdentifier];
        
        NSError *error;
        if ( [[FKHelper sharedHelper] setFnKeyState:state error:&error] != YES)  {
            NSLog(@" ** Error: %@", error);
        } else {
            NSLog(@"%@: %@", app.bundleIdentifier, @(state));
        }
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
