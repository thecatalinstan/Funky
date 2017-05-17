//
//  FKAppDelegate.h
//  Funky
//
//  Created by Cătălin Stan on 01/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define FKBundlesKeyPath                        @"FKBundles"
#define FKToggleAppShortcutKeyPath              @"FKToggleAppShortcut"
#define FKLaunchOnLoginKeyPath                  @"FKLaunchOnLogin"

@class FKPreferencesWindowController, FKBundle;

@interface FKAppDelegate : NSObject <NSApplicationDelegate>

@property (strong) FKPreferencesWindowController *preferencesWindowController;
@property (strong) NSStatusItem *statusItem;
@property (assign) BOOL launchOnLogin;

@property (strong) IBOutlet NSMenuItem *toggleCurrentAppMenuItem;

@end

