//
//  FKBundleTableCellView.m
//  Funky
//
//  Created by Cătălin Stan on 22/03/2017.
//  Copyright © 2017 Cătălin Stan. All rights reserved.
//

#import "FKBundleTableCellView.h"

@implementation FKBundleTableCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    [super setBackgroundStyle:backgroundStyle];
    self.titleLabel.textColor = (backgroundStyle == NSBackgroundStyleLight ? [NSColor labelColor] : [NSColor selectedTextColor]);
}

@end
