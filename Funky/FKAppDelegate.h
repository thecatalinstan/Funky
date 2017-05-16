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


@class FKPreferencesWindowController, FKBundle;

@interface FKAppDelegate : NSObject <NSApplicationDelegate>

@property (strong) FKPreferencesWindowController *preferencesWindowController;
@property (strong) NSStatusItem *statusItem;

@end

