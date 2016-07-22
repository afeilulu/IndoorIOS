//
//  CADActivityDetailTableViewController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/22.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADActivityDetailTableViewController.h"
#import "CADActivityTopCell.h"
#import "CADActivityDescCell.h"
#import "CADActivityAttrCell.h"
#import "Constants.h"
#import <UIImageView+WebCache.h>


NSString *const kActivityTopCellIdentifier = @"CADActivityTopCell";
NSString *const kActivityTopCellNibName = @"CADActivityTopCell";

NSString *const kActivityDescCellIdentifier = @"CADActivityDescCell";
NSString *const kActivityDescCellNibName = @"CADActivityDescCell";

NSString *const kActivityAttrCellIdentifier = @"CADActivityAttrCell";
NSString *const kActivityAttrCellNibName = @"CADActivityAttrCell";

@interface CADActivityDetailTableViewController ()

@end

@implementation CADActivityDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = self.activity.name;
    
    // hide empty cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kActivityTopCellNibName bundle:nil] forCellReuseIdentifier:kActivityTopCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kActivityDescCellNibName bundle:nil] forCellReuseIdentifier:kActivityDescCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kActivityAttrCellNibName bundle:nil] forCellReuseIdentifier:kActivityAttrCellIdentifier];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1; // 图片
            break;
        case 1:
            return 1; // 介绍
            break;
        case 2:
            return 8; // 其他8个属性
            break;
            
        default:
            break;
    }
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell* cell = nil;
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row ==0){
                CADActivityTopCell *detailsCell = [tableView dequeueReusableCellWithIdentifier:kActivityTopCellIdentifier];
                
                NSString *imgUrl = [[NSString alloc] initWithFormat:@"%@%@",KImageUrl,self.activity.imageUrl];
                [detailsCell.image sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
                
                cell = detailsCell;
            }
            break;
            
        case 1:
        {
            CADActivityDescCell *descCell = [tableView dequeueReusableCellWithIdentifier:kActivityDescCellIdentifier];
            descCell.descLabel.text = self.activity.desc;
            cell = descCell;
            break;
        }
        case 2:
        {
            CADActivityAttrCell *attrCell = [tableView dequeueReusableCellWithIdentifier:kActivityAttrCellIdentifier];
            
            switch (indexPath.row) {
                case 0:
                    attrCell.textLabel.text = @"地址";
                    attrCell.detailTextLabel.text = self.activity.address;
                    break;
                case 1:
                    attrCell.textLabel.text = @"发起人";
                    attrCell.detailTextLabel.text = self.activity.initiator;
                    break;
                case 2:
                    attrCell.textLabel.text = @"联系电话";
                    attrCell.detailTextLabel.text = self.activity.contactPhone;
                    break;
                case 3:
                    attrCell.textLabel.text = @"费用";
                    attrCell.detailTextLabel.text = self.activity.fee;
                    break;
                case 4:
                    attrCell.textLabel.text = @"开始时间";
                    attrCell.detailTextLabel.text = self.activity.startDate;
                    break;
                case 5:
                    attrCell.textLabel.text = @"结束时间";
                    attrCell.detailTextLabel.text = self.activity.endDate;
                    break;
                case 6:
                    attrCell.textLabel.text = @"已报名";
                    attrCell.detailTextLabel.text = self.activity.currentNum;
                    break;
                case 7:
                    attrCell.textLabel.text = @"活动人数";
                    attrCell.detailTextLabel.text = self.activity.maxNum;
                    break;
                default:
                    break;
            }
            
            
            cell = attrCell;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A much nicer way to deal with this would be to extract this code to a factory class, that would return the cells' height.
    CGFloat height = 0;
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                height = 200;
            }
            break;
        }
        case 1:
        {
            height = 100;
            break;
        }
        default:
        {
            height = 44;
            break;
        }
    }
    
    return height;
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
