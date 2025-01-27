//
//  UIViewController+PresentError.m
//  Instagram
//
//  Created by Chaytan Inman on 6/24/22.
//

#import "UIViewController+PresentError.h"

@implementation UIViewController (PresentError)
- (void) presentError: (NSString*)title message:(NSString*)message error:(NSError* _Nullable)error {
    NSLog(@"Error: %@", error);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                   message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) presentError: (NSString*)title message:(NSString*)message error:(NSError* _Nullable)error completion: (void(^)(UIAlertAction * action))completion {
    NSLog(@"Error: %@", error);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                   message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
    {
        completion(action);
    }];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
