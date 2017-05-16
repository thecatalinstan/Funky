//
//  FKPreferencesGeneralViewController.m
//  Funky
//
//  Created by Cătălin Stan on 05/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <MASShortcut/Shortcut.h>

#import "FKPreferencesGeneralViewController.h"
#import "FKAppDelegate.h"

@interface FKPreferencesGeneralViewController ()

@property (nonatomic, weak) IBOutlet MASShortcutView *toggleAppShortcut;

@end

@implementation FKPreferencesGeneralViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.toggleAppShortcut.style = MASShortcutViewStyleTexturedRect;
    self.toggleAppShortcut.associatedUserDefaultsKey = FKToggleAppShortcutKeyPath;
}

@end
