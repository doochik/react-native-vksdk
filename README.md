# react-native-vk-sdk

A wrapper around the [iOS VK (VKontakte) SDK](https://github.com/VKCOM/vk-ios-sdk) for React Native apps.

## Setup

//Work in progress... Sorry//

1. Setup your app using VK [readme](https://github.com/VKCOM/vk-ios-sdk)
2. Add `VkAppID` key to Info.plist
3. Add `RCTVkSdkLoginManager.h` and `RCTVkSdkLoginManager.m` to you Libraries.

## Usage

```js
var Vk = require('react-native-vksdk');

Vk.authorize()
    .then((result) => {
        // your code here
    }, (error) => {
        // your code here
    });
    
```
