//
//  ViewController.m
//  blumrButton
//
//  Created by Retina01 on 5/5/15.
//
//

#import <CoreGraphics/CoreGraphics.h>

#import "ViewController.h"
#import "MenuOption.h"

@interface ViewController () <UIScrollViewDelegate>

typedef NS_ENUM(NSInteger, menuViewType) {
    menuViewTypeContacts,
    menuViewTypeMessages
};

typedef NS_ENUM(NSInteger, menuButtonPosition) {
    upperleft,
    middleleft,
    lowerleft,
    upperright,
    middleright,
    lowerright
};
#pragma mark - Private Properties

//Outlets
@property (nonatomic, strong)  UIView *menuButton;
@property (nonatomic, strong)  UIScrollView *viewContainer;

@property (nonatomic, strong) UIView *menuViewBackground;
@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, assign) BOOL isTouchingMenuButton;
@property (nonatomic, assign) BOOL isDraggingMenuButton;

//Menu Choices
@property (nonatomic, strong) NSArray *contactsMenuChoices;
@property (nonatomic, strong) NSArray *messagesMenuChoices;

@end

@implementation ViewController

#pragma mark - Private Synthesizers

@synthesize menuView = _menuView;
@synthesize menuViewBackground = _menuViewBackground;
@synthesize menuButton = _menuButton;
@synthesize viewContainer = _viewContainer;

@synthesize isTouchingMenuButton = _isTouchingMenuButton;
@synthesize isDraggingMenuButton = _isDraggingMenuButton;

@synthesize contactsMenuChoices = _contactsMenuChoices;
@synthesize messagesMenuChoices = _messagesMenuChoices;

#pragma mark - Overridden Getters
- (UIScrollView *)viewContainer {
    if (_viewContainer == nil) {
        @autoreleasepool {
            _viewContainer = [[UIScrollView alloc] initWithFrame:self.view.frame];
            _viewContainer.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * 2, CGRectGetHeight(self.view.frame));
            _viewContainer.pagingEnabled = TRUE;
            _viewContainer.scrollEnabled = FALSE;
            _viewContainer.delegate = self;
            
            //hardcoded
            CGFloat width = CGRectGetWidth(_viewContainer.frame);
            CGFloat height = CGRectGetHeight(_viewContainer.frame);
            
            for (NSInteger counter = 0; counter < 2; counter ++) {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake((width * counter) + 5, 5, width - 10, height - 10)];
                if (counter == 0) {
                    view.backgroundColor = [UIColor lightGrayColor];
                } else {
                    view.backgroundColor = [UIColor cyanColor];
                }
                
                [_viewContainer addSubview:view];
            }
        }
    }
    
    return _viewContainer;
}

- (UIView *)menuButton {
    if (_menuButton == nil) {
        _menuButton = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 50, CGRectGetHeight(self.view.frame) - 50, 50, 50)];
        _menuButton.backgroundColor = [UIColor blueColor];
        _menuButton.layer.cornerRadius = 25;

    }
    
    return _menuButton;
}

- (UIView *)menuView {
    if (_menuView == nil) {
        _menuView = [[UIView alloc] initWithFrame:self.menuButton.frame];
        _menuView.backgroundColor = [UIColor greenColor];
    }
    
    return _menuView;
}

- (UIView *)menuViewBackground {
    if (_menuViewBackground == nil) {
        _menuViewBackground = [[UIView alloc] initWithFrame:self.view.frame];
        _menuViewBackground.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.8];
    }
    return _menuViewBackground;
}

- (NSArray *)contactsMenuChoices {
    if (_contactsMenuChoices == nil) {
        _contactsMenuChoices = @[@"contacts", @"invites", @"chat"];
    }
    return _contactsMenuChoices;
}

- (NSArray *)messagesMenuChoices {
    if (_messagesMenuChoices == nil) {
        _messagesMenuChoices = @[@"Trending" /*, @"Blumit", @"Boohit", @"Newest", @"Post a Topic", @"My Bookmarks"*/ , @"Posts", @"Comments"];
    }
    
    return _messagesMenuChoices;
}


#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addSubview:self.viewContainer];
    [self.view insertSubview:self.menuButton atIndex:self.view.subviews.count];
    
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    @autoreleasepool {
        
        if (self.isTouchingMenuButton == TRUE) {
            self.isTouchingMenuButton = FALSE;
            [self closeMenu];
        } else {
            self.isTouchingMenuButton = [self touchIsForView:self.menuButton forTouch:[touches anyObject]];
        }
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    @autoreleasepool {
        if (self.isTouchingMenuButton == FALSE) {
            //the user is dragging a different item and so we do nothing
            return;
        } else if (self.isDraggingMenuButton == FALSE) {
            if ([self mainViewContainsView:self.menuView]) {
                [self closeMenu];
                return;
            }
        }
        
        self.isDraggingMenuButton = TRUE;
        
        UITouch *aTouch = [touches anyObject];
        CGPoint currentTouchPosition = [aTouch locationInView:self.view];
        self.menuButton.frame = CGRectMake(currentTouchPosition.x, currentTouchPosition.y, CGRectGetWidth(self.menuButton.frame), CGRectGetHeight(self.menuButton.frame));
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.isTouchingMenuButton == FALSE) {
        if ([self mainViewContainsView:self.menuView] == TRUE) {
            [self closeMenu];
        }
    } else if (self.isDraggingMenuButton == TRUE) {
        [self moveViewToScreenBounds:self.menuButton];
    } else if ([self mainViewContainsView:self.menuView] == TRUE){
        [self closeMenu];
    } else {
        [self didPressButton:self.menuButton];
    }
    
    //make sure the touching bool is false for the button
    self.isDraggingMenuButton = FALSE;
    self.isTouchingMenuButton = FALSE;
}



#pragma mark - Button Events

- (void)didPressButton:(id)button {
    if (button == self.menuButton) {
//        [self openMenuForViewType:menuViewTypeContacts];
        if (self.viewContainer.contentOffset.x == 0) {
            [self openMenuForViewType:menuViewTypeMessages];
        } else {
            [self openMenuForViewType:menuViewTypeContacts];
        }
    } else if ([button isKindOfClass:[MenuOption class]]) {
        //TODO: decide on what todo here coz this scrolling is hardcoded
        [self closeMenu];
        if (self.viewContainer.contentOffset.x == 0) {
            [self moveViewContainerToViewType:menuViewTypeMessages];
        } else {
            [self moveViewContainerToViewType:menuViewTypeContacts];
        }
    }
}

#pragma mark - Scrollview Handlers

- (void)moveViewContainerToViewType:(menuViewType)viewType {
    CGFloat containerWidth = CGRectGetWidth(self.viewContainer.frame);
    
    if (viewType == menuViewTypeMessages) {
        [self.viewContainer setContentOffset:CGPointMake(containerWidth, 0) animated:TRUE];
    } else if (viewType == menuViewTypeContacts) {
        [self.viewContainer setContentOffset:CGPointMake(0, 0) animated:TRUE];
    } else {
        //Unknown view type
    }
}

#pragma mark - Menu Handlers

- (void)openMenuForViewType:(menuViewType)viewType {
    if (viewType == menuViewTypeContacts) {
        //provide a menu for contacts
        [self createMenuUsingChoices:self.contactsMenuChoices];
        
    } else if (viewType == menuViewTypeMessages) {
        //provide a menu for messages
        [self createMenuUsingChoices:self.messagesMenuChoices];
    } else {
        //Unknown ViewType
    }
}

