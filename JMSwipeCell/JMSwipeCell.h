//
//  JMSwipeCell.h
//  JMSwipeTableViewCell
//
//  Created by Justin Makaila on 11/30/13.
//  Copyright (c) 2013 Justin Makaila. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kJMSwipeDirectionUp = 0,
    kJMSwipeDirectionCenter,
    kJMSwipeDirectionLeft,
    kJMSwipeDirectionRight,
    kJMSwipeDirectionDown
} JMSwipeDirection;

@protocol JMSwipeCellDelegate <NSObject>
- (void)deletePressedAtIndex:(NSInteger)index;
@end

@interface JMSwipeCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (unsafe_unretained) id<JMSwipeCellDelegate> delegate;

@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIView *cellContent;
@property (strong, nonatomic) UIImageView *pictureView;

@property (strong, nonatomic) UIButton *deleteButton;

@property (nonatomic, getter = isDragging) BOOL dragging;
@property (nonatomic) BOOL shouldDrag;
@property (nonatomic, getter = canEdit) BOOL editable;

@end
