#import "RCTBridgeModule.h"
#import <VKSdkFramework/VKSdkFramework.h>

@interface RCTVkSdkLoginManager : NSObject <RCTBridgeModule, VKSdkDelegate, VKSdkUIDelegate>
@end
