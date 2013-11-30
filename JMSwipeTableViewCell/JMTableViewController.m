//
//  JMTableViewController.m
//  JMSwipeTableViewCell
//
//  Created by Justin Makaila on 11/29/13.
//  Copyright (c) 2013 Justin Makaila. All rights reserved.
//

#import "JMTableViewController.h"
#import "JMSwipeCell.h"

@interface JMTableViewController ()

@property (strong, nonatomic) NSMutableArray *dataModel;

@end

@implementation JMTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataModel = [NSMutableArray arrayWithCapacity:20];
    for (int i = 0; i < 20; i++) {
        self.dataModel[i] = @"Hey!";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataModel.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [tableView registerClass:[JMSwipeCell class] forCellReuseIdentifier:CellIdentifier];
    });
    
    JMSwipeCell *cell = (JMSwipeCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[JMSwipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    if (indexPath.row % 2 == 0) {
        cell.editable = YES;
    }else {
        cell.editable = NO;
    }
    
    cell.textLabel.text = self.dataModel[indexPath.row];
    
    return cell;
}

#pragma mark - JMSwipeCell Delegate

- (void)deletePressedAtIndex:(NSInteger)index {
    NSLog(@"Delete pressed at index %i", index);
    [self.dataModel removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView reloadData];
}

@end