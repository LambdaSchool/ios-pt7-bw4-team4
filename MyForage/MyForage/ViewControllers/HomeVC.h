//
//  HomeVC.h
//  MyForage
//
//  Created by Cora Jacobson on 1/5/21.
//

#import <UIKit/UIKit.h>

@class MainCoordinator;

NS_ASSUME_NONNULL_BEGIN

@interface HomeVC : UIViewController

@property (weak, nonatomic) MainCoordinator *coordinator;

- (instancetype)initWithCoordinator:(MainCoordinator *)theCoordinator;

@end

NS_ASSUME_NONNULL_END
