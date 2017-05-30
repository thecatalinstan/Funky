//
//  FKPreferencesGeneralViewController.m
//  Funky
//
//  Created by Cătălin Stan on 05/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <ShortcutRecorder/ShortcutRecorder.h>

#import "FKPreferencesGeneralViewController.h"
#import "FKAppDelegate.h"

@interface FKPreferencesGeneralViewController ()

@property (nonatomic, weak) IBOutlet SRRecorderControl *toggleAppShortcut;

@end

@implementation FKPreferencesGeneralViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.toggleAppShortcut bind:NSValueBinding toObject:[NSUserDefaults standardUserDefaults] withKeyPath:FKToggleAppShortcutKeyPath options:nil];
}

- (void)dealloc {
    [self.toggleAppShortcut unbind:NSValueBinding];
}

@end
