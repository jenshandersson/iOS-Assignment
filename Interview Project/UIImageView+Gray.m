//
//  UIImageView+Gray.m
//  Interview Project
//
//  Created by Jens Andersson on 2014-01-29.
//  Copyright (c) 2014 Projectplace. All rights reserved.
//

#import "UIImageView+Gray.h"
#import <objc/runtime.h>

void SwizzleInstanceMethod(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

// Transform the image in grayscale.
UIImage *grayishImage(UIImage *inputImage) {
    
    // Create a graphic context.
    UIGraphicsBeginImageContextWithOptions(inputImage.size, YES, 1.0);
    CGRect imageRect = CGRectMake(0, 0, inputImage.size.width, inputImage.size.height);
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [inputImage drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
    
    // Get the resulting image.
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return filteredImage;
}

@implementation UIImageView (Gray)

#pragma mark - Class methods

+ (void)enableGrayification {
    SwizzleInstanceMethod([UIImageView class], @selector(setImage:), @selector(setGrayImage:));
}


#pragma mark - Instance methods

- (void)setGrayImage:(UIImage *)image {
    
    [self setGrayImage:grayishImage(image)];
}

@end
