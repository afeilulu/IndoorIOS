//
//  CADSearchController.m
//  IndoorIOS
//
//  Created by Chen Gefei on 16/6/19.
//  Copyright © 2016年 chinaairdome. All rights reserved.
//

#import "CADSearchController.h"
#import "CADSearchBar.h"

@interface CADSearchController (){
UISearchBar* _searchBar;
}
@end

@implementation CADSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UISearchBar *)searchBar{
    if (_searchBar == nil) {
        _searchBar = [[CADSearchBar alloc] initWithFrame:CGRectZero];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchBar.text length] > 0) {
        self.active = true;
    } else {
        self.active = false;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
