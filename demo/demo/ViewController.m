//
//  ViewController.m
//  IRPlayerUIShell
//
//  Created by irons on 2019/9/12.
//  Copyright © 2019年 irons. All rights reserved.
//

#import "ViewController.h"
#import "IRPlayerViewController.h"
#import "IRPlayerUIShellViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"Q";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    IRPlayerViewController *player = [IRPlayerViewController new];
//    player.displayMode = IRPlayerDisplayerQuadMode;
//    self.navigationController.navigationBar.hidden = NO;
    IRPlayerUIShellViewController *player = [IRPlayerUIShellViewController new];
    [self.navigationController pushViewController:player animated:YES];
}

- (BOOL)shouldAutorotate {
    return false;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
