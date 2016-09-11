#import "RCTVkSdkLoginManager.h"
#import "VKSdk/VKSdk.h"
#import <RCTConvert.h>
#import <RCTUtils.h>

#ifdef DEBUG
#define VKSDKLog(...) NSLog(@"[VKSDK] %s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define VKSDKLog(...) do { } while (0)
#endif

@implementation RCTVkSdkLoginManager
{
  VKSdk *_sdkInstance;
  RCTResponseSenderBlock callback;
}

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (instancetype)init
{
  if ((self = [super init])) {
    NSString *VkAppID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"VkAppID"];
    VKSDKLog(@"RCTVkSdkLoginManager starts with ID %@", VkAppID);

    _sdkInstance = [VKSdk initializeWithAppId:VkAppID];
    [_sdkInstance registerDelegate:self];
    [_sdkInstance setUiDelegate:self];
    
    NSArray *SCOPE = @[VK_PER_FRIENDS, VK_PER_EMAIL];
    [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
      if (state == VKAuthorizationAuthorized) {
        VKSDKLog(@"wakeUpSession", state);
        // Authorized and ready to go
      } else if (error) {
        VKSDKLog(@"wakeUpSession", error);
        // Some error happend, but you may try later
      }
    }];
  }
  return self;
}

#pragma mark RN Export

RCT_EXPORT_METHOD(authorize:(RCTResponseSenderBlock)jsCallback)
{
  VKSDKLog(@"RCTVkSdkLoginManager#authorize");
  self->callback = jsCallback;
  [self _authorize];
};

RCT_EXPORT_METHOD(logout)
{
  VKSDKLog(@"RCTVkSdkLoginManager#logout");
  [VKSdk forceLogout];
};

RCT_EXPORT_METHOD(openShareDialog: (NSDictionary *) data resolver: (RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject)
{
  UIWindow *keyWindow = RCTSharedApplication().keyWindow;
  UIViewController *rootViewController = keyWindow.rootViewController;
  
  VKShareDialogController *shareDialog = [VKShareDialogController new]; //1
  
  shareDialog.text = [RCTConvert NSString:data[@"text"]];
  shareDialog.shareLink = [[VKShareLink alloc] initWithTitle:[RCTConvert NSString:data[@"linkText"]]
                                                        link:[NSURL URLWithString:[RCTConvert NSString:data[@"linkUrl"]]]];
  //shareDialog.dismissAutomatically = YES;

  [shareDialog setCompletionHandler:^(VKShareDialogController *dialog, VKShareDialogControllerResult result) {
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
    if (result == VKShareDialogControllerResultDone) {
      VKSDKLog(@"onVkShareComplete");
      resolve(dialog.postId);
    } else if (result == VKShareDialogControllerResultCancelled) {
      VKSDKLog(@"onVkShareCancel");
      reject(RCTErrorUnspecified, nil, RCTErrorWithMessage(@"canceled"));
    }
  }];
  
  [rootViewController presentViewController:shareDialog animated:YES completion:nil];
}

#pragma mark VKSdkDelegate

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
  VKSDKLog(@"vkSdkAccessAuthorizationFinishedWithResult %@", result);
  if (result.error) {
    NSDictionary *jsError = [self _NSError2JS:result.error];
    self->callback(@[jsError, [NSNull null]]);

  } else if (result.token) {
    NSDictionary *loginData = [self buildResponseData];
    self->callback(@[[NSNull null], loginData]);

  }
}

- (void)vkSdkUserAuthorizationFailed:(VKError *)error {
  VKSDKLog(@"vkSdkUserAuthorizationFailed %@", error);
  self->callback(@[error, [NSNull null]]);
}

#pragma mark VKSdkUIDelegate

-(void) vkSdkNeedCaptchaEnter:(VKError*) captchaError
{
  VKSDKLog(@"vkSdkNeedCaptchaEnter %@", captchaError);
  VKCaptchaViewController * vc = [VKCaptchaViewController captchaControllerWithError:captchaError];

  UIWindow *keyWindow = RCTSharedApplication().keyWindow;
  UIViewController *rootViewController = keyWindow.rootViewController;

  [vc presentIn:rootViewController];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
  VKSDKLog(@"vkSdkShouldPresentViewController");
  UIWindow *keyWindow = RCTSharedApplication().keyWindow;
  UIViewController *rootViewController = keyWindow.rootViewController;

  [rootViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - helpers

- (void)_authorize
{
  NSArray *SCOPE = @[VK_PER_FRIENDS, VK_PER_EMAIL];
  [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
    if (state == VKAuthorizationAuthorized) {
      // VKAuthorizationAuthorized - means a previous session is okay, and you can continue working with user data.
      VKSDKLog(@"VKSdk wakeUpSession result VKAuthorizationAuthorized");
      NSDictionary *loginData = [self buildResponseData];
      self->callback(@[[NSNull null], loginData]);

    } else if (state == VKAuthorizationInitialized) {
      // VKAuthorizationInitialized – means the SDK is ready to work, and you can authorize user with `+authorize:` method. Probably, an old session has expired, and we wiped it out. *This is not an error.*
      
      VKSDKLog(@"VKSdk wakeUpSession result VKAuthorizationInitialized");
      [VKSdk authorize:SCOPE];

    } else if (state == VKAuthorizationError) {
      // VKAuthorizationError - means some error happened when we tried to check the authorization. Probably, the internet connection has a bad quality. You have to try again later.
      
      VKSDKLog(@"VKSdk wakeUpSession result VKAuthorizationError");
      self->callback(@[@"VKAuthorizationError", [NSNull null]]);

    } else if (error) {
      VKSDKLog(@"VKSdk wakeUpSession error %@", error);
      NSDictionary *jsError = [self _NSError2JS:error];
      self->callback(@[jsError, [NSNull null]]);
    }
  }];
}

- (NSDictionary *)buildCredentials {
  NSDictionary *credentials = nil;
  VKAccessToken *token = [VKSdk accessToken];
  
  if (token) {
    credentials = @{
                    @"token" : token.accessToken,
                    @"userId" : token.userId,
                    @"permissions" : token.permissions
                    };
  }
  
  return credentials;
}

- (NSDictionary *)buildResponseData {
  NSDictionary *responseData = @{
                              @"credentials": [self buildCredentials]
                              };
  
  return responseData;
}

- (NSDictionary *)_NSError2JS:(NSError *)error {
  NSDictionary *jsError = @{
                            @"code" : [NSNumber numberWithLong:error.code],
                            @"domain" : error.domain,
                            @"description" : error.localizedDescription
                            };
  
  return jsError;
}


@end
