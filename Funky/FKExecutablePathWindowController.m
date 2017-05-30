//
//  FKExecutablePathWindowController.m
//  Funky
//
//  Created by Cătălin Stan on 17/05/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import "FKExecutablePathWindowController.h"

@interface FKExecutablePathWindowController ()

@end

@implementation FKExecutablePathWindowController


- (IBAction)confirmPath:(id)sender {
    [NSApp endSheet:self.window returnCode:NSOKButton];
    [self close];
}

- (IBAction)cancel:(id)sender {
    [NSApp endSheet:self.window returnCode:NSCancelButton];
    [self close];
}


@end
