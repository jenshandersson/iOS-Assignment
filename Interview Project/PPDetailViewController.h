//
//  PPDetailViewController.h
//  Interview Project
//
//  Created by Jens Andersson on 2014-01-29.
//  Copyright (c) 2014 Projectplace. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PPMasterDelegate <NSObject>

- (void)reloadDataFromAPI;

@end


@interface PPDetailViewController : UIViewController

@property (strong, nonatomic) NSDictionary *post;
@property (strong, nonatomic) id<PPMasterDelegate> masterDelegate;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
