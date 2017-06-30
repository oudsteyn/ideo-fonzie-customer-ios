//
//  HistoryTableViewCell.h
//  Fonzie
//
//  Created by John Oudsteyn on 6/29/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *createdAt;
@property (weak, nonatomic) IBOutlet UILabel *impact;
@property (weak, nonatomic) IBOutlet UILabel *odometer;
@property (weak, nonatomic) IBOutlet UILabel *note;

@end
