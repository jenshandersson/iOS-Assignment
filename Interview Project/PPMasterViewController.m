//
//  PPMasterViewController.m
//  Interview Project
//
//  Created by Jens Andersson on 2014-01-29.
//  Copyright (c) 2014 Projectplace. All rights reserved.
//

#import "PPMasterViewController.h"
#import "PPDetailViewController.h"
#import <AFNetworking.h>
#import "NSString+StipHTML.h"
#import "UIImageView+Gray.h"

@interface PPMasterViewController () {
}

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic) PPDetailViewController *detailView;
@property (nonatomic, retain) void (^successCallback)(NSArray *posts);
@property (nonatomic) NSMutableDictionary *cachedImages;

@property (nonatomic) UILabel *descriptionLabel;

// Used for tracking.
@property (nonatomic) NSMutableArray *clickedTitles;

@end

@implementation PPMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clickedTitles = (NSMutableArray *) @[];
    self.cachedImages = [NSMutableDictionary dictionary];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchData)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    void (^successCallback)(NSArray *posts) = ^(NSArray *posts) {
        self.posts = posts.mutableCopy;
        [self.tableView reloadData];
    };
    
    self.successCallback = successCallback;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"cachdPosts"];
    NSArray *cachedPosts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.successCallback(cachedPosts);
    
}

- (void)viewDidAppear:(BOOL)animated {
    [UIImageView enableGrayification];
}

- (void)setUpHeaderWithData:(NSDictionary *)info {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.frame, 10, 10)];
    self.descriptionLabel.numberOfLines = 4;
    self.descriptionLabel.text = [info[@"description"] stringByStrippingHTML];
    self.navigationItem.title = info[@"title"];
    
    [headerView addSubview:self.descriptionLabel];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchData {
    NSURL *url = [NSURL URLWithString:@"https://api.tumblr.com/v2/blog/iheartcatgifs.tumblr.com/posts?api_key=yQQKdUWSjfvQ9h6rp1nnpuZrXuYRzOVXSQjuw0vJsAzXBh0buv&limit=50"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *blogInfo = [JSON valueForKeyPath:@"response.blog"];
        [self setUpHeaderWithData:blogInfo];
        
        NSArray *posts = [JSON valueForKeyPath:@"response.posts"];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:posts];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"cachedPosts"];
        self.successCallback(posts);
    } failure:nil];
    [operation start];
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *post = self.posts[indexPath.row];
    
    NSString *caption = [post[@"caption"] stringByStrippingHTML];
    
    if (caption.length == 0)
        caption = @"<NO CAPTION>";
    
    cell.textLabel.text = caption;
    
    NSDictionary *photo = post[@"photos"][0];
    NSString *smallUrl = [[photo valueForKeyPath:@"alt_sizes.@firstObject"] objectForKey:@"url"];
    
    // Fetch images on seperate thread
    UIImage *cachedImage = self.cachedImages[post[@"id"]];
    if (cachedImage){
        cell.imageView.image = cachedImage;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *image = [UIImage imageWithData:
                              [NSData dataWithContentsOfURL:[NSURL URLWithString:smallUrl]]];
            if (!image) return;
            self.cachedImages[post[@"id"]] = image;
            cell.imageView.image = image;
        });
    }
    

    // Is this the most shared post?
    NSNumber *noteCount = post[@"note_count"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Notes: %@", noteCount];
    BOOL isTheMostShared = YES;
    for (NSDictionary *p in self.posts) {
        if ([p[@"note_count"] compare:noteCount] == NSOrderedAscending) {
            isTheMostShared = NO;
        }
    }
    if (isTheMostShared) {
        cell.textLabel.textColor = [UIColor greenColor];
    }
    
    return cell;
}

#pragma mark - Master delegate

- (void)reloadDataFromAPI {
    [self fetchData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *post = self.posts[indexPath.row];
        NSString *title = post[@"source_title"];
        
        // Add each clicked source to this array for tracking purposes
        [self.clickedTitles addObject:title];
        
        self.detailView = [segue destinationViewController];
        self.detailView.masterDelegate = self;
        [self.detailView setPost:post];
        
        // Remove cat from list when taping on it.
        // Don't want to see that cat again.
        [self.posts removeObjectAtIndex:indexPath.row];
    }
}

- (void)dealloc {
    
}

@end
