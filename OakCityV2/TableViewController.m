//
//  TableViewController.m
//  OakCityV2
//
//  Created by Josh Green on 6/8/15.
//  Copyright (c) 2015 Josh Green. All rights reserved.
//

#import "TableViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "DetailViewController.h"
#import "DetailCell.h"
#import "Job.h"
#import "AFNetworking/UIImageView+AFNetworking.h"

#define LANGUAGE @"PHP"
#define TOWN @"San+Francisco"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Fetch JSON
    NSString *urlAsString = [NSString stringWithFormat:@"https://jobs.github.com/positions.json?description=%@&location=%@", LANGUAGE, TOWN];
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //Parse JSON
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.jobs  = (NSArray *)responseObject;
        
        NSLog(@"%@", responseObject);
        
        if([self.jobs count] > 0) {
            [self.tableView reloadData];
        }
        
        //Alert on failure to fetch JSON
        else {
            UIAlertView* alert = [[UIAlertView alloc]
                                       initWithTitle: @"Failed to retrieve data" message: nil delegate: self
                                       cancelButtonTitle: @"cancel" otherButtonTitles: @"Retry", nil];
            [alert show];
        }
    }
    
    //Alert on fundemental errors
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         UIAlertView *aV = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:[error localizedDescription] delegate: nil
                                                   cancelButtonTitle:@"Ok" otherButtonTitles:nil];
         [aV show];
     }];
    [operation start];
    
}

//Alert View
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *button = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([button isEqualToString:@"Retry"]) {
        //Fetch JSON
        NSString *urlAsString = [NSString stringWithFormat:@"https://jobs.github.com/positions.json?description=%@&location=%@", LANGUAGE, TOWN];
        NSURL *url = [NSURL URLWithString:urlAsString];
        NSURLRequest *request = [NSURLRequest requestWithURL: url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        //Parse JSON
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
             self.jobs  = (NSArray *)responseObject;
             [self.tableView reloadData];
         }
         
         //Upon failure
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             UIAlertView *aV = [[UIAlertView alloc]
                                initWithTitle:@"Error" message:[error localizedDescription] delegate: nil
                                cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [aV show];
         }];
        [operation start];
    }
    
}

//Pull to refresh
- (IBAction)refresh:(UIRefreshControl *)sender
{
    //Fetch JSON
    NSString *urlAsString = [NSString stringWithFormat:@"https://jobs.github.com/positions.json?description=%@&location=%@", LANGUAGE, TOWN];
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //Parse JSON
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        self.jobs  = (NSArray *)responseObject;
        [self.tableView reloadData];
    }
     
    //Upon failure
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
    [sender endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.jobs.count;
}

- (CGFloat)tableView:(UITableView *)tableView
estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

//Fill TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];

    [cell.titleLabel setText:self.jobs[indexPath.row][@"title"]];
    [cell.companyLabel setText:self.jobs[indexPath.row][@"company"]];
    if (self.jobs[indexPath.row][@"company_logo"] != [NSNull null])
    {
        [cell.logoImageView setImageWithURL:[NSURL URLWithString:self.jobs[indexPath.row][@"company_logo"]] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    }
    else
    {
        [cell.logoImageView setImage:[UIImage imageNamed:@"placeholder.jpg"]];
    }
    
    return cell;
    
    //Partition out setText to DetailCell.m
    
    /*
    DataObject *data = self.jobs[indexPath.row];
    [cell.titleLabel setText:data.title];
    [cell.companyLabel setText:data.company];
    if (self.jobs[indexPath.row][@"company_logo"] != [NSNull null])
    {
        [cell.logoImageView setImageWithURL:[NSURL URLWithString:data.logo] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    }
    else
    {
        [cell.logoImageView setImage:[UIImage imageNamed:@"placeholder.jpg"]];
    }
    */
}

//Fill DetailView
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Identifier"])
    {
        DetailViewController *DetailVC = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        DetailVC.ttitle = self.jobs[indexPath.row][@"title"];
        
        DetailVC.company = self.jobs[indexPath.row][@"company"];
        
        if (self.jobs[indexPath.row][@"company_url"] != [NSNull null])
        {
            DetailVC.url = self.jobs[indexPath.row][@"company_url"];
        }
        
        else
        {
            DetailVC.url = @"No URL Provided";
        }
        
        DetailVC.desc = self.jobs[indexPath.row][@"description"];
    }
    
}

@end