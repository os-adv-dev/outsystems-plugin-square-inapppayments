var exec = require('cordova/exec');

exports.payWithCard = function (success, error) {
    exec(success, error, 'SquareInAppPayments', 'payWithCard');
};
