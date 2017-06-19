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
    testTask.name = @"Natallis";
    testTask.note = @"task1 notes";
    testTask.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    OMMTask *testTask2 = [[OMMTask alloc] init];
    testTask2.name = @"Oleg";
    testTask2.note = @"task2 notes";
    testTask2.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    OMMTask *testTask3 = [[OMMTask alloc] init];
    testTask3.name = @"Bogdan";
    testTask3.note = @"task3 notes";
    testTask3.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    self.tasksArray = [[NSMutableArray alloc] initWithObjects:testTask, testTask2, testTask3, nil];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[@"All tasks", @"Completed"];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES; // hide searchController if present another viewController and do visible if go back
    
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
    cell.taskNote.text = task.note;
    cell.taskStartDate.text = [task.startDate convertDateToString];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}


#pragma mark - search and update result

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultTaskArray = self.tasksArray;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    if (searchText.length != 0) {
        self.resultTaskArray = [self.resultTaskArray filteredArrayUsingPredicate:predicate];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTask *task = [self.tasksArray objectAtIndex:indexPath.row];
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    taskDetails.task = task;
    [self.navigationController pushViewController:taskDetails animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.resultTaskArray = self.tasksArray;
}


@end
