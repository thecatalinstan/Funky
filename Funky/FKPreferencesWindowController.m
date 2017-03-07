//
//  FKPreferencesWindowController.m
//  Funky
//
//  Created by Cătălin Stan on 3/5/17.
//  Copyright (c) 2017 Cătălin Stan. All rights reserved.
//

#import "FKPreferencesWindowController.h"
#import "FKAppDelegate.h"

@interface FKPreferencesWindowController () <NSWindowDelegate, NSToolbarDelegate>

@property (weak) IBOutlet NSToolbar *toolbar;

- (IBAction)loadView:(id)sender;

@end

@implementation FKPreferencesWindowController

- (void)windowDidLoad {
    self.window.contentView.wantsLayer = YES;
    self.window.contentView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
}

- (void)showWindow:(id)sender {
    [[self.window standardWindowButton:NSWindowCloseButton] setKeyEquivalent:@"w"];
    [[self.window standardWindowButton:NSWindowCloseButton] setKeyEquivalentModifierMask:NSCommandKeyMask];
    [super showWindow:sender];
}

- (void)windowWillClose:(NSNotification *)notification {
    FKAppDelegate *delegate = (FKAppDelegate *) NSApp.delegate;
    delegate.preferencesWindowController = nil;
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if ( self ) {
    }
    return self;
}

- (IBAction)loadView:(id)sender {

    NSToolbarItem *item = (NSToolbarItem*) sender;
    NSString *viewControllerClassName = [NSString stringWithFormat:@"FKPreferences%@ViewController", item.label];
    Class viewControllerClass = NSClassFromString(viewControllerClassName);
    
    if ( viewControllerClass == nil ) {
        NSLog(@"Unable to load class: %@", viewControllerClassName);
        return;
    }
    
    NSString *title = self.window.title;
    
    self.window.title = [NSString stringWithFormat: @"Loading %@ ...", ((NSToolbarItem*) sender).label];
    [self.window setViewsNeedDisplay:YES];

    if ( self.window.contentView.subviews.count != 0 ) {
        [self.window.contentView.subviews[0] removeFromSuperview];
    }
    
    self.contentViewController = [[viewControllerClass alloc] initWithNibName:viewControllerClassName bundle:nil];
    [self.window layoutIfNeeded];
    self.window.title = title;
    
}

@end
