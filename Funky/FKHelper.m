//
//  FKHelper.m
//  Funky
//
//  Created by Cătălin Stan on 02/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import "FKHelper.h"
#import <mach/mach.h>

@interface FKHelper ()

- (NSError *)machErrorWithResult:(kern_return_t)res;

@end

@implementation FKHelper

+ (instancetype)sharedHelper {
    static FKHelper *sharedHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[FKHelper alloc] init];
    });
    return sharedHelper;
}

- (NSError *)machErrorWithResult:(kern_return_t)res {
    NSString *description = [NSString stringWithUTF8String:mach_error_string(res)] ? : [NSString stringWithFormat:@"Unknown kernel result code: %d", res];
    
    NSError *error = [NSError errorWithDomain:FKHelperMachErrorDomain code:@(res).integerValue userInfo:@{NSLocalizedDescriptionKey: description}];
    
    return error;
}

- (BOOL)setFnKeyState:(BOOL)state error:(NSError *__autoreleasing *)error {
    
    kern_return_t ret;
    mach_port_t port;
    
    ret = IOMasterPort(bootstrap_port, &port);
    if ( ret != KERN_SUCCESS ) {
        if ( error != NULL ) {
            *error = [self machErrorWithResult:ret];
        }
        return NO;
    }
    
    CFDictionaryRef class = IOServiceMatching(kIOHIDSystemClass);
    if ( class == NULL ) {
        if ( error != NULL ) {
            *error = [NSError errorWithDomain:FKHelperMachErrorDomain code:FKHelperMachErrorNoClass userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No matching IO Class: %s", kIOHIDSystemClass]}];
        }
        return NO;
    }
    
    io_iterator_t iterator;
    ret = IOServiceGetMatchingServices(port, class, &iterator);
    if ( ret != KERN_SUCCESS ) {
        if ( error != NULL ) {
            *error = [self machErrorWithResult:ret];
        }
        return NO;
    }
    
    io_service_t service = IOIteratorNext(iterator);
    IOObjectRelease(iterator);
    
    if ( !service ){
        if ( error != NULL ) {
            *error = [NSError errorWithDomain:FKHelperMachErrorDomain code:FKHelperMachErrorNoServices userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No matching services for class %s", kIOHIDSystemClass]}];
        }
        return NO;
    }
    
    io_connect_t connect;
    ret = IOServiceOpen(service, mach_task_self(), kIOHIDParamConnectType, &connect);
    if ( ret != KERN_SUCCESS ) {
        if ( error != NULL ) {
            *error = [self machErrorWithResult:ret];
        }
        return NO;
    }
    
    unsigned int val = state;
    ret = IOHIDSetParameter(connect, CFSTR(kIOHIDFKeyModeKey), &val, sizeof(val));
    if ( ret != KERN_SUCCESS ) {
        if ( error != NULL ) {
            *error = [self machErrorWithResult:ret];
        }
        IOServiceClose(connect);
        return NO;
    }
    
    IOServiceClose(connect);
    return YES;
}

@end
