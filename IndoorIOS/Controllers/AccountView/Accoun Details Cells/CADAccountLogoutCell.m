//
//  CADAccountLogoutCell.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/7/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADAccountLogoutCell.h"
#import "CADUserManager.h"

@implementation CADAccountLogoutCell

#pragma mark -
#pragma mark Init Methods

+ (CADAccountLogoutCell*) makeCell
{
    CADAccountLogoutCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CADAccountLogoutCell" owner:self options:nil] objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)logoutAction:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user"];
    
    [[CADUserManager sharedInstance] setUser:nil];
    
    [((UINavigationController *)self.window.rootViewController) popViewControllerAnimated:true];
}
@end
