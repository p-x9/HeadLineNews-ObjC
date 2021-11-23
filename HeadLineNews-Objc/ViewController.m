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
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) UIStackView *contentStackView;
@property (strong, nonatomic) UISlider *speedSlider;
@property (strong, nonatomic) UITextField *speedTextField;
@property (strong, nonatomic) UISlider *fontSizeSlider;
@property (strong, nonatomic) UITextField *fontSizeTextField;
@property (getter=isRunning, nonatomic) BOOL isRunning;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.url = [[NSURL alloc] initWithString: @"https://news.yahoo.co.jp/rss/topics/top-picks.xml"];
    self.parser = [[RSSParser alloc] init];
    [self setupViews];
    [self setupGestures];
}

- (void)setupViews {
    [self setupHeadLineNewsView];
    [self setupContentViews];
    [self setupSettingViews];
}

- (void)setupContentViews {
    self.contentScrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    self.contentStackView = [[UIStackView alloc] initWithFrame: CGRectZero];
    
    self.contentStackView.alignment = UIStackViewAlignmentCenter;
    self.contentStackView.axis = UILayoutConstraintAxisVertical;
    self.contentStackView.distribution = UIStackViewDistributionEqualSpacing;
    self.contentStackView.spacing = 12;
    
    [self.view addSubview: self.contentScrollView];
    [self.contentScrollView addSubview: self.contentStackView];
    
    self.contentScrollView.translatesAutoresizingMaskIntoConstraints = false;
    self.contentStackView.translatesAutoresizingMaskIntoConstraints = false;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.contentScrollView.topAnchor constraintEqualToAnchor:self.headlineNewsView.bottomAnchor constant:48],
        [self.contentScrollView.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor],
        [self.contentScrollView.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor],
        [self.contentScrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.contentStackView.topAnchor constraintEqualToAnchor:self.contentScrollView.topAnchor],
        [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.contentScrollView.bottomAnchor],
        [self.contentStackView.widthAnchor constraintEqualToAnchor:self.contentScrollView.widthAnchor],
        [self.contentScrollView.centerXAnchor constraintEqualToAnchor:self.contentScrollView.centerXAnchor]
    ]];
}

