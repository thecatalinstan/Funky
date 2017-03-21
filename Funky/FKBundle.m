//
//  FKBundle.m
//  Funky
//
//  Created by Cătălin Stan on 20/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FKBundle.h"

#define FKBundleNameKey         @"name"
#define FKBundlePathKey         @"path"
#define FKBundleIdentifierKey   @"identifier"
#define FKBundleImageKey        @"image"

@implementation FKBundle

+ (instancetype)bundleWithURL:(NSURL *)URL {
    return [[FKBundle alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if ( self != nil ) {
        NSBundle *bundle = [NSBundle bundleWithURL:URL];
        self.identifier = [bundle.bundleIdentifier copy];
        self.name = [bundle objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
        self.path = [bundle.bundlePath copy];
        self.image = [[NSWorkspace sharedWorkspace] iconForFile:bundle.bundlePath] ? : [NSImage imageNamed:NSImageNameApplicationIcon];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:FKBundleNameKey];
    [coder encodeObject:self.path forKey:FKBundlePathKey];
    [coder encodeObject:self.identifier forKey:FKBundleIdentifierKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if ( self != nil ) {
        self.name = [decoder decodeObjectForKey:FKBundleNameKey];
        self.path = [decoder decodeObjectForKey:FKBundlePathKey];
        self.identifier = [decoder decodeObjectForKey:FKBundleIdentifierKey];
        self.image = [[NSWorkspace sharedWorkspace] iconForFile:self.path] ? : [NSImage imageNamed:NSImageNameApplicationIcon];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", super.description, self.name];
}

- (BOOL)isEqual:(id)object {
    return [self isEqualTo:object];
}

- (BOOL)isEqualTo:(id)object {
    if ( [object isKindOfClass:[self class]] ) {
        return NO;
    }
    return [self.identifier isEqualToString:((FKBundle *) object).identifier];
}

@end
