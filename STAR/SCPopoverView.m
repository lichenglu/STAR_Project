//
//  SCPopoverView.m
//  smartchat
//
//  Created by Yong Lin on 9/5/15.
//  Copyright © 2015 palmdrive. All rights reserved.
//

#import "SCPopoverView.h"


#define kArrowHeight 8.f
#define kArrowCurvature 6.f
#define SPACE 2.f
#define ROW_HEIGHT 44.f
#define TITLE_FONT [UIFont appMediumFontWithSize:15]
#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
#define MDK_SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define MDK_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define kPopoverMinWidth  92

@interface SCPopoverView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic) CGPoint showPoint;

@property (nonatomic, strong) UIButton *handerView;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation SCPopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.borderColor = RGB(200, 199, 204);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithPoint:(CGPoint)point titles:(NSArray *)titles images:(NSArray *)images
{
    self = [super init];
    if (self) {
        self.showPoint = point;
        self.titleArray = titles;
        self.imageArray = images;
        
        self.frame = [self getViewFrame];
        
        [self addSubview:self.tableView];
        
    }
    return self;
}

- (CGRect)getViewFrame
{
    CGRect frame = CGRectZero;
    
    frame.size.height = [self.titleArray count] * ROW_HEIGHT + SPACE + kArrowHeight;
    
    frame.size.width = kPopoverMinWidth;
    for (NSString *title in self.titleArray) {
        CGFloat width =  [title sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByCharWrapping].width;
        frame.size.width = MAX(width, frame.size.width);
    }
    
    if ([self.titleArray count] == [self.imageArray count]) {
        frame.size.width = 10 + 25 + 10 + frame.size.width + 40;
    }else{
        frame.size.width = 10 + frame.size.width + 40;
    }
    
    frame.origin.x = self.showPoint.x - frame.size.width/2;
    frame.origin.y = self.showPoint.y;
    
    //左间隔最小5x
    if (frame.origin.x < 5) {
        frame.origin.x = 5;
    }
    //右间隔最小5x
    if ((frame.origin.x + frame.size.width) > MDK_SCREEN_WIDTH - 5) {
        frame.origin.x = MDK_SCREEN_WIDTH - 5 - frame.size.width;
    }
    
    return frame;
}

- (void)showWithSelectedIndex:(NSInteger)index
{
    self.selectedIndex = index;
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
    [_handerView setBackgroundColor:[UIColor clearColor]];
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:_handerView];
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    self.frame = [self getViewFrame];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)dismiss
{
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animate
{
    if (!animate) {
        [_handerView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_handerView removeFromSuperview];
    }];
    
}


#pragma mark - UITableView

- (UITableView *)tableView
{
    if (_tableView != nil) {
        return _tableView;
    }
    
    CGRect rect = self.frame;
    rect.origin.x = SPACE;
    rect.origin.y = kArrowHeight + SPACE;
    rect.size.width -= SPACE * 2;
    rect.size.height -= (SPACE - kArrowHeight);
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceHorizontal = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView setTintColor:[UIColor whiteColor]];
//    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    return _tableView;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.backgroundView = [[UIView alloc] init];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    if ([_imageArray count] == [_titleArray count]) {
        cell.imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectRowAtIndex) {
        self.selectRowAtIndex(indexPath.row);
    }
    self.selectedIndex = indexPath.row;
    [self.tableView reloadData];
//    [self dismiss:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.borderColor set]; //设置线条颜色
    
    CGRect frame = CGRectMake(0, kArrowHeight, self.bounds.size.width, self.bounds.size.height - kArrowHeight);
    
    float xMin = CGRectGetMinX(frame);
    float yMin = CGRectGetMinY(frame);
    
    float xMax = CGRectGetMaxX(frame);
    float yMax = CGRectGetMaxY(frame);
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    
    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
    [popoverPath moveToPoint:CGPointMake(xMin, yMin)];//左上角
    
    /********************向上的箭头**********************/
    [popoverPath addLineToPoint:CGPointMake(arrowPoint.x - kArrowHeight*0.75, yMin)];//left side
    [popoverPath addLineToPoint:arrowPoint];//actual arrow point
    [popoverPath addLineToPoint:CGPointMake(arrowPoint.x + kArrowHeight*0.75, yMin)];//right side
    /********************向上的箭头**********************/
    
    
    [popoverPath addLineToPoint:CGPointMake(xMax, yMin)];//右上角
    
    [popoverPath addLineToPoint:CGPointMake(xMax, yMax)];//右下角
    
    [popoverPath addLineToPoint:CGPointMake(xMin, yMax)];//左下角
    
    //填充颜色
    [RGB(88, 88, 88) setFill];
    [popoverPath fill];
    
    [popoverPath closePath];
    [popoverPath stroke];
}


@end
