//
//  CADStartCollectionViewHeader.h
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/18.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CADStartCollectionViewHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *sectionTitle;

-(void) setHeaderWithTitle:(NSString*)title;
@end
