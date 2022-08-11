//
//  User.m
//  ModelVale
//
//  Created by Chaytan Inman on 7/27/22.
//

#import "User.h"
@import FirebaseFirestore;
@import FirebaseStorage;
#import "UIViewController+PresentError.h"

@implementation User

- (instancetype) initUser: (NSString*)uid {
    self = [super init];
    if(self) {
        self.uid = uid;
        self.userModelDocRefs = [NSMutableArray new];
    }
    return self;
}

- (void) updateUserModelDocRefs: (FIRFirestore*)db vc: (UIViewController*)vc completion:(void(^)(NSError *error))completion {
    
    // Get the existing document, get its models, update local data to have remote + self.avatarName, finally update remote
    
    FIRDocumentReference* docRef = [[db collectionWithPath:@"users"] documentWithPath:self.uid];
    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        // this should never be nil, want to add the user FIRST then be sure that it exists and always merge
        if(snapshot.data == nil) {
            [self addNewUser:db vc:vc completion:completion];
        }
        else {
            [self mergeUserModelDocRefsData:db vc:vc completion:completion];
        }
    }];
}

- (void) mergeUserModelDocRefsData: (FIRFirestore*)db vc: (UIViewController*)vc completion:(void(^)(NSError *error))completion {
    // Upload or create modified user.uid.models data
    [[[db collectionWithPath:@"users"] documentWithPath:self.uid] updateData:@{
        @"models" : self.userModelDocRefs
    } completion:^(NSError * _Nullable error) {
        if(error != nil){
            [vc presentError:@"Failed to update users" message:error.localizedDescription error:error];
        }
        else {
            NSLog(@"Updated model in users.models");
        }
        completion(error);
    }];
}

- (void) addNewUser: (FIRFirestore*)db vc: (UIViewController*)vc completion:(void(^)(NSError *error))completion {
    // Upload or create modified user.uid.models data
    [[[db collectionWithPath:@"users"] documentWithPath:self.uid] setData:@{
        @"models" : self.userModelDocRefs
    } completion:^(NSError * _Nullable error) {
        if(error != nil){
            [vc presentError:@"Failed to update users" message:error.localizedDescription error:error];
        }
        else {
            NSLog(@"Added new user and added model in users.models");
        }
        completion(error);
    }];
}

@end
