//
//  JMSwipeCell.m
//  JMSwipeTableViewCell
//
//  Created by Justin Makaila on 11/30/13.
//  Copyright (c) 2013 Justin Makaila. All rights reserved.
//

#import "JMSwipeCell.h"

/**
 *  Percentage limit to trigger the first action
 */
static CGFloat const kJMStop1 = 0.2;

/**
 *  Percentage limit to trigger the second action
 */
static CGFloat const kJMStop2 = 0.000001;

/**
 *  Maximum bounce amplitude
 */
static CGFloat const kBounceAmplitude = 20.0;

/**
 *  Duration of the first part of the bounce animation
 */
static NSTimeInterval const kBounceDuration1 = 0.2;

/**
 *  Duration of the second part of the bounce animation
 */
static NSTimeInterval const kBounceDuration2 = 0.1;

/**
 *  Lowest duration when swiping the cell to simulate velocity
 */
static NSTimeInterval const kJMDurationLowLimit = 0.25;

/**
 *  Highest duration when swiping the cell to simulate velocity
 */
static NSTimeInterval const kJMDurationHighLimit = 0.1;

/**
 *  Interface declaration for JMSwipeCell
 */
@interface JMSwipeCell () {
    /**
     *  Current swipe direction
     */
    JMSwipeDirection direction;
    
    /**
     *  Current percentage dragged
     */
    CGFloat currentPercentage;
}

/**
 *  The pan gesture to detect swipes
 */
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

@end

@implementation JMSwipeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (void)initializer {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panReceived:)];
    panGesture.delegate = self;
    self.panGesture = panGesture;
    [self.contentView addGestureRecognizer:self.panGesture];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.frame = CGRectMake(220, 0, 100, CGRectGetHeight(self.bounds));
    self.deleteButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.deleteButton.backgroundColor = [UIColor redColor];
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:self.deleteButton atIndex:0];
    
    [self prepareForReuse];
}

- (void)prepareForReuse {
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.editable = NO;
    self.dragging = NO;
    direction = kJMSwipeDirectionCenter;
    currentPercentage = 0;
}

#pragma mark - Utils

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToDimension:(CGFloat)dimension {
    CGFloat percentage = offset / dimension;
    
    if (percentage < -1.0) {
        percentage = -1.0;
    }else if (percentage > 1.0) {
        percentage = 1.0;
    }
    
    return percentage;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat height = CGRectGetHeight(self.bounds);
    NSTimeInterval animationDurationDiff = kJMDurationHighLimit - kJMDurationLowLimit;
    CGFloat verticalVelocity = velocity.y;
    
    if (verticalVelocity < -height) {
        verticalVelocity = -height;
    }else if (verticalVelocity > height) {
        verticalVelocity = height;
    }
    
    return (kJMDurationHighLimit + kJMDurationLowLimit) - fabs(((verticalVelocity / height) * animationDurationDiff));
}

- (JMSwipeDirection)directionWithPercentage:(CGFloat)percentage {
    if (percentage < -kJMStop1) {
        return kJMSwipeDirectionLeft;
    }else if (percentage > kJMStop2) {
        return kJMSwipeDirectionRight;
    }else {
        return kJMSwipeDirectionCenter;
    }
}

#pragma mark - Button Actions

- (void)deleteButtonPressed:(UIButton*)sender {
    if ([_delegate respondsToSelector:@selector(deletePressedAtIndex:)]) {
        [_delegate deletePressedAtIndex:self.tag];
    }
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.canEdit) {
        return NO;
    }
    
    if (gestureRecognizer == self.panGesture) {
        CGPoint translation = [self.panGesture translationInView:self.contentView];
        return fabs(translation.x) > fabs(translation.y);
    }else {
        return YES;
    }
}

- (void)panReceived:(UIPanGestureRecognizer*)gesture {
    UIGestureRecognizerState state = gesture.state;
    CGPoint translation = [gesture translationInView:self.contentView];
    CGPoint velocity = [gesture velocityInView:self.contentView];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMinX(self.contentView.frame) relativeToDimension:CGRectGetWidth(self.bounds)];
    direction = [self directionWithPercentage:percentage];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        self.dragging = YES;
        
        if ((direction == kJMSwipeDirectionCenter || direction == kJMSwipeDirectionRight) && (velocity.x > 0 && self.contentView.center.x >= self.center.x)) {
            return;
        }
        
        CGPoint newCenter = { self.contentView.center.x + translation.x, self.contentView.center.y };
        self.contentView.center = newCenter;
        
        [gesture setTranslation:CGPointZero inView:self];
    }else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateEnded) {
        self.dragging = NO;
        
        currentPercentage = percentage;
        
        if (direction == kJMSwipeDirectionLeft && self.contentView.center.x < self.center.x) {
            [self animateToDelete];
        }else {
            [self bounceToOrigin];
        }
    }
}

#pragma mark - Animations

-(void)bounceToOrigin {
    CGFloat bounceDistance = kBounceAmplitude * currentPercentage;
    [UIView animateWithDuration:kBounceDuration1
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = self.contentView.frame;
                         frame.origin.x = -bounceDistance;
                         self.contentView.frame = frame;
                     }completion:^(BOOL finished) {
                         [UIView animateWithDuration:kBounceDuration2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              CGRect frame = self.contentView.frame;
                                              frame.origin.x = 0;
                                              self.contentView.frame = frame;
                                          }completion:nil];
                     }];
}

-(void)animateToDelete {
    [UIView animateWithDuration:kBounceDuration1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGPoint center = { self.center.x - 100, self.contentView.center.y };
                         self.contentView.center = center;
                     }completion:nil];
}

-(void)removeAnimation {
    [UIView animateWithDuration:kBounceDuration1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = self.frame;
                         frame.origin.y = frame.size.height;
                         self.frame = frame;
                     }completion:^(BOOL finished) {
                         [self setHidden:YES];
                         [_delegate deletePressedAtIndex:self.tag];
                     }];
}

@end
