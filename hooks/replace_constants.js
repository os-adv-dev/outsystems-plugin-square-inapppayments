var fs = require('fs'), path = require('path');
const semver = require('semver');

const getConfigParser = (context, configPath) => {
      let ConfigParser;

      if (semver.lt(context.opts.cordova.version, '5.4.0')) {
        ConfigParser = context.requireCordovaModule('cordova-lib/src/ConfigParser/ConfigParser');
      } else {
        ConfigParser = context.requireCordovaModule('cordova-common/src/ConfigParser/ConfigParser');
      }

      return new ConfigParser(configPath);
    };

module.exports = function(context) {

    const args = process.argv

    var merchant_identifier;
    for (const arg of args) {  
      if (arg.includes('MERCHANT_IDENTIFIER')){
        var stringArray = arg.split("=");
        merchant_identifier = stringArray.slice(-1).pop();
      }
    }

    var country_code;
    for (const arg of args) {  
      if (arg.includes('COUNTRY_CODE')){
        var stringArray = arg.split("=");
        country_code = stringArray.slice(-1).pop();
      }
    }

    var currency_code;
    for (const arg of args) {  
      if (arg.includes('CURRENCY_CODE')){
        var stringArray = arg.split("=");
        currency_code = stringArray.slice(-1).pop();
      }
    }

    var square_location_id;
    for (const arg of args) {  
      if (arg.includes('SQUARE_LOCATION_ID')){
        var stringArray = arg.split("=");
        square_location_id = stringArray.slice(-1).pop();
      }
    }

    var application_id;
    for (const arg of args) {  
      if (arg.includes('APPLICATION_ID')){
        var stringArray = arg.split("=");
        application_id = stringArray.slice(-1).pop();
      }
    }

    var charge_server_host;
    for (const arg of args) {  
      if (arg.includes('CHARGE_SERVER_HOST')){
        var stringArray = arg.split("=");
        charge_server_host = stringArray.slice(-1).pop();
      }
    }
    
    const projectRoot = context.opts.projectRoot;
    const platformPath = path.join(projectRoot, 'platforms', 'ios');
    const config = getConfigParser(context, path.join(projectRoot, 'config.xml'));

    let projectName = config.name();
    let projectPath = path.join(platformPath, projectName);

    var swiftFile = path.join(projectPath, 'Plugins/outsystems-plugin-square-inapppayments/Constants.swift');
    var AppDelegateFile = path.join(projectPath, 'Plugins/outsystems-plugin-square-inapppayments/AppDelegate+Square.m');
    
    if (fs.existsSync(swiftFile)) {
     
      fs.readFile(swiftFile, 'utf8', function (err,data) {
        
        if (err) {
          throw new Error('🚨 Unable to read Constants.swift: ' + err);
        }
        
        var result = data.replace(/REPLACE_ME1/g, merchant_identifier);
        result = result.replace(/REPLACE_ME2/g, country_code);
        result = result.replace(/REPLACE_ME3/g, currency_code);
        result = result.replace(/REPLACE_ME4/g, square_location_id);
        result = result.replace(/REPLACE_ME5/g, application_id);
        result = result.replace(/REPLACE_ME6/g, charge_server_host);
        
        fs.writeFile(swiftFile, result, 'utf8', function (err) {
        if (err) 
          {throw new Error('🚨 Unable to write into Constants.swift: ' + err);}
        else 
          {console.log("✅ Constants.swift edited successfuly");}
        });
      });
    } else {
        throw new Error("🚨 WARNING: Constants.swift was not found <<<");
    }

    if (fs.existsSync(AppDelegateFile)) {
     
      fs.readFile(AppDelegateFile, 'utf8', function (err,data) {
        
        if (err) {
          throw new Error('🚨 Unable to read AppDelegate+Square.m: ' + err);
        }
        
        var result = data.replace(/REPLACE_ME/g, application_id);
                
        fs.writeFile(AppDelegateFile, result, 'utf8', function (err) {
        if (err) 
          {throw new Error('🚨 Unable to write into AppDelegate+Square.m: ' + err);}
        else 
          {console.log("✅ AppDelegate+Square.m edited successfuly");}
        });
      });
    } else {
        throw new Error("🚨 WARNING: AppDelegate+Square.m was not found <<<");
    }
}

