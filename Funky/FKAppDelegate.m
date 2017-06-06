//
//  FKAppDelegate.m
//  Funky
//
//  Created by Cătălin Stan on 01/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

@import Fabric;
@import Crashlytics;
@import ShortcutRecorder;
@import ShortcutRecorder.PTHotKey;
@import ServiceManagement;

#import "FKAppDelegate.h"
#import "FKHelper.h"
#import "FKPreferencesWindowController.h"
#import "FKBundle.h"

#define FKHelperAppName                         @"FunkyHelper"
#define FKStatusImageName                       @"FunkyStatusTemplate"
#define FKStatusActiveImageName                 @"FunkyStatusActiveTemplate"
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
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    defaults[@"NSApplicationCrashOnExceptions"] = @YES;
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    [[NSWorkspace sharedWorkspace].notificationCenter addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) { @autoreleasepool {
        dispatch_async(self.eventQueue, ^{ @autoreleasepool {
            [self handleApplicationSwitch:note];
        }});
    }}];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:FKStatusImageName];
    self.statusItem.menu = self.statusMenu;
    
    // Bind the menu item key equivalent
    [self.toggleCurrentAppMenuItem bind:@"keyEquivalent" toObject:[NSUserDefaults standardUserDefaults] withKeyPath:FKToggleAppShortcutKeyPath options:@{NSValueTransformerBindingOption: [SRKeyEquivalentTransformer new]}];
    [self.toggleCurrentAppMenuItem bind:@"keyEquivalentModifierMask" toObject:[NSUserDefaults standardUserDefaults] withKeyPath:FKToggleAppShortcutKeyPath options:@{NSValueTransformerBindingOption: [SRKeyEquivalentModifierMaskTransformer new]}];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) { @autoreleasepool {
        PTHotKey *oldToggleAppHotKey = [[PTHotKeyCenter sharedCenter] hotKeyWithIdentifier:FKToggleAppShortcutKeyPath];
        [[PTHotKeyCenter sharedCenter] unregisterHotKey:oldToggleAppHotKey];
        
        PTHotKey *toggleAppHotKey = [PTHotKey hotKeyWithIdentifier:FKToggleAppShortcutKeyIdentifier keyCombo:[[NSUserDefaults standardUserDefaults] objectForKey:FKToggleAppShortcutKeyPath] target:self action:@selector(toggleCurrentApp:)];
        [[PTHotKeyCenter sharedCenter] registerHotKey:toggleAppHotKey];
    }}];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    dispatch_barrier_sync(self.eventQueue, ^{ @autoreleasepool {
        [[FKHelper sharedHelper] setFnKeyState:NO error:nil];
    }});
}

- (void)toggleCurrentApp:(id)sender {
    NSRunningApplication *app = [[NSWorkspace sharedWorkspace] activeApplication][NSWorkspaceApplicationKey];
    [self toggleBundleWithURL:app.bundleURL];
}

- (void)showPreferencesDialog:(id)sender {
    if ( self.preferencesWindowController == nil ) {
        self.preferencesWindowController = [[FKPreferencesWindowController alloc] initWithWindowNibName:FKPreferencesWindowControllerNibName currentViewIdx:0];
    }
    [self.preferencesWindowController showWindow:sender];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)handleApplicationSwitch:(NSNotification *)note {
    NSRunningApplication *app = note.userInfo[NSWorkspaceApplicationKey] ? : [[NSWorkspace sharedWorkspace] activeApplication][NSWorkspaceApplicationKey];
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
    
    self.statusItem.image = [NSImage imageNamed:(state ? FKStatusActiveImageName : FKStatusImageName)];
}

- (BOOL)stateForApp:(NSRunningApplication *)app inBundles:(NSArray<FKBundle *> *)bundles {
    return [[bundles valueForKeyPath:FKBundleIdentifierKey] containsObject:app.bundleIdentifier] || [[bundles valueForKeyPath:FKBundlePathKey] containsObject:app.bundleURL.path];
}

- (void)toggleBundleWithURL:(NSURL *)URL {
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
        
        [self handleApplicationSwitch:nil];
    });
    
}


- (BOOL)launchOnLogin {
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] boolForKey:FKLaunchOnLoginKeyPath];
}

- (void)setLaunchOnLogin:(BOOL)launchOnLogin {
    CFStringRef helperBundleIdentifier = (__bridge CFStringRef)[[NSBundle mainBundle].bundleIdentifier stringByAppendingPathExtension:FKHelperAppName];
    BOOL status = SMLoginItemSetEnabled(helperBundleIdentifier, launchOnLogin);
    
    if ( !status ) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FKLaunchOnLoginKeyPath];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *infoText = launchOnLogin ? NSLocalizedString(@"Could not set %@ to start at login",) : NSLocalizedString(@"Could not remove %@ from the login items list.",);
        
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"An error ocurred",) defaultButton:NSLocalizedString(@"OK",) alternateButton:nil otherButton:nil informativeTextWithFormat:infoText, [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey]];
        [alert runModal];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:launchOnLogin forKey:FKLaunchOnLoginKeyPath];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
