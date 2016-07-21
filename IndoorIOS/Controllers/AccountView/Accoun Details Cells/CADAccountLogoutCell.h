//
//  CADAccountLogoutCell.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADAccountLogoutCell : UITableViewCell

+ (CADAccountLogoutCell*) makeCell;

- (IBAction)logoutAction:(id)sender;

@end
