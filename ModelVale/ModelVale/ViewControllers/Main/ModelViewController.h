//
//  ModelViewController.h
//  ModelVale
//
//  Created by Chaytan Inman on 7/4/22.
//

#import <UIKit/UIKit.h>
#import "FirebaseViewController.h"
@class AvatarMLModel;

NS_ASSUME_NONNULL_BEGIN

@interface ModelViewController : FirebaseViewController
@property (nonatomic, assign) CGPoint seed;
@property (nonatomic, strong) NSMutableArray<AvatarMLModel*>* models;
- (void) earnXP:(int)XPClustersEarned;
- (void) fetchAndSetVCModels: (void(^_Nullable)(void))completion;
@end

NS_ASSUME_NONNULL_END