- (void)createMenuUsingChoices:(NSArray *)choices {
    @autoreleasepool {
        if (choices == nil) {
            //choices cannot be nil
            return;
        } else if (choices.count == 0) {
            //choices cannot be empty
            return;
        }

        CGFloat menuButtonHeight = CGRectGetHeight(self.menuButton.frame);
        
        CGFloat menuX = CGRectGetMinX(self.menuButton.frame) - 100;
        CGFloat menuY = CGRectGetMinY(self.menuButton.frame) - 100;
        CGFloat menuHeight = CGRectGetWidth(self.menuButton.frame) + 200;
        CGFloat menuWidth = CGRectGetHeight(self.menuButton.frame) + 200;
        
        CGFloat optionHeight = 45;
        CGFloat optionWidth = 45;
        __block CGFloat optionX = 0;
        __block CGFloat optionY = 0;

        menuButtonPosition buttonPosition = [self getMenuButtonPositionForView:self.menuButton];
        
        if (buttonPosition == upperleft) {
            
            optionY = (menuHeight / 2) - (menuButtonHeight / 2);
            optionX = menuWidth - (optionWidth + optionWidth / 2);
            
            [choices enumerateObjectsUsingBlock:^(NSString *menuOption, NSUInteger idx, BOOL *stop) {
                MenuOption *optionButton = [self createMenuOptionForOption:menuOption withFrame:CGRectMake(optionX, optionY, optionWidth, optionHeight)];
                optionY += optionHeight + 2;
                optionX -= optionWidth / (choices.count - (idx+1));
                
                [self.menuView addSubview:optionButton];
                
               
            }];
            
        } else if (buttonPosition == middleleft) {
            
            optionY = menuHeight / 2 - (menuButtonHeight / 2);
            optionX = menuWidth - (optionWidth + optionWidth / 2);
            
            NSInteger middleIndex = (choices.count - 1) / 2;
            
            //upper insert
            for (NSInteger counter = middleIndex; counter >= 0; counter--) {
                NSString *menuOption = choices[counter];
                
                MenuOption *optionButton = [self createMenuOptionForOption:menuOption withFrame:CGRectMake(optionX, optionY, optionWidth, optionHeight)];
                
                optionY -= optionHeight + 2;
                optionX -= optionWidth / (counter+1);
                
                [self.menuView addSubview:optionButton];
            }
            
            optionY = menuHeight / 2 + (menuButtonHeight / 2);
            optionX = menuWidth - (optionWidth + optionWidth / 2);
            optionX -= optionWidth / 2;
            
            //lower insert
            for (NSInteger counter = middleIndex+1; counter <= choices.count -1; counter++) {
                NSString *menuOption = choices[counter];
                MenuOption *optionButton = [self createMenuOptionForOption:menuOption withFrame:CGRectMake(optionX, optionY, optionWidth, optionHeight)];
                
                optionY -= optionHeight + 2;
                optionX -= optionWidth / counter;
                
                [self.menuView addSubview:optionButton];
            }
            
        } else if (buttonPosition == lowerleft) {
            
            optionY = (menuHeight / 2) - (menuButtonHeight / 2);
            optionX = menuWidth - (optionWidth + optionWidth / 2);
            
            [choices enumerateObjectsUsingBlock:^(NSString *menuOption, NSUInteger idx, BOOL *stop) {
                MenuOption *optionButton = [self createMenuOptionForOption:menuOption withFrame:CGRectMake(optionX, optionY, optionWidth, optionHeight)];
                optionY -= optionHeight + 2;
                optionX -= optionWidth / (choices.count - (idx+1));
                
                [self.menuView addSubview:optionButton];
                
                
            }];
            
        } else if (buttonPosition == upperright) {
            
            optionY = (menuHeight / 2) - (menuButtonHeight / 2);
            optionX = optionWidth / 2;
            
            [choices enumerateObjectsUsingBlock:^(NSString *menuOption, NSUInteger idx, BOOL *stop) {
                MenuOption *optionButton = [self createMenuOptionForOption:menuOption withFrame:CGRectMake(optionX, optionY, optionWidth, optionHeight)];
                optionY += optionHeight + 2;
                optionX += optionWidth / (choices.count - (idx+1));
                
                [self.menuView addSubview:optionButton];
                
                
            }];
            
        } else if (buttonPosition == middleright) {
            
            optionY = menuHeight / 2 - (menuButtonHeight / 2);
            optionX = optionWidth / 2;
            
            NSInteger middleIndex = (choices.count - 1) / 2;
            
            //upper insert
            for (NSInteger counter = middleIndex; counter >= 0; counter--) {
                NSString *menuOption = choices[counter];
                
                MenuOption *optionButton = [self createMenuOptionForOption:menuOption withFrame:CGRectMake(optionX, optionY, optionWidth, optionHeight)];
                
                optionY -= optionHeight + 2;
                optionX += optionWidth / (counter+1);
                
                [self.menuView addSubview:optionButton];
            }
            
            optionY = menuHeight / 2 + (menuButtonHeight / 2);
            optionX = optionWidth / 2;
            optionX += optionWidth / 2;
            
            //lower insert
            for (NSInteger counter = middleIndex+1; counter <= choices.count -1; counter++) {
                NSString *menuOption = choices[counter];
                MenuOption *optionButton = [self createMenuOptionForOption:menuOption withFrame:CGRectMake(optionX, optionY, optionWidth, optionHeight)];
                
                optionY -= optionHeight + 2;
                optionX += optionWidth / counter;
                
                [self.menuView addSubview:optionButton];
            }
            
        } else if (buttonPosition == lowerright) {
            optionY = (menuHeight / 2) - (menuButtonHeight / 2);
            optionX = optionWidth / 2;
            
            [choices enumerateObjectsUsingBlock:^(NSString *menuOption, NSUInteger idx, BOOL *stop) {
                MenuOption *optionButton = [self createMenuOptionForOption:menuOption withFrame:CGRectMake(optionX, optionY, optionWidth, optionHeight)];
                optionY -= optionHeight + 2;
                optionX += optionWidth / (choices.count - (idx+1));
                
                [self.menuView addSubview:optionButton];
                
                
            }];
        } else {
            //unknown position
        }

        [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionLayoutSubviews) animations:^{
            self.menuView.frame = CGRectMake(menuX, menuY, menuWidth, menuHeight);
            self.menuView.layer.cornerRadius = menuHeight / 2;
            
        } completion:^(BOOL finished) {
            
        }];
        
        //insert the menuview at the 2nd to the last object meaning only the menubutton will be above it
        [self.view insertSubview:self.menuViewBackground belowSubview:self.menuButton];
        [self.view insertSubview:self.menuView atIndex:self.view.subviews.count - 1];
    }
}

