# react-native-vk-sdk

A wrapper around the [iOS VK (VKontakte) SDK](https://github.com/VKCOM/vk-ios-sdk) for React Native apps.

## Setup

1. Install package: `npm install react-native-vksdk`
1. Setup your app for [VK iOS SDK](https://github.com/VKCOM/vk-ios-sdk)
2. Add `VkAppID` key to Info.plist <img src="https://raw.githubusercontent.com/doochik/react-native-vk-sdk/master/docs/plist.png" alt="preview" />
3. Add `RCTVkSdkLoginManager.h` and `RCTVkSdkLoginManager.m` to you Libraries. <img src="https://raw.githubusercontent.com/doochik/react-native-vk-sdk/master/docs/add.png" alt="preview" />

## Usage

```js
var Vk = require('react-native-vksdk');

// authorize and get token
Vk.authorize()
    .then((result) => {
        // your code here
    }, (error) => {
        // your code here
    });
    
// logout
Vk.logout();
    
```
