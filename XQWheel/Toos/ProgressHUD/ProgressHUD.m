//
//  ProgressHUD.m
//  ProgressHUD-obj-C
//
//  Created by apple on 16/7/12.
//  Copyright © 2016年 ANGELEN. All rights reserved.
//

#import "ProgressHUD.h"

@interface ProgressHUD()

@property (nonatomic, assign) BOOL interaction;

@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UIToolbar *hud;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *label;

@end

@implementation ProgressHUD

+ (ProgressHUD *)shared {
    static ProgressHUD *progressHUD;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        progressHUD = [[ProgressHUD alloc] init];
    });
    return progressHUD;
}

+ (void)dismiss {
    [[self shared] hudHide];
}

+ (void)show:(NSString *)status {
    [self shared].interaction = YES;
    [[self shared] hudMake:status image:nil spin:YES hide:NO];
}

+ (void)show:(NSString *)status Interaction:(BOOL)Interaction {
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status image:nil spin:YES hide:NO];
}

+ (void)showSuccess:(NSString *)status {
    [self shared].interaction = YES;
    [[self shared] hudMake:status image:HUD_IMAGE_SUCCESS spin:NO hide:YES];
}

+ (void)showSuccess:(NSString *)status Interaction:(BOOL)Interaction {
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status image:HUD_IMAGE_SUCCESS spin:NO hide:YES];
}

+ (void)showError:(NSString *)status {
    [self shared].interaction = YES;
    [[self shared] hudMake:status image:HUD_IMAGE_ERROR spin:NO hide:YES];
}

+ (void)showError:(NSString *)status Interaction:(BOOL)Interaction {
    [self shared].interaction = Interaction;
    [[self shared] hudMake:status image:HUD_IMAGE_ERROR spin:NO hide:YES];
}

- (id)init {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate respondsToSelector:@selector(window)]) {
        self.window = [delegate performSelector:@selector(window)];
    } else {
        self.window = [[UIApplication sharedApplication] keyWindow];
    }
    
    self.background = nil;
    self.hud = nil;
    self.spinner = nil;
    self.image = nil;
    self.label = nil;
    
    self.alpha = 0;
    return self;
}

- (void)hudMake:(NSString *)status image:(UIImage *)img spin:(BOOL)spin hide:(BOOL)hide {
    [self hudCreate];
    self.label.text = status;
    self.label.hidden = (status == nil) ? YES : NO;
    self.image.image = img;
    self.image.hidden = (img == nil) ? YES : NO;
    if (spin) {
        [self.spinner startAnimating];
    } else {
        [self.spinner stopAnimating];
    }
    [self hudSize];
    [self hudPosition:nil];
    [self hudShow];
    if (hide) {
        [NSThread detachNewThreadSelector:@selector(timedHide) toTarget:self withObject:nil];
    }
}

- (void)hudCreate {
    if (self.hud == nil) {
        self.hud = [[UIToolbar alloc] initWithFrame:CGRectZero];
        self.hud.barTintColor = HUD_BACKGROUND_COLOR;
        self.hud.layer.cornerRadius = 10;
        self.hud.layer.masksToBounds = YES;
        [self registerNotifications];
    }
    
    if (self.hud.superview == nil) {
        if (self.interaction == NO) {
            self.background = [[UIView alloc] initWithFrame:self.window.frame];
            self.background.backgroundColor = HUD_WINDOW_COLOR;
            [self.window addSubview:self.background];
            [self.background addSubview:self.hud];
        } else {
            [self.window addSubview:self.hud];
        }
    }
    
    if (self.spinner == nil) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.color = HUD_SPINNER_COLOR;
        self.spinner.hidesWhenStopped = YES;
    }
    
    if (self.spinner.superview == nil) {
        [self.hud addSubview:self.spinner];
    }
    
    if (self.image == nil) {
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    }
    
    if (self.image.superview == nil) {
        [self.hud addSubview:self.image];
    }
    
    if (self.label == nil) {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.font = HUD_STATUS_FONT;
        self.label.textColor = HUD_STATUS_COLOR;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.label.numberOfLines = 0;
    }
    if (self.label.superview == nil) {
        [self.hud addSubview:self.label];
    }
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hudPosition:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)hudDestroy {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.label removeFromSuperview];
    self.label = nil;
    
    [self.image removeFromSuperview];
    self.image = nil;
    
    [self.spinner removeFromSuperview];
    self.spinner = nil;
    
    [self.hud removeFromSuperview];
    self.hud = nil;
    
    [self.background removeFromSuperview];
    self.background = nil;
}

