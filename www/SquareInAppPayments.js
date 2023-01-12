var exec = require('cordova/exec');

exports.payWithCard = function (success, error, button_caption, tint_hex_color, message_hex_color, error_hex_color) {
    exec(success, error, 'SquareInAppPayments', 'payWithCard',button_caption, tint_hex_color, message_hex_color, error_hex_color);
};
