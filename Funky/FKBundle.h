//
//  FKBundle.h
//  Funky
//
//  Created by Cătălin Stan on 20/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FKBundleNameKey             @"name"
#define FKBundlePathKey             @"path"
#define FKBundleExecutablePathKey   @"executablePath"
#define FKBundleIdentifierKey       @"identifier"
#define FKBundleImageKey            @"image"

@interface FKBundle : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *executablePath;
@property (nonatomic, strong) NSImage *image;

@property (nonatomic, readonly) BOOL available;

+ (instancetype __autoreleasing)bundleWithURL:(NSURL *)URL;

- (instancetype)initWithURL:(NSURL *)URL;

@end
