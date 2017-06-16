//
//  OMMSearchTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 15/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMSearchTableViewController.h"
#import "OMMTask.h"
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMSearchTableViewController () <UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSMutableArray *tasksArray;
@property (nonatomic, strong) NSArray *resultTaskArray;
@property (nonatomic, strong) UISearchController *searchController;


@end

@implementation OMMSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    OMMTask *testTask = [[OMMTask alloc] init];
    testTask.name = @"task1";
    testTask.note = @"task1 notes";
    testTask.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    OMMTask *testTask2 = [[OMMTask alloc] init];
    testTask2.name = @"task2";
    testTask2.note = @"task2 notes";
    testTask2.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    OMMTask *testTask3 = [[OMMTask alloc] init];
    testTask3.name = @"task3";
    testTask3.note = @"task3 notes";
    testTask3.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    self.tasksArray = [[NSMutableArray alloc] initWithObjects:testTask, testTask2, testTask3, nil];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[@"All tasks", @"Completed"];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.resultTaskArray = self.tasksArray;
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultTaskArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"OMMTaskCell" bundle:nil] forCellReuseIdentifier:@"OMMTaskCellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    }
    
    OMMTask *task = [self.resultTaskArray objectAtIndex:indexPath.row];
    cell.taskName.text = task.name;
    cell.taskStartDate.text = @"";
    cell.taskNote.text = @"";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchController.searchBar.text];
    //    NSArray *tasksNameArray = [self.tasksArray valueForKeyPath:@"@unionOfObjects.name"];
    // NSLog(@"%@", tasksNameArray);
    self.resultTaskArray = [self.resultTaskArray filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTask *task = [self.tasksArray objectAtIndex:indexPath.row];
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    taskDetails.task = task;
//    self.searchController.searchBar.showsScopeBar = NO;
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:taskDetails];
}

- (NSArray *)findMatchesInArray:(NSArray *)array {
    
    
    return _resultTaskArray;
}




@end
