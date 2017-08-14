//
//  OMMNotificationTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 03/07/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMNotificationTableViewController.h"
#import "NSDate+OMMDateConverter.h"
#import "UIView+OMMHeaderInSection.h"

@interface OMMNotificationTableViewController ()

@property (nonatomic, strong) NSArray *notificationsArray;

@end


@implementation OMMNotificationTableViewController


#pragma mark - Constants

static NSString * const OMMNotificationCellIdentifair = @"OMMNotificationCell";
static NSString * const OMMNotificationDictUserInfoNotifyName = @"notificationInfo";
static NSString * const OMMNotificationDictUserInfoNotifyDate = @"notificationDate";
static NSString * const OMMNotificationTaskWasModifyNotification = @"TaskListWasModify";
static NSString * const OMMNotificationSortDescriptorKeyFireDate = @"fireDate";


#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.notificationsArray = [self allLocalNotificationsSortedByDate];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationsArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    return [UIView createViewForHeaderInSection:tableView withTitle:sectionTitle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OMMNotificationCellIdentifair forIndexPath:indexPath];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:OMMNotificationCellIdentifair forIndexPath:indexPath];
    }
    UILocalNotification *notification = [self.notificationsArray objectAtIndex:indexPath.row];
    NSDictionary *userInfoNotificationDictionary = notification.userInfo;
    cell.textLabel.text = [userInfoNotificationDictionary objectForKey:OMMNotificationDictUserInfoNotifyName];
    cell.detailTextLabel.text = [userInfoNotificationDictionary objectForKey:OMMNotificationDictUserInfoNotifyDate];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - other methods

- (NSArray *)allLocalNotificationsSortedByDate {
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSSortDescriptor *sortByDateDescriptor = [[NSSortDescriptor alloc] initWithKey:OMMNotificationSortDescriptorKeyFireDate ascending:YES];
    NSArray *sortDescriptorsArray = @[sortByDateDescriptor];
    return [allNotifications sortedArrayUsingDescriptors:sortDescriptorsArray];
}

- (void)refreshData {
    self.notificationsArray = [self allLocalNotificationsSortedByDate];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


@end
