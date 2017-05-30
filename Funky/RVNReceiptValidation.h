//
//  RVNReceiptValidation.h
//
//  Created by Satoshi Numata on 12/06/30.
//  Copyright (c) 2012 Sazameki and Satoshi Numata, Ph.D. All rights reserved.
//
//  This sample shows how to write the Mac App Store receipt validation code.
//  Replace kRVNBundleID and kRVNBundleVersion with your own ones.
//
//  This sample is provided because the coding sample found in "Validating Mac App Store Receipts"
//  is somehow out-of-date today and some functions are deprecated in Mac OS X 10.7.
//  (cf. Validating Mac App Store Receipts: )
//
//  You must want to make it much more robustness with some techniques, such as obfuscation
//  with your "own" way. If you use and share the same codes with your friends, attackers
//  will be able to make a special tool to patch application binaries so easily.
//  Again, this sample gives you the very basic idea that which APIs can be used for the validation.
//
//  Don't forget to add IOKit.framework and Security.framework to your project.
//  The main() function should be replaced with the (commented out) main() code at the bottom of this sample.
//  This sample assume that you are using Automatic Reference Counting for memory management.
//
//  Have a nice Cocoa flavor, guys!!
//
#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonDigest.h>
#import <Security/CMSDecoder.h>
#import <Security/SecAsn1Coder.h>
#import <Security/SecAsn1Templates.h>
#import <Security/SecRequirement.h>

#import <IOKit/IOKitLib.h>

void RVNValidate(void);