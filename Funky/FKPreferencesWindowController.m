//
//  FKPreferencesWindowController.m
//  Funky
//
//  Created by Cătălin Stan on 3/5/17.
//  Copyright (c) 2017 Cătălin Stan. All rights reserved.
//

#import "FKPreferencesWindowController.h"
#import "FKAppDelegate.h"

@interface FKPreferencesWindowController () <NSWindowDelegate, NSToolbarDelegate> {
    BOOL shouldRecalculateWindowY;
    NSUInteger currentViewIdx;
}

@property (weak) IBOutlet NSToolbar *toolbar;

@property (strong) NSViewController *currentViewController;
@property (strong) NSButton *quitButton;

@property (readonly) CGFloat toolbarHeight;
@property (readonly) CGFloat titleHeight;
    
- (IBAction)loadView:(id)sender;

+ (NSDictionary<NSString *, NSImage *> *)toolbarItems;

@end

@implementation FKPreferencesWindowController
    
- (instancetype)initWithWindowNibName:(NSString *)windowNibName currentViewIdx:(NSUInteger)idx {
    self = [self initWithWindowNibName:windowNibName];
    if ( self != nil ) {
        currentViewIdx = MAX(MIN([FKPreferencesWindowController toolbarItems].count, idx), 0);
    }
    return self;
}

- (CGFloat)toolbarHeight {
    static CGFloat toolbarHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toolbarHeight = self.window.frame.size.height  - [self titleHeight] - self.window.contentView.frame.size.height;
    });
    return toolbarHeight;
}

- (CGFloat)titleHeight {
    static CGFloat titleHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect frame = NSMakeRect (0, 0, 100, 100);
        NSRect contentRect = [NSWindow contentRectForFrameRect: frame styleMask: NSTitledWindowMask];
        titleHeight = frame.size.height - contentRect.size.height;
    });
    return titleHeight;
}

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

- (void)awakeFromNib {
    self.quitButton = [NSButton buttonWithTitle:@"Quit" target:NSApp action:@selector(terminate:)];
    self.quitButton.keyEquivalent = @"q";
    self.quitButton.keyEquivalentModifierMask = NSCommandKeyMask;
    self.quitButton.frame = NSZeroRect;
    [self.window.contentView addSubview:self.quitButton];

    [self.window standardWindowButton:NSWindowCloseButton].keyEquivalent = @"w";
    [self.window standardWindowButton:NSWindowCloseButton].keyEquivalentModifierMask = NSCommandKeyMask;
    
    self.toolbar.selectedItemIdentifier = self.toolbar.items[currentViewIdx].itemIdentifier;
    [self loadView:self.toolbar.items[currentViewIdx]];
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
    
    if ( self.currentViewController != nil ) {
        [self.currentViewController.view removeFromSuperview];
        self.currentViewController = nil;
    }
    
    NSRect windowFrame = self.window.frame;
    
    self.currentViewController = [[viewControllerClass alloc] initWithNibName:nil bundle:nil];
    NSRect newViewFrame = self.currentViewController.view.frame;
    newViewFrame.size.width = windowFrame.size.width;
    newViewFrame.origin.y = 0;
    
    windowFrame.size.height = self.titleHeight + self.toolbarHeight + self.currentViewController.view.frame.size.height;
    if ( shouldRecalculateWindowY ) {
        windowFrame.origin.y -= windowFrame.size.height - self.window.frame.size.height;
    }
    shouldRecalculateWindowY = YES;
    
    [self.window setFrame:windowFrame display:YES animate:YES];
    [self.window.contentView addSubview:self.currentViewController.view];
    [self.currentViewController.view setFrame:newViewFrame];
    
    [self.window layoutIfNeeded];
    self.window.title = title;
    [self.window setViewsNeedDisplay:YES];
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
