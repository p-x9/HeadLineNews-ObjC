//
//  ViewController.m
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/09/28.
//  
//

#import "ViewController.h"
#import "RSSParser.h"
#import "Item.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [[NSURL alloc] initWithString:@"https://news.yahoo.co.jp/rss/topics/top-picks.xml"];
    RSSParser *parser = [[RSSParser alloc] init];
    [parser parseWithURL:url completionHandler:^(NSArray *items, NSError *error) {
        [items enumerateObjectsUsingBlock:^(Item*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%@",item.title);
        }];
    }];
}


@end
