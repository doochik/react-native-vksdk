#import "RCTBridgeModule.h"
#import "VKSdk/VKSdk.h"

@interface RCTVkSdkLoginManager : NSObject <RCTBridgeModule, VKSdkDelegate, VKSdkUIDelegate>
@end
