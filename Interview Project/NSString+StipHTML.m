//
//  NSString+StipHTML.m
//  Interview Project
//
//  Created by Jens Andersson on 2014-01-29.
//  Copyright (c) 2014 Projectplace. All rights reserved.
//

#import "NSString+StipHTML.h"

@implementation NSString (StipHTML)

-(NSString *)stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end
