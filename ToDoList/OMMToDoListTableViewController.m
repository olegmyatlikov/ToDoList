//
//  OMMToDoListTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 19/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMToDoListTableViewController.h"
#import "NSDate+OMMDateConverter.h"
#import "UIView+OMMHeaderInSection.h"
#import "OMMTask.h"
#import "OMMTasksGroup.h"
#import "OMMTaskService.h"


@interface OMMToDoListTableViewController ()

@property (nonatomic, strong) OMMTaskService *taskService;
@property (nonatomic, strong) NSArray *tasksGroupArray;

@end

@implementation OMMToDoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskService = [OMMTaskService sharedInstance];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tasksGroupArray = self.taskService.tasksGroupsArray;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskWasCreatedOrEdited:) name:@"TaskWasCreatedOrEdited" object:nil];
}

- (void)triggerTaskWasCreatedOrEdited:(NSNotification *)notification {
    self.tasksGroupArray = self.taskService.tasksGroupsArray;
    [self.tableView reloadData];
}


#pragma mark - Setup UI for tableView

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    return [UIView createViewForHeaderInSection:tableView withTitle:sectionTitle];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 25.f;
    } else {
        return 50.f;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @" ";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.tasksGroupArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskListTableVCCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskListTableVCCell"];
    }
    
    OMMTasksGroup *taskGroup = [[OMMTasksGroup alloc] init];
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Inbox";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)", self.taskService.allTasksArray.count];
    } else {
        taskGroup = [self.taskService.tasksGroupsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = taskGroup.groupName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu)", [taskGroup.tasksArray count]];
    }
    
    return cell;
}


@end
