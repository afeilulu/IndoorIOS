//
//  CADCoachDetailTableViewController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/22.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADCoachDetailTableViewController.h"
#import "Constants.h"
#import "CADCoachDetailCell.h"
#import "CADCoachAttrCell.h"

#import <UIImageView+WebCache.h>


NSString *const kCoachAttrCellIdentifier = @"CADCoachAttrCell";
NSString *const kCoachAttrCellNibName = @"CADCoachAttrCell";

@interface CADCoachDetailTableViewController ()

@end

@implementation CADCoachDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = self.coach.nick;
    
    // hide empty cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // we use a nib which contains the cell's view and this class as the files owner
    [self.tableView registerNib:[UINib nibWithNibName:kCoachAttrCellNibName bundle:nil] forCellReuseIdentifier:kCoachAttrCellIdentifier];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return self.coach.attrs.count;
            break;
        case 2:
            return 1;
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
                CADCoachDetailCell *detailsCell = [tableView dequeueReusableCellWithIdentifier:@"CADCoachDetailCell"];
                if(detailsCell == nil)
                    detailsCell = [CADCoachDetailCell makeCell];
                
                NSString *imgUrl = [[NSString alloc] initWithFormat:@"%@%@",KImageUrl,self.coach.imageUrl];
                [detailsCell.icon sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
                detailsCell.name.text = self.coach.name;
                
                cell = detailsCell;
            }
            break;
            
        case 1:
        {
            CADCoachAttrCell *attrCell = [tableView dequeueReusableCellWithIdentifier:kCoachAttrCellIdentifier];
            
            NSString *key = [[self.coach.attrs allKeys] objectAtIndex:indexPath.row];
            attrCell.textLabel.text = key;
            attrCell.detailTextLabel.text = [self.coach.attrs objectForKey:key];
            
            cell = attrCell;
        }
            break;
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
                height = 120;
            }
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
