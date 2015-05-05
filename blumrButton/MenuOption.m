//
//  MenuOption.m
//  blumrButton
//
//  Created by Retina01 on 5/5/15.
//
//

#import "MenuOption.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation MenuOption

#pragma mark - Synthesizers

@synthesize menuOption = _menuOption;

#pragma mark - Overridden Setters

- (void)setMenuOption:(NSString *)menuOption {
    if (menuOption == nil) {
        //option cannot be nil
    } else if ([menuOption isEqualToString:@""]) {
        //option cannot be empty
    } else {
        _menuOption = menuOption;
        //TODO:
//        self.menuIcon.image = [UIImage imageNamed:@"add image here"];
//        self.menuLabel.text = self.menuOption;
        
        [self setImage:[UIImage imageNamed:@"add image here"] forState:UIControlStateNormal];
//        [self setTitle:self.menuOption forState:UIControlStateNormal];
        NSAttributedString *formattedString = [[NSAttributedString alloc] initWithString:self.menuOption attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8]}];
        [self setAttributedTitle:formattedString forState:UIControlStateNormal];
    }
}

#pragma mark - Allocation
+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    MenuOption *button = [super buttonWithType:buttonType];

    return button;
}

@end
