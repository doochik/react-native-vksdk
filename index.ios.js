'use strict';

var VkSdkLoginManager = require('react-native').NativeModules.VkSdkLoginManager;

module.exports = {

    /**
     * Starts authorization process to retrieve unlimited token.
     * If VKapp is available in system, it will opens and requests access from user.
     * Otherwise Mobile Safari will be opened for access request.
     * @returns {Promise}
     */
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