- (void)setupSettingViews {
    /* Speed */
    UIStackView *speedStackView = [self makeSettingSectionStackViewWith:@"Speed"];
    self.speedSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    self.speedSlider.continuous = true;
    self.speedSlider.value = 1.0;
    self.speedSlider.minimumValue = 0.0;
    self.speedSlider.maximumValue = 2.0;
    [self.speedSlider addTarget:self action:@selector(handleSpeedSlider:) forControlEvents:UIControlEventValueChanged];
    
    self.speedTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.speedTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.speedTextField.text = @"1.0";
    self.speedTextField.borderStyle = UITextBorderStyleBezel;
    self.speedTextField.textAlignment = NSTextAlignmentCenter;
    [self.speedTextField addTarget:self action:@selector(handleSpeedTextField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [speedStackView addArrangedSubview:self.speedSlider];
    [speedStackView addArrangedSubview:self.speedTextField];
    [self.contentStackView addArrangedSubview:speedStackView];
    [NSLayoutConstraint activateConstraints:@[
        [speedStackView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor constant:-48],
        [self.speedTextField.widthAnchor constraintEqualToConstant:40]
    ]];
    
    /* Font Size */
    UIStackView *fontSizeStackView = [self makeSettingSectionStackViewWith:@"Font Size"];
    self.fontSizeSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    self.fontSizeSlider.continuous = true;
    self.fontSizeSlider.contentScaleFactor = 1;
    self.fontSizeSlider.minimumValue = 10;
    self.fontSizeSlider.maximumValue = 30;
    self.fontSizeSlider.value = self.headlineNewsView.font.pointSize;
    [self.fontSizeSlider addTarget:self action:@selector(handleFontSizeSlider:) forControlEvents:UIControlEventValueChanged];
    
    self.fontSizeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.fontSizeTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.fontSizeTextField.text = @"10";
    self.fontSizeTextField.borderStyle = UITextBorderStyleBezel;
    self.fontSizeTextField.textAlignment = NSTextAlignmentCenter;
    [self.fontSizeTextField addTarget:self action:@selector(handleFontSizeTextField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [fontSizeStackView addArrangedSubview:self.fontSizeSlider];
    [fontSizeStackView addArrangedSubview:self.fontSizeTextField];
    [self.contentStackView addArrangedSubview:fontSizeStackView];
    [NSLayoutConstraint activateConstraints:@[
        [fontSizeStackView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor constant:-48],
        [self.fontSizeTextField.widthAnchor constraintEqualToConstant:40]
    ]];
    
    /* Text Color */
    UIStackView *textColorStackView = [self makeSettingSectionStackViewWith:@"Font Color"];
    UIColorWell *textColorwell = [[UIColorWell alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    textColorwell.title = @"Font Color";
    textColorwell.selectedColor = self.headlineNewsView.textColor;
    [textColorwell addTarget:self action:@selector(handleTextColorWell:) forControlEvents:UIControlEventValueChanged];
    
    [textColorStackView addArrangedSubview:textColorwell];
    [self.contentStackView addArrangedSubview:textColorStackView];
    [NSLayoutConstraint activateConstraints:@[
        [textColorStackView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor constant:-48],
    ]];
    
    /* Background Color */
    UIStackView *backColorStackView = [self makeSettingSectionStackViewWith:@"Background Color"];
    UIColorWell *backColorwell = [[UIColorWell alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    backColorwell.title = @"Background Color";
    backColorwell.selectedColor = self.headlineNewsView.backgroundColor;
    [backColorwell addTarget:self action:@selector(handleBackColorWell:) forControlEvents:UIControlEventValueChanged];
    
    [backColorStackView addArrangedSubview:backColorwell];
    [self.contentStackView addArrangedSubview:backColorStackView];
    [NSLayoutConstraint activateConstraints:@[
        [backColorStackView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor constant:-48],
    ]];
    
}


- (void)setupHeadLineNewsView {
    self.headlineNewsView = [[HeadLineNewsView alloc] initWithFrame:CGRectZero];
    self.headlineNewsView.speed = 0.8;
    self.headlineNewsView.delegate = self;
    
    [self.view addSubview: self.headlineNewsView];
    
    self.headlineNewsView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [self.headlineNewsView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.headlineNewsView.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor],
        [self.headlineNewsView.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor],
        [self.headlineNewsView.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)setupGestures {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.headlineNewsView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [self.headlineNewsView addGestureRecognizer:longPressGesture];
}

-(UIStackView *)makeSettingSectionStackViewWith:(NSString *)title{
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 24;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = title;
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    [stackView addArrangedSubview:label];
    
    
    return stackView;
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

- (void)handleSpeedSlider:(UISlider *)sender {
    self.headlineNewsView.speed = sender.value;
    self.speedTextField.text = [NSString stringWithFormat:@"%.1f",sender.value];
}

- (void)handleSpeedTextField:(UITextField *)sender {
    self.headlineNewsView.speed = sender.text.floatValue;
    self.speedSlider.value = sender.text.floatValue;
}

- (void)handleFontSizeSlider:(UISlider *)sender {
    self.headlineNewsView.font = [UIFont fontWithName:self.headlineNewsView.font.fontName size:sender.value];
    self.fontSizeTextField.text = [NSString stringWithFormat:@"%.0f",sender.value];
}

- (void)handleFontSizeTextField:(UITextField *)sender {
    self.headlineNewsView.font = [UIFont fontWithName:self.headlineNewsView.font.fontName size:sender.text.floatValue];
    self.speedSlider.value = sender.text.floatValue;
}

-(void)handleTextColorWell:(UIColorWell *)sender {
    self.headlineNewsView.textColor = sender.selectedColor;
}

-(void)handleBackColorWell:(UIColorWell *)sender {
    self.headlineNewsView.backgroundColor = sender.selectedColor;
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
