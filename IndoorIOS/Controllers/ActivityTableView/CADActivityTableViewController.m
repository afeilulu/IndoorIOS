//
//  CADActivityTableViewController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/19.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADActivityTableViewController.h"
#import "Activity.h"
#import "CADAlertManager.h"
#import "Constants.h"
#import "Utils.h"
#import <UIImageView+WebCache.h>
#import "CADActivityDetailTableViewController.h"
#import "CADStoryBoardUtilities.h"

NSString *const kActivityCellIdentifier = @"activityCellID";
NSString *const kActivityTableCellNibName = @"CADActivityCell";

@interface CADActivityTableViewController ()

@end

@implementation CADActivityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"活 动";
    self.afm = [AFHTTPSessionManager manager];
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kActivityTableCellNibName bundle:nil] forCellReuseIdentifier:kActivityCellIdentifier];
    
    // hide empty cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self getActivityList:@"" atPage:@"1" withPageSize:@"10"];
}

/*
 * 获取活动
 * key:关键字
 * page:第几页
 * pageSize:页面大小
 */
- (void) getActivityList:(NSString*)key atPage:(NSString*)page withPageSize:(NSString*)pageSize {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // reset
    self.timeStamp = @"";
    
    [self.afm POST:kTimeStampUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if ([[responseObject objectForKey:@"success"] boolValue] == true) {
            // update time here
            self.timeStamp = [responseObject objectForKey:@"randTime"];
            
            NSString *beforeMd5 = [[NSString alloc] initWithFormat:@"%@%@",kSecretKey,self.timeStamp ];
            NSDictionary *parameters = @{@"jsonString": [[NSString alloc] initWithFormat:@"{'randTime':'%@','secret':'%@','key':'%@','page':'%@','pageSize':'%@'}",self.timeStamp,[Utils md5:beforeMd5],key,page,pageSize]};
            
            [self.afm POST:KActivityListUrl parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if ([[responseObject objectForKey:@"success"] boolValue] == true) {
                    //                    NSLog(@"JSON: %@", responseObject);
                    
                    self.activities = [[NSMutableArray alloc] init];
                    for (NSDictionary *item in [responseObject objectForKey:@"list"]) {
                        Activity *activity = [[Activity alloc] init];
                        activity.name = [item objectForKey:@"name"];
                        activity.address = [item objectForKey:@"address"];
                        activity.idString = [item objectForKey:@"id"];
                        activity.imageUrl = [item objectForKey:@"logo_url"];
                        activity.startDate = [item objectForKey:@"start_time"];
                        activity.endDate = [item objectForKey:@"end_time"];
                        activity.fee = [item objectForKey:@"fee"];
                        activity.desc = [item objectForKey:@"bak"];
                        activity.initiator = [[item objectForKey:@"customer"] objectForKey:@"name"];
                        activity.contactPhone = [item objectForKey:@"contact_code"];
                        activity.maxNum = [[item objectForKey:@"member_max"] stringValue] ;
                        activity.currentNum = [[item objectForKey:@"member_amount"] stringValue];
                        [self.activities addObject:activity];
                    }
                    [self.tableView reloadData];
                } else {
                    NSString* errmsg = [responseObject objectForKey:@"errmsg"];
                    [CADAlertManager showAlert:self setTitle:@"获取活动错误" setMessage:errmsg];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [CADAlertManager showAlert:self setTitle:@"获取活动错误" setMessage:[error localizedDescription]];
            }];
            
        } else {
            NSString* errmsg = [responseObject objectForKey:@"errmsg"];
            [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:errmsg];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [CADAlertManager showAlert:self setTitle:@"获取时间戳错误" setMessage:[error localizedDescription]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kActivityCellIdentifier forIndexPath:indexPath];
    
//    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    Activity *activity = [self.activities objectAtIndex:indexPath.row];
    
    cell.textLabel.text = activity.name;
    cell.detailTextLabel.text = activity.address;
    
    NSString *imgUrl = [[NSString alloc] initWithFormat:@"%@%@",KImageUrl,activity.imageUrl];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // set back title
    UIBarButtonItem *blankButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:blankButton];
    
    Activity *activity = [self.activities objectAtIndex:indexPath.row];
    
    CADActivityDetailTableViewController * vc = (CADActivityDetailTableViewController *)[CADStoryBoardUtilities viewControllerForStoryboardName:@"ActivityDetail" class:[CADActivityDetailTableViewController class]];
    
    [self.navigationController pushViewController:vc animated:YES];
    [vc setActivity:activity];

    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
