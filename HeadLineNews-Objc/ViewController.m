//
//  ViewController.m
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/09/28.
//  
//

#import "ViewController.h"
#import "HeadLineNewsView.h"
#import "RSSParser.h"

@interface ViewController () <HeadLineNewsViewDelegate>
@property (strong, nonatomic) RSSParser *parser;
@property (strong, nonatomic) NSURL *url;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    HeadLineNewsView *headlineNewsView = [[HeadLineNewsView alloc] initWithFrame:CGRectZero];
    headlineNewsView.frame = CGRectMake(0, 100, UIScreen.mainScreen.bounds.size.width, 50);
    headlineNewsView.delegate = self;
    
    [self.view addSubview:headlineNewsView];
    
    self.url = [[NSURL alloc] initWithString: @"https://news.yahoo.co.jp/rss/topics/top-picks.xml"];
    self.parser = [[RSSParser alloc] init];
    
    [self.parser parseWithURL:self.url completionHandler:^(NSArray *items, NSError *error) {
        printf("loaded: %lu",(unsigned long)items.count);
        [headlineNewsView startAnimatingWith:items];
    }];
    
}

- (void)headLineNewsView:(HeadLineNewsView *)view animationEndedWith:(NSArray<Item *> *)items{
    printf("\nlooped");
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


@end
