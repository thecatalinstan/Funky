//
//  FKPreferencesWindowController.h
//  Funky
//
//  Created by Cătălin Stan on 3/5/17.
//  Copyright (c) 2017 Cătălin Stan. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface FKPreferencesWindowController : NSWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName currentViewIdx:(NSUInteger)idx;
    
@end
