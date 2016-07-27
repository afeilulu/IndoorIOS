//
//  CADAccountDetailCell.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CADGillSansLabel.h"

@interface CADAccountDetailCell : UITableViewCell

+ (CADAccountDetailCell*) makeCell;

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet CADGillSansLightLabel *name;
@property (weak, nonatomic) IBOutlet UILabel *fee;
@property (weak, nonatomic) IBOutlet UILabel *score;

@property (weak, nonatomic) IBOutlet UIControl *statusContainer1;
- (IBAction)statusContainer1Action:(id)sender;

@property (weak, nonatomic) IBOutlet UIControl *statusContainer2;
- (IBAction)statusContainer2Action:(id)sender;

@property (weak, nonatomic) IBOutlet UIControl *statusContainer3;
- (IBAction)statusContainer3Action:(id)sender;

@property (weak, nonatomic) IBOutlet UIControl *statusContainer4;
- (IBAction)statusContainer4Action:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *status1name;
@property (weak, nonatomic) IBOutlet UILabel *status1value;

@property (weak, nonatomic) IBOutlet UILabel *status2name;
@property (weak, nonatomic) IBOutlet UILabel *status2value;

@property (weak, nonatomic) IBOutlet UILabel *status3name;
@property (weak, nonatomic) IBOutlet UILabel *status3value;

@property (weak, nonatomic) IBOutlet UILabel *status4name;
@property (weak, nonatomic) IBOutlet UILabel *status4value;

@end
