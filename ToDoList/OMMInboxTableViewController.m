//
//  OMMInboxTableViewController.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMInboxTableViewController.h"
#import "NSDate+OMMDateConverter.h"
#import "OMMAddTaskViewController.h"
#import "OMMTask.h"
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMInboxTableViewController ()

@property (strong, nonatomic) NSMutableArray* tasksArray;

@end

@implementation OMMInboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tasksArray = [[NSMutableArray alloc] init];
    
    OMMTask *testTask = [[OMMTask alloc] init];
    testTask.name = @"task1";
    testTask.note = @"task1 notes";
    testTask.startDate = [NSDate convertStringToDate:@"10-04-2017 10:30"];
    testTask.finishDate = [NSDate convertStringToDate:@"11-04-2017 12:00"];
    testTask.priority = low;
    testTask.enableRemainder = NO;
    [self.tasksArray addObject:testTask];
    
    
    //[self.tableView reloadData];
}

- (IBAction)addNewTaskButtonPressed:(UIBarButtonItem *)sender {
    OMMAddTaskViewController *taskAddViewController = [[OMMAddTaskViewController alloc] initWithNibName:@"OMMAddTaskViewController" bundle:nil];
    [taskAddViewController setDelegate:self];
    taskAddViewController.title = @"New task";
    [self.navigationController pushViewController:taskAddViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tasksArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"OMMTaskCell" bundle:nil] forCellReuseIdentifier:@"OMMTaskCellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    }
    
    OMMTask *task = [self.tasksArray objectAtIndex:indexPath.row];
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskFinishDate.text = [task.finishDate convertDateToString];
 
 return cell;
 }

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67.f;
}

#pragma mark - Tap to cell

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTask *task = [self.tasksArray objectAtIndex:indexPath.row];
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    taskDetails.task = task;
    [self.navigationController pushViewController:taskDetails animated:YES];
}


#pragma mark - Delegate method


- (void)addNewTaskInTaskArray:(OMMTask *)task {
    [self.tasksArray addObject:task];
    [self.tableView reloadData];
}


- (void)saveChangesInTaskArray:(OMMTask *)editingTask {
    [self.tableView reloadData];
}




@end