- (MenuOption *)createMenuOptionForOption:(NSString *)option withFrame:(CGRect)frame {
    MenuOption *optionButton = [MenuOption buttonWithType:UIButtonTypeCustom];
    optionButton.menuOption = option;
    
    optionButton.frame = frame;
    optionButton.backgroundColor = [UIColor purpleColor];
    
    [optionButton addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return optionButton;
}

- (void)closeMenu {
    [self.menuView removeFromSuperview];
    self.menuView = nil;
    
    [self.menuViewBackground removeFromSuperview];
    self.menuViewBackground = nil;
}

- (void)moveViewToScreenBounds:(UIView *)view {
    
    CGFloat viewX = CGRectGetMinX(view.frame);
    CGFloat parentMidX = CGRectGetWidth(self.view.frame) / 2;
    
    //this is to make sure that the view is always in front
    [self.view bringSubviewToFront:view];
    
    if (viewX > parentMidX) {
        [UIView animateWithDuration:0.2 animations:^{
            CGFloat parentViewWidth = CGRectGetWidth(self.view.frame);
            CGFloat viewWidth = CGRectGetWidth(view.frame);
            view.frame = CGRectMake(parentViewWidth - viewWidth, CGRectGetMinY(view.frame), viewWidth, CGRectGetHeight(view.frame));
        }];
        
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            CGFloat viewWidth = CGRectGetWidth(view.frame);
            view.frame = CGRectMake(0, CGRectGetMinY(view.frame), viewWidth, CGRectGetHeight(view.frame));
        }];
        
    }
    
}

#pragma mark - Touch Handlers

- (BOOL)touchIsForView:(UIView *)view forTouch:(UITouch *)aTouch {
    @autoreleasepool {
        //this is to make sure that the view is always in front
        [self.view bringSubviewToFront:view];
        
        CGPoint currentTouchPosition = [aTouch locationInView:self.view];
        CGRect currentTouchRect = CGRectMake(currentTouchPosition.x, currentTouchPosition.y, 1,1);
        CGRect viewRect = view.frame;
        if (CGRectIntersectsRect(currentTouchRect, viewRect)) {
            return TRUE;
        } else {
            return FALSE;
        }
    }
}

- (BOOL)mainViewContainsView:(id)view {
    NSPredicate *filterMenuViewFromSelf = [NSPredicate predicateWithFormat:@"SELF == %@", self.menuView];
    NSArray *filteredViewsFromSelf = [self.view.subviews filteredArrayUsingPredicate:filterMenuViewFromSelf];
    if (filteredViewsFromSelf.count > 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (menuButtonPosition)getMenuButtonPositionForView:(UIView *)view {
    menuButtonPosition viewPosition = upperleft;
    CGFloat viewX = CGRectGetMinX(view.frame);
    CGFloat viewY = CGRectGetMinY(view.frame);
    CGFloat mainViewHeight = CGRectGetHeight(self.view.frame);
    if (viewX == 0) {
        //left side
        if (viewY <= 80) {
            viewPosition = upperleft;
        } else if (viewY >= mainViewHeight - 80) {
            viewPosition = lowerleft;
        } else {
            viewPosition = middleleft;
        }
    } else {
        //right side
        if (viewY <= 80) {
            viewPosition = upperright;
        } else if (viewY >= mainViewHeight - 80) {
            viewPosition = lowerright;
        } else {
            viewPosition = middleright;
        }
    }
    
    return viewPosition;
}

@end
