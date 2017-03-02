//
//  FKHelper.h
//  Funky
//
//  Created by Cătălin Stan on 02/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FKHelperErrorDomain             @"FKHelperErrorDomain"
#define FKHelperMachErrorDomain         @"FKHelperMachErrorDomain"

#define FKHelperMachErrorNoClass        101
#define FKHelperMachErrorNoServices     102

@interface FKHelper : NSObject

+ (instancetype)sharedHelper;

- (BOOL)setFnKeyState:(BOOL)state error:(NSError * __autoreleasing *)error;

@end
