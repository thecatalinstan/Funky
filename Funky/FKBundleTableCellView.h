//
//  FKBundleTableCellView.h
//  Funky
//
//  Created by Cătălin Stan on 22/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FKBundleTableCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSTextField *pathLabel;
@property (weak) IBOutlet NSImageView *thumbnailImageView;

@end
