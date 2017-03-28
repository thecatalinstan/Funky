//
//  FKPreferencesAppsViewController.m
//  Funky
//
//  Created by Cătălin Stan on 05/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import "FKPreferencesAppsViewController.h"
#import "FKAppDelegate.h"
#import "FKBundle.h"

@interface FKPreferencesAppsViewController () <NSTableViewDelegate, NSTableViewDataSource, NSDraggingDestination, NSTextFinderClient>

@property (weak) IBOutlet NSArrayController *appsListController;
@property (weak) IBOutlet NSTableView *appsListTableView;

@property (weak) IBOutlet NSButton *actionsButton;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *removeButton;

@property (weak) IBOutlet NSSearchField *appFilterSearchField;
@property (strong) IBOutlet NSView *searchBarContainerView;

@property (strong) IBOutlet NSMenu *actionsMenu;
@property (strong) IBOutlet NSMenu *searchMenu;

@property (readonly) NSEdgeInsets originalContentInsets;

- (IBAction)addBundle:(id)sender;
- (IBAction)addExecutablePath:(id)sender;
- (IBAction)filterApps:(id)sender;
- (IBAction)popupActionsMenu:(id)sender;

@end

@implementation FKPreferencesAppsViewController

- (void)awakeFromNib {
    [self.appsListTableView registerForDraggedTypes:@[NSFilenamesPboardType]];
    self.appsListTableView.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleSourceList;
    
    self.appsListController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:FKBundleNameKey ascending:YES], [NSSortDescriptor sortDescriptorWithKey:FKBundlePathKey ascending:YES]];
}

- (NSEdgeInsets)originalContentInsets {
    static NSEdgeInsets originalContentInsets;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        originalContentInsets = self.appsListTableView.enclosingScrollView.contentInsets;
    });
    return originalContentInsets;
}

- (void)filterApps:(id)sender {
    
    NSRect frame = self.appFilterSearchField.superview.frame;
    frame.size.width = self.appsListTableView.enclosingScrollView.frame.size.width;
    self.appFilterSearchField.superview.frame = frame;
    
    NSEdgeInsets contentInsets = self.originalContentInsets;
    contentInsets.top = self.appFilterSearchField.bounds.size.height;
    self.appsListTableView.enclosingScrollView.contentInsets = contentInsets;
    
    [self.appsListTableView.enclosingScrollView addSubview:self.appFilterSearchField.superview positioned:NSWindowAbove relativeTo:self.appsListTableView];
    self.appsListTableView.enclosingScrollView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (IBAction)popupActionsMenu:(id)sender {
    NSEvent *event = [NSEvent mouseEventWithType:NSEventTypeLeftMouseUp location:NSMakePoint(self.actionsButton.frame.origin.x - 1.0f, self.actionsButton.frame.origin.y + self.actionsButton.bounds.size.height + self.actionsMenu.size.height - 5.0f) modifierFlags:0 timestamp:0 windowNumber:self.view.window.windowNumber context:nil eventNumber:0 clickCount:1 pressure:1.0f];
    [NSMenu popUpContextMenu:self.actionsMenu withEvent:event forView:self.actionsButton];
}

- (IBAction)addBundle:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.directoryURL = [[NSFileManager defaultManager] URLsForDirectory:NSAllApplicationsDirectory inDomains:NSAllDomainsMask].lastObject;
    panel.allowedFileTypes = @[@"app"];
    panel.allowsMultipleSelection = YES;
    panel.canChooseDirectories = YES;
    panel.treatsFilePackagesAsDirectories = NO;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if ( result != NSFileHandlingPanelOKButton ) {
            return;
        }
        [panel.URLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { @autoreleasepool {
            [self addBundleWithURL:obj];
        }}];
        [self.appsListController commitEditing];
    }];
}

- (void)addExecutablePath:(id)sender {
    
}

- (void)addBundleWithURL:(NSURL *)URL {
    FKBundle *bundle = [FKBundle bundleWithURL:URL];
    if ( [[self.appsListController.arrangedObjects valueForKeyPath:FKBundleIdentifierKey] containsObject:bundle.identifier] ) {
        return;
    }
    [self.appsListController addObject:bundle];
}

#pragma mark - NSTableViewDelegate

- (NSArray<NSTableViewRowAction *> *)tableView:(NSTableView *)tableView rowActionsForRow:(NSInteger)row edge:(NSTableRowActionEdge)edge {
    if ( edge != NSTableRowActionEdgeTrailing ) {
        return nil;
    }
    
    NSTableViewRowAction *deleteAction = [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleDestructive title:@"Delete" handler:^(NSTableViewRowAction * _Nonnull action, NSInteger row) {
        [self.appsListController removeObjectAtArrangedObjectIndex:row];
    }];
    
    return @[deleteAction];
}

- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(nonnull id<NSDraggingInfo>)draggingInfo proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    
    if ( ![draggingInfo.draggingPasteboard.types containsObject:NSFilenamesPboardType] ) {
        return NSDragOperationNone;
    }
    
    __block BOOL canAccept = NO;
    NSArray<NSString *> *files = [draggingInfo.draggingPasteboard propertyListForType:NSFilenamesPboardType];
    [files enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [[[NSBundle bundleWithPath:obj] objectForInfoDictionaryKey:@"CFBundlePackageType"] isEqualToString:@"APPL"]) {
            canAccept = YES;
            *stop = YES;
        }
    }];
    
    return canAccept ? NSDragOperationCopy : NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(nonnull id<NSDraggingInfo>)draggingInfo row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    __block BOOL canAccept = NO;
    NSArray<NSString *> *files = [draggingInfo.draggingPasteboard propertyListForType:NSFilenamesPboardType];
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( ![[[NSBundle bundleWithPath:obj] objectForInfoDictionaryKey:@"CFBundlePackageType"] isEqualToString:@"APPL"]) {
            return;
        }
        canAccept = YES;
        NSURL *bundleURL = [NSURL fileURLWithPath:obj];
        [self addBundleWithURL:bundleURL];
    }];
    
    return canAccept;
}

#pragma mark - NSTextFinderClient



@end
