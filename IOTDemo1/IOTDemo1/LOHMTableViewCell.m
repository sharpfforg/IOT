//
//  LOHMTableViewCell.m
//  IOTDemo1
//
//  Created by linfeng on 14-10-10.
//  Copyright (c) 2014年 ___SHARPFF___. All rights reserved.
//

#import "LOHMTableViewCell.h"

@implementation LOHMTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
