//
//  FKAppDelegate.m
//  Funky
//
//  Created by Cătălin Stan on 01/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import "FKAppDelegate.h"
#import "FKHelper.h"
#import "FKPreferencesWindowController.h"
#import "FKBundle.h"

#define FKStatusImageName                       @"FunkyStatusTemplate"
#define FKPreferencesWindowControllerNibName    @"FKPreferencesWindowController"

@interface FKAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *statusMenu;

@property (strong) dispatch_queue_t eventQueue;

- (IBAction)showPreferencesDialog:(id)sender;

- (void)handleApplicationSwitch:(NSNotification *)note;

@end

@implementation FKAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    NSString *eventQueueLabel = [NSString stringWithFormat:@"%@-eventQueue", [NSBundle mainBundle].bundleIdentifier];
    self.eventQueue = dispatch_queue_create(eventQueueLabel.UTF8String, DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(self.eventQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:FKStatusImageName];
    self.statusItem.menu = self.statusMenu;
    
    [[NSWorkspace sharedWorkspace].notificationCenter addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) { @autoreleasepool {
        dispatch_async(self.eventQueue, ^{ @autoreleasepool {
            [self handleApplicationSwitch:note];
        }});
    }}];
    
    [self showPreferencesDialog:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    dispatch_barrier_sync(self.eventQueue, ^{ @autoreleasepool {
        [[FKHelper sharedHelper] setFnKeyState:NO error:nil];
    }});
}

- (void)showPreferencesDialog:(id)sender {
    if ( self.preferencesWindowController == nil ) {
        self.preferencesWindowController = [[FKPreferencesWindowController alloc] initWithWindowNibName:FKPreferencesWindowControllerNibName];
    }
    [self.preferencesWindowController showWindow:sender];
}

- (void)handleApplicationSwitch:(NSNotification *)note {
    NSRunningApplication *app = note.userInfo[NSWorkspaceApplicationKey];
    NSData *bundleData = [[NSUserDefaults standardUserDefaults] objectForKey:FKBundlesKeyPath];
    NSArray<NSString *> *bundleIds = [[NSKeyedUnarchiver unarchiveObjectWithData:bundleData] valueForKeyPath:@"identifier"];
    BOOL state = [bundleIds containsObject:app.bundleIdentifier];
    
    NSError *error;
    if ( [[FKHelper sharedHelper] setFnKeyState:state error:&error] != YES)  {
        NSLog(@" ** Error: %@", error);
    } else {
        NSLog(@"%@: %@", app.bundleURL.path, @(state));
    }
}

@end