- (void)hudSize {
    CGRect labelRect = CGRectZero;
    CGFloat hudWidth = 100, hudHeight = 100;
    if (self.label.text != nil) {
        NSDictionary *attributes = @{NSFontAttributeName:self.label.font};
        NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
        labelRect = [self.label.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];
        
        labelRect.origin.x = 12;
        labelRect.origin.y = 66;
        
        hudWidth = labelRect.size.width + 24;
        hudHeight = labelRect.size.height + 80;
        
        if (hudWidth < 100) {
            hudWidth = 100;
            labelRect.origin.x = 0;
            labelRect.size.width = 100;
        }
    }
    self.hud.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
    CGFloat imagex = hudWidth/2;
    CGFloat imagey = (self.label.text == nil) ? hudHeight / 2 : 36;
    self.image.center = self.spinner.center = CGPointMake(imagex, imagey);
    self.label.frame = labelRect;
}

- (void)hudPosition:(NSNotification *)notification {
    CGFloat heightKeyboard = 0;
    NSTimeInterval duration = 0;
    if (notification != nil) {
        NSDictionary *info = [notification userInfo];
        CGRect keyboard = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        if ((notification.name == UIKeyboardWillShowNotification) || (notification.name == UIKeyboardDidShowNotification)) {
            heightKeyboard = keyboard.size.height;
        }
    }
    else heightKeyboard = [self keyboardHeight];
    CGPoint center = CGPointMake(WW/2, (HH - 100)/2);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        weakSelf.hud.center = CGPointMake(center.x, center.y);
    } completion:nil];
    
    if (self.background != nil) {
        self.background.frame = self.window.frame;
    }
}

- (CGFloat)keyboardHeight {
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if ([[testWindow class] isEqual:[UIWindow class]] == NO) {
            for (UIView *possibleKeyboard in [testWindow subviews]) {
                if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
                    return possibleKeyboard.bounds.size.height;
                } else if ([[possibleKeyboard description] hasPrefix:@"<UIInputSetContainerView"]) {
                    for (UIView *hostKeyboard in [possibleKeyboard subviews]) {
                        if ([[hostKeyboard description] hasPrefix:@"<UIInputSetHost"])  {
                            return hostKeyboard.frame.size.height;
                        }
                    }
                }
            }
        }
    }
    return 0;
}

- (void)hudShow {
    if (self.alpha == 0) {
        self.alpha = 1;
        
        self.hud.alpha = 0;
        self.hud.transform = CGAffineTransformScale(self.hud.transform, 1.4, 1.4);
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            weakSelf.hud.transform = CGAffineTransformScale(weakSelf.hud.transform, 1/1.4, 1/1.4);
            weakSelf.hud.alpha = 1;
        } completion:nil];
    }
}

- (void)hudHide {
    if (self.alpha == 1) {
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
        __weak typeof(self) weakSelf = self;
        
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            weakSelf.hud.transform = CGAffineTransformScale(weakSelf.hud.transform, 0.7, 0.7);
            weakSelf.hud.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf hudDestroy];
            weakSelf.alpha = 0;
        }];
    }
}

- (void)timedHide {
    @autoreleasepool {
        //        double length = label.text.length;
        //        NSTimeInterval sleep = length * 0.04 + 0.5;
        // 直接固定2s
        [NSThread sleepForTimeInterval:1.5];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hudHide];
        });
    }
}

@end
