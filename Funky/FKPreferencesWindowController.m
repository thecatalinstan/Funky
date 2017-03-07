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

+ (NSDictionary<NSString *, NSImage *> *)toolbarItems;


@end

@implementation FKPreferencesWindowController

+ (NSDictionary<NSString *,NSImage *> *)toolbarItems {
    static NSDictionary<NSString *,NSImage *> *toolbarItems;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toolbarItems = @{
          @"General": [NSImage imageNamed:NSImageNamePreferencesGeneral],
          @"Apps": [NSImage imageNamed:NSImageNameApplicationIcon],
          @"Advanced": [NSImage imageNamed:NSImageNameAdvanced]
        };
    });
    return toolbarItems;
}

- (void)windowDidLoad {
    self.window.contentView.wantsLayer = YES;
    self.window.contentView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    
    self.toolbar.selectedItemIdentifier = self.toolbar.items[0].itemIdentifier;
    [self loadView:self.toolbar.items[0]];
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

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    
    NSString *itemClassName = [NSString stringWithFormat:@"FKPreferences%@ViewController", itemIdentifier];
    Class itemClass = NSClassFromString(itemClassName);
    if ( !itemClass ) {
        NSLog(@" * Unable to find %@. Skipping %@ toolbar item.", itemClassName, itemIdentifier);
        return nil;
    }
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    item.label = NSLocalizedString(itemIdentifier,);
    item.image = [FKPreferencesWindowController toolbarItems][itemIdentifier];
    item.autovalidates = YES;
    
    if ( flag ) {
        item.action = @selector(loadView:);
    }
    
    return item;
}

- (NSArray<NSString *> *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    return [FKPreferencesWindowController toolbarItems].allKeys;
}

- (NSArray<NSString *> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [FKPreferencesWindowController toolbarItems].allKeys;
}

- (NSArray<NSString *> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [FKPreferencesWindowController toolbarItems].allKeys;
}


@end
