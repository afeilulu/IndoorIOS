//
//  CADIndexCollectionViewCell.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/2/21.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADIndexCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;

-(void)LoadCell:(NSString*)title;

@end
