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

@interface FKPreferencesAppsViewController () <NSTableViewDelegate, NSTableViewDataSource, NSDraggingDestination>

@property (weak) IBOutlet NSArrayController *appsListController;
@property (weak) IBOutlet NSTableView *appsListTableView;

- (IBAction)addBundle:(id)sender;

@end

@implementation FKPreferencesAppsViewController

- (void)awakeFromNib {
    [self.appsListTableView registerForDraggedTypes:@[NSFilenamesPboardType]];
    self.appsListTableView.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleSourceList;
    
    self.appsListController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:FKBundleNameKey ascending:YES], [NSSortDescriptor sortDescriptorWithKey:FKBundlePathKey ascending:YES]];
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

@end
