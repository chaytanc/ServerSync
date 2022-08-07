//
//  AvatarMLModel.m
//  ModelVale
//
//  Created by Chaytan Inman on 7/14/22.
//

#import "AvatarMLModel.h"
#import "CoreML/CoreML.h"
#import "UIViewController+PresentError.h"
@import FirebaseFirestore;
#import "ModelLabel.h"

NSNumber* const MAXHEALTH = @500;
@interface AvatarMLModel ()
@property (nonatomic, strong) NSMutableArray<NSString*>* userModelDocRefs;
@end

@implementation AvatarMLModel

- (instancetype) initWithModelName: (NSString*)modelName avatarName: (NSString*)avatarName uid: (NSString*)uid {
    self = [super init];
    if(self){
        self.modelName = modelName;
        self.avatarName = avatarName;
        self.health = MAXHEALTH;
        self.labeledData = [NSMutableArray new];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if(self){
        self.modelName = dict[@"modelName"];
        self.avatarName = dict[@"avatarName"];
        self.health = dict[@"health"];
        self.labeledData = dict[@"labeledData"];
    }
    return self;
}

//XXX todo only works with SqueezeNet rn
- (MLModel*) getMLModelFromModelName {
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"mlmodelc"];
    MLModel* model = [[UpdatableSqueezeNet alloc] initWithContentsOfURL:modelURL error:nil].model;
    return model;
}
    
- (NSURL*) loadModelURL: (NSString*) resource extension: (NSString*)extension {
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:resource withExtension:extension];
    return modelURL;
}

- (UpdatableSqueezeNet*) loadModel: (NSString*) resource extension: (NSString*)extension {
    NSURL* modelURL = [self loadModelURL:resource extension:extension];
    UpdatableSqueezeNet* model = [[UpdatableSqueezeNet alloc] initWithContentsOfURL:modelURL error:nil];
    return model;
}

- (UpdatableSqueezeNet*) loadModel: (NSURL*)url {
    UpdatableSqueezeNet* model = [[UpdatableSqueezeNet alloc] initWithContentsOfURL:url error:nil];
    return model;
}

//MARK: Firebase

// Checks if the model with the avatarName and owner already exists, if not, uploads the new model and updates user.models as well
- (void) uploadModelToUserWithViewController: (NSString*) uid db: (FIRFirestore*)db vc: (UIViewController*)vc completion:(void(^)(NSError *error))completion {

    FIRDocumentReference *docRef = [[db collectionWithPath:@"Model"] documentWithPath:self.avatarName];
    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if(error != nil) {
            [vc presentError:@"Failed to fetch models" message:error.localizedDescription error:error];
        }
        // If a model already exists under that avatarName, update local properties, then update the database model
        else if(snapshot.data != nil) {
            [self initWithDictionary:snapshot.data];
        }
        [self uploadNewModel:uid db:db vc:vc completion:completion];
    }];
}

- (void) updateUserModelDocRefs: (NSString*)uid db: (FIRFirestore*)db userModelDocRefs: (NSMutableArray*)userModelDocRefs vc: (UIViewController*)vc completion:(void(^)(NSError *error))completion {
    
    // Get the existing document, get its models, update local data to have remote + self.avatarName, finally update remote
    FIRDocumentReference* docRef = [[db collectionWithPath:@"users"] documentWithPath:uid];
    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        NSMutableArray* remoteModels = snapshot.data[@"models"];
        NSMutableArray* userModelDocRefs = (remoteModels) ? remoteModels : [NSMutableArray new];
        if(![userModelDocRefs containsObject:self.avatarName]) {
            [userModelDocRefs addObject:self.avatarName];
            self.userModelDocRefs = userModelDocRefs;
            [self addUserModelDocRefs:uid db:db userModelDocRefs:userModelDocRefs vc:vc completion:completion];
        }
    }];
}

- (void) addUserModelDocRefs: (NSString*)uid db: (FIRFirestore*)db userModelDocRefs: (NSMutableArray*)userModelDocRefs vc: (UIViewController*)vc completion:(void(^)(NSError *error))completion {
    // Reuploaded modified user.uid.models data
    [[[db collectionWithPath:@"users"] documentWithPath:uid]
        setData:@{ @"models": userModelDocRefs }
            merge:YES
            completion:^(NSError * _Nullable error) {
                if(error != nil){
                    [vc presentError:@"Failed to update users" message:error.localizedDescription error:error];
                }
                else {
                    NSLog(@"Added model in users.models");
                }
        completion(error);
    }];
}

- (void) uploadNewModel: (NSString*)uid db: (FIRFirestore*)db vc: (UIViewController*)vc completion:(void(^)(NSError *error))completion {
    [[[db collectionWithPath:@"Model"] documentWithPath:self.avatarName]
     setData:@{
        @"avatarName": self.avatarName,
        @"modelName" : self.modelName,
        @"health" : self.health,
         @"labeledData" : self.labeledData
    }
         merge:YES
         completion:^(NSError * _Nullable error) {
                if(error != nil){
                    [vc presentError:@"Failed to update Model" message:error.localizedDescription error:error];
                }
                else {
                    NSLog(@"Uploaded Model to Firestore");
                    [self.userModelDocRefs addObject:self.avatarName];
//                    [self addUserModelDocRefs:uid db:db userModelDocRefs:self.userModelDocRefs vc:vc];
                    [self updateUserModelDocRefs:uid db:db userModelDocRefs:self.userModelDocRefs vc:vc completion:completion];
                }
    }];
}

- (void)updatePropsLocallyWithDict:(NSDictionary *)dict vc: (UIViewController*)vc completion:(void(^)(void))completion{
    self.modelName = dict[@"modelName"];
    self.avatarName = dict[@"avatarName"];
    self.health = dict[@"health"];
    self.labeledData = dict[@"labeledData"];
}

+ (void) fetchAndCreateAvatarMLModel: (FIRFirestore*)db documentPath: (NSString*)documentPath completion:(void(^_Nullable)(AvatarMLModel*))completion {
    FIRDocumentReference *docRef = [[db collectionWithPath:@"Model"] documentWithPath:documentPath];
    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
       if (snapshot.exists) {
           NSLog(@"Model exists with data: %@", snapshot.data);
           AvatarMLModel* model = [[AvatarMLModel new] initWithDictionary: snapshot.data];
           completion(model);
       }
       else {
           NSLog(@"Model does not exist");
       }
     }];
}

- (void) updateModelLabeledDataWithDatabase: (FIRFirestore*)db vc: (UIViewController*)vc completion:(void(^)(NSError *error))completion {
    
    FIRDocumentReference *modelRef = [[db collectionWithPath:@"Model"] documentWithPath:self.avatarName];
    [modelRef updateData:@{
      @"labeledData": [FIRFieldValue fieldValueForArrayUnion:self.labeledData]
    } completion:^(NSError * _Nullable error) {
        completion(error);
    }];
}

// Update the label document found in Firestore with the given docID
- (void) updateLabeledData: (FIRFirestore*)db docID: (NSString*)docID vc: (UIViewController*)vc {
    [[[db collectionWithPath:@"Model"] documentWithPath:docID]
        setData:@{
        @"labeledData" : self.labeledData
        }
         merge:YES
         completion:^(NSError * _Nullable error) {
                if(error != nil){
                    [vc presentError:@"Failed to update Model labeledData" message:error.localizedDescription error:error];
                }
                else {
                    NSLog(@"Uploaded Model labeledData to Firestore");
                }
    }];
}

@end
