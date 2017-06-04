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
#import "OMMTaskDetailViewController.h"

@interface OMMInboxTableViewController ()

@property (strong, nonatomic) NSMutableArray* tasksArray;

@end

@implementation OMMInboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tasksArray = [[NSMutableArray alloc] init];
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
     NSString *identifier = @"Cell";
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
     
     OMMTask *nameOfTask = [self.tasksArray objectAtIndex:indexPath.row];
     cell.textLabel.text = nameOfTask.name;
     cell.detailTextLabel.text = [nameOfTask.finishDate convertDateToString];
 
 return cell;
 }


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTask *task = [self.tasksArray objectAtIndex:indexPath.row];
    //UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //OMMTaskDetailViewController *taskDetailViewController = [stryBoard instantiateViewControllerWithIdentifier:@"DetailTask"];
    //[taskDetailViewController setTask:task];
    NSLog(@" task.name = %@", task.name);

}


- (void)addNewTaskInTaskArray:(id)task {
    [self.tasksArray addObject:task];
    [self.tableView reloadData];
}




@end
