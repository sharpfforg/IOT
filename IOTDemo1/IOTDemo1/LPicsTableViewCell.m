//
//  LPicsTableViewCell.m
//  IOTDemo1
//
//  Created by linfeng on 14-10-7.
//  Copyright (c) 2014年 ___SHARPFF___. All rights reserved.
//

#import "LPicsTableViewCell.h"

@implementation LPicsTableViewCell

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
