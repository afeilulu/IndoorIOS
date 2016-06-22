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
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

- (IBAction)moreButtonAction:(id)sender;
-(void) setHeaderWithTitle:(NSString*)title tag:(NSInteger)tag;
@end
