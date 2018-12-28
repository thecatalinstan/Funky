//
//  main.m
//  Funky
//
//  Created by Cătălin Stan on 01/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RVNReceiptValidation.h"

// Set this to 1 to skip Mac AppStore receipt validation
#ifndef DEVELOPMENT
#   define DEVELOPMENT 0
#endif

int main(int argc, const char * argv[]) {
    @try {
#if !DEBUG && !DEVELOPMENT
        RVNValidate();
#endif
        return NSApplicationMain(argc, argv);
    } @catch (NSException *e) {
        NSLog(@"%@", e.reason);
        return EXIT_FAILURE;
    }
}
