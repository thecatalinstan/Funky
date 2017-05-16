//
//  FKAppDelegate.m
//  Funky
//
//  Created by Cătălin Stan on 01/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <MASShortcut/MASShortcut.h>
#import <MASShortcut/MASShortcutBinder.h>

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
- (IBAction)toggleCurrentApp:(id)sender;

- (void)handleApplicationSwitch:(NSNotification *)note;
- (BOOL)stateForApp:(NSRunningApplication *)app inBundles:(NSArray<FKBundle *> *)bundles;

@end

@implementation FKAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    NSString *eventQueueLabel = [NSString stringWithFormat:@"%@-eventQueue", [NSBundle mainBundle].bundleIdentifier];
    self.eventQueue = dispatch_queue_create(eventQueueLabel.UTF8String, DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(self.eventQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [Fabric with:@[[Crashlytics class]]];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:FKStatusImageName];
    self.statusItem.menu = self.statusMenu;
    
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    
    MASShortcut *toggleAppShortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_F modifierFlags:NSShiftKeyMask|NSAlternateKeyMask|NSCommandKeyMask];
    defaults[FKToggleAppShortcutKeyPath] = [NSKeyedArchiver archivedDataWithRootObject:toggleAppShortcut];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    // Associate the preference key with an action
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:FKToggleAppShortcutKeyPath toAction:^{
        [self toggleCurrentApp:nil];
    }];
    
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

- (void)toggleCurrentApp:(id)sender {
    NSRunningApplication *app = [[NSWorkspace sharedWorkspace] activeApplication][NSWorkspaceApplicationKey];
    [self addBundleWithURL:app.bundleURL];
}

- (void)showPreferencesDialog:(id)sender {
    if ( self.preferencesWindowController == nil ) {
        self.preferencesWindowController = [[FKPreferencesWindowController alloc] initWithWindowNibName:FKPreferencesWindowControllerNibName currentViewIdx:1];
    }
    [self.preferencesWindowController showWindow:sender];
}

- (void)handleApplicationSwitch:(NSNotification *)note {
    NSRunningApplication *app = note.userInfo[NSWorkspaceApplicationKey];
    NSData *bundleData = [[NSUserDefaults standardUserDefaults] objectForKey:FKBundlesKeyPath];
    NSArray<FKBundle *> *bundles = [NSKeyedUnarchiver unarchiveObjectWithData:bundleData];
    
    NSError *error;
    
    BOOL state = [self stateForApp:app inBundles:bundles];
    if ( !state ) {
        pid_t pid = [[FKHelper sharedHelper] parentProcessForPID:app.processIdentifier error:&error];
        if ( error ) {
            NSLog(@" ** State: %@, Error: %@", @(state), error);
        } else if (pid != 1) {
            app = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
            state = [self stateForApp:app inBundles:bundles];
        }
    }
    
    error = nil;
    if ( [[FKHelper sharedHelper] setFnKeyState:state error:&error] != YES)  {
#if DEBUG
        NSLog(@" ** State: %@, Error: %@", @(state), error);
#endif
    }
    
    NSLog(@"%@: %@", app.executableURL.path, @(state));
}

- (BOOL)stateForApp:(NSRunningApplication *)app inBundles:(NSArray<FKBundle *> *)bundles {
    return [[bundles valueForKeyPath:FKBundleIdentifierKey] containsObject:app.bundleIdentifier] || [[bundles valueForKeyPath:FKBundlePathKey] containsObject:app.bundleURL.path];
}

- (void)addBundleWithURL:(NSURL *)URL {
    FKBundle *bundle = [FKBundle bundleWithURL:URL];
    
    NSData *bundleData = [[NSUserDefaults standardUserDefaults] objectForKey:FKBundlesKeyPath];
    NSMutableArray<FKBundle *> *bundles = [[NSKeyedUnarchiver unarchiveObjectWithData:bundleData] mutableCopy];
    
    if ( bundles == nil ) {
        bundles = [NSMutableArray array];
    }
    
    NSString *message, *title;
    
    if ( [[bundles valueForKeyPath:FKBundleIdentifierKey] containsObject:bundle.identifier] ) {
        [bundles removeObject:bundle];
        title = NSLocalizedString(@"Application Removed",);
        message = NSLocalizedString(@"%@ has been removed from the Funky list.",);
    } else {
        [bundles addObject:bundle];
        title = NSLocalizedString(@"Application Added",);
        message = NSLocalizedString(@"%@ has been added to the Funky list.",);
    }
    
    bundleData = [NSKeyedArchiver archivedDataWithRootObject:bundles];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setObject:bundleData forKey:FKBundlesKeyPath];
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = title;
        notification.informativeText = [NSString stringWithFormat:message, bundle.name];
        notification.contentImage = bundle.image;
        notification.identifier = [NSUUID UUID].UUIDString;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    });
}

@end
