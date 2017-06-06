//
//  FKExecutablePathWindowController.h
//  Funky
//
//  Created by Cătălin Stan on 17/05/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FKExecutablePathWindowController : NSWindowController

@property (nonatomic, strong) NSString * selectedPath;

- (IBAction)confirmPath:(id)sender;
- (IBAction)cancel:(id)sender;

@end
