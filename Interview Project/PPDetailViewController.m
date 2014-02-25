//
//  PPDetailViewController.m
//  Interview Project
//
//  Created by Jens Andersson on 2014-01-29.
//  Copyright (c) 2014 Projectplace. All rights reserved.
//

#import "PPDetailViewController.h"

@interface PPDetailViewController ()

@property (nonatomic, copy) void (^loadImageBlock)();

@end

@implementation PPDetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.detailDescriptionLabel.text = self.post[@"caption"];

    typeof(self) weakSelf = self;
    self.loadImageBlock = ^{
        NSDictionary *photo = _post[@"photos"][0];
        NSString *smallUrl = [[photo valueForKeyPath:@"alt_sizes.@firstObject"] objectForKey:@"url"];
        
        [weakSelf setImageWithURL:[NSURL URLWithString:smallUrl]];
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), self.loadImageBlock);
}

- (void)setImageWithURL:(NSURL *)url {
    UIImage *image = [UIImage imageWithData:
                      [NSData dataWithContentsOfURL:url]];
    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}

@end
