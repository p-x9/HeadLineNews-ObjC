//
//  ViewController.m
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/09/28.
//  
//

#import "ViewController.h"
#import <SafariServices/SafariServices.h>
#import "HeadLineNewsView.h"
#import "RSSParser.h"

@interface ViewController () <HeadLineNewsViewDelegate>
@property (strong, nonatomic) RSSParser *parser;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) HeadLineNewsView *headlineNewsView;
@property (getter=isRunning, nonatomic) BOOL isRunning;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.url = [[NSURL alloc] initWithString: @"https://news.yahoo.co.jp/rss/topics/top-picks.xml"];
    self.parser = [[RSSParser alloc] init];
    [self setupHeadLineNewsView];
    [self setupGestures];
}

- (void)setupHeadLineNewsView {
    self.headlineNewsView = [[HeadLineNewsView alloc] initWithFrame:CGRectZero];
    self.headlineNewsView.frame = CGRectMake(0, 100, UIScreen.mainScreen.bounds.size.width, 50);
    self.headlineNewsView.speed = 0.8;
    self.headlineNewsView.delegate = self;
    
    [self.view addSubview: self.headlineNewsView];
}

- (void)setupGestures {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.headlineNewsView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [self.headlineNewsView addGestureRecognizer:longPressGesture];
}

- (void)headLineNewsView:(HeadLineNewsView *)view animationEndedWith:(NSArray<Item *> *)items{
}

- (NSArray<Item *> *)nextItemsForView:(HeadLineNewsView *)view {
    __block NSArray<Item *> *items = @[];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self.parser parseWithURL:self.url completionHandler:^(NSArray *loadedItems, NSError *error) {
        items = loadedItems;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return  items;
}

- (void)tap:(UIGestureRecognizer *)sender {
    if(!self.isRunning) {
        [self.parser parseWithURL:self.url completionHandler:^(NSArray *items, NSError *error) {
            printf("loaded: %lu",(unsigned long)items.count);
            [self.headlineNewsView startAnimatingWith:items];
        }];
    } else {
        [self openLink];
    }
}

- (void)longTap:(UIGestureRecognizer *)sender {
    [self.headlineNewsView stopAnimation];
}

- (void)openLink {
    Item *item = self.headlineNewsView.currentItem;
    NSString *urlString = item.link;
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    UIViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:safariVC animated:true completion:nil];
}

- (BOOL)isRunning {
    return  self.headlineNewsView.isRunning;
}


@end
