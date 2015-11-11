'use strict';

var React = require('react-native');
var {
    NativeModules
} = React;
var VkSdkLoginManager = NativeModules.VkSdkLoginManager;

module.exports = {

    authorize: function() {
        return new Promise(function(resolve, reject) {
            VkSdkLoginManager.authorize(function(error, result) {
                if (error) {
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    },

    /**
     * Forces logout using OAuth (with VKAuthorizeController). Removes all cookies for *.vk.com.
     * Has no effect for logout in VK app.
     */
    logout: function() {
        VkSdkLoginManager.logout();
    }
};
