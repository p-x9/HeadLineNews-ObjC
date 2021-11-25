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
@property (strong, nonatomic) UIColorWell *textColorwell;
@property (strong, nonatomic) UIColorWell *backColorwell;
@property (getter=isRunning, nonatomic) BOOL isRunning;
@end

@implementation ViewController

- (HeadLineNewsView *)headlineNewsView {
    if(!_headlineNewsView){
        _headlineNewsView = [[HeadLineNewsView alloc] initWithFrame:CGRectZero];
        _headlineNewsView.speed = 0.8;
    }
    return _headlineNewsView;
}

- (UIScrollView *)contentScrollView {
    if(!_contentScrollView){
        _contentScrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    }
    return _contentScrollView;
}

- (UIStackView *)contentStackView {
    if(!_contentStackView){
        _contentStackView = [[UIStackView alloc] initWithFrame: CGRectZero];
        
        _contentStackView.alignment = UIStackViewAlignmentCenter;
        _contentStackView.axis = UILayoutConstraintAxisVertical;
        _contentStackView.distribution = UIStackViewDistributionEqualSpacing;
        _contentStackView.spacing = 12;
    }
    
    return _contentStackView;
}

- (UISlider *)speedSlider {
    if(!_speedSlider) {
        _speedSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        _speedSlider.continuous = true;
        _speedSlider.value = 1.0;
        _speedSlider.minimumValue = 0.0;
        _speedSlider.maximumValue = 2.0;
    }
    return _speedSlider;
}

- (UITextField *)speedTextField {
    if(!_speedTextField) {
        _speedTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _speedTextField.keyboardType = UIKeyboardTypeDecimalPad;
        _speedTextField.borderStyle = UITextBorderStyleBezel;
        _speedTextField.textAlignment = NSTextAlignmentCenter;
    }
    return _speedTextField;
}

- (UISlider *)fontSizeSlider {
    if(!_fontSizeSlider) {
        _fontSizeSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        _fontSizeSlider.continuous = true;
        _fontSizeSlider.contentScaleFactor = 1;
        _fontSizeSlider.minimumValue = 10;
        _fontSizeSlider.maximumValue = 30;
    }
    return _fontSizeSlider;
}

- (UITextField *)fontSizeTextField {
    if(!_fontSizeTextField) {
        _fontSizeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _fontSizeTextField.keyboardType = UIKeyboardTypeDecimalPad;
        _fontSizeTextField.text = @"10";
        _fontSizeTextField.borderStyle = UITextBorderStyleBezel;
        _fontSizeTextField.textAlignment = NSTextAlignmentCenter;
    }
    return _fontSizeTextField;
}

- (UIColorWell *)textColorwell {
    if(!_textColorwell) {
        _textColorwell = [[UIColorWell alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _textColorwell.title = @"Font Color";
    }
    return _textColorwell;
}

- (UIColorWell *)backColorwell {
    if(!_backColorwell) {
        _backColorwell = [[UIColorWell alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _backColorwell.title = @"Background Color";
    }
    return _backColorwell;
}

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
    UIStackView *speedStackView = [self makeSettingSectionStackViewWith:@"Speed"
                                                       arrangedSubViews:@[self.speedSlider, self.speedTextField]];
    [self.speedSlider addTarget:self action:@selector(handleSpeedSlider:) forControlEvents:UIControlEventValueChanged];
    [self.speedTextField addTarget:self action:@selector(handleSpeedTextField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.speedTextField.text = [NSString stringWithFormat:@"%.1f",self.headlineNewsView.speed];
    [self.contentStackView addArrangedSubview:speedStackView];
    [NSLayoutConstraint activateConstraints:@[
        [speedStackView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor constant:-48],
        [self.speedTextField.widthAnchor constraintEqualToConstant:40]
    ]];
    
    /* Font Size */
    UIStackView *fontSizeStackView = [self makeSettingSectionStackViewWith:@"Font Size"
                                                          arrangedSubViews:@[self.fontSizeSlider, self.fontSizeTextField]];
    self.fontSizeSlider.value = self.headlineNewsView.font.pointSize;
    [self.fontSizeSlider addTarget:self action:@selector(handleFontSizeSlider:) forControlEvents:UIControlEventValueChanged];
    [self.fontSizeTextField addTarget:self action:@selector(handleFontSizeTextField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.fontSizeTextField.text = [NSString stringWithFormat:@"%.0f",self.headlineNewsView.font.pointSize];
    [self.contentStackView addArrangedSubview:fontSizeStackView];
    [NSLayoutConstraint activateConstraints:@[
        [fontSizeStackView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor constant:-48],
        [self.fontSizeTextField.widthAnchor constraintEqualToConstant:40]
    ]];
    
    /* Text Color */
    UIStackView *textColorStackView = [self makeSettingSectionStackViewWith:@"Font Color"
                                                           arrangedSubViews:@[self.textColorwell]];
    self.textColorwell.selectedColor = self.headlineNewsView.textColor;
    [self.textColorwell addTarget:self action:@selector(handleTextColorWell:) forControlEvents:UIControlEventValueChanged];
    [self.contentStackView addArrangedSubview:textColorStackView];
    [NSLayoutConstraint activateConstraints:@[
        [textColorStackView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor constant:-48],
    ]];
    
    /* Background Color */
    UIStackView *backColorStackView = [self makeSettingSectionStackViewWith:@"Background Color"
                                                           arrangedSubViews:@[self.backColorwell]];
    self.backColorwell.selectedColor = self.headlineNewsView.backgroundColor;
    [self.backColorwell addTarget:self action:@selector(handleBackColorWell:) forControlEvents:UIControlEventValueChanged];
    [self.contentStackView addArrangedSubview:backColorStackView];
    [NSLayoutConstraint activateConstraints:@[
        [backColorStackView.widthAnchor constraintEqualToAnchor:self.contentStackView.widthAnchor constant:-48],
    ]];
    
}


- (void)setupHeadLineNewsView {
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

-(UIStackView *)makeSettingSectionStackViewWith:(NSString *)title arrangedSubViews:(nonnull NSArray<__kindof UIView *> *)views {
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 24;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = title;
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    [stackView addArrangedSubview:label];
    
    [views enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [stackView addArrangedSubview:obj];
    }];
    
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
    
    return items;
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
    return self.headlineNewsView.isRunning;
}


@end
