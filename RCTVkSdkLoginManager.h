// #import "RCTBridgeModule.h"

//@interface RCTVkSdkLoginManager : NSObject <RCTBridgeModule>
//@end


#import "VKSdk/VKSdk.h"
#import "RCTViewManager.h"

@interface RCTVkSdkLoginManager : RCTViewManager <VKSdkDelegate, VKSdkUIDelegate>
@end
