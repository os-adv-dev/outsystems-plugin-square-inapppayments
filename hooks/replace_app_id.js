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

    var application_id;
    for (const arg of args) {  
      if (arg.includes('APPLICATION_ID')){
        var stringArray = arg.split("=");
        application_id = stringArray.slice(-1).pop();
      }
    }    

    const projectRoot = context.opts.projectRoot;
    const platformPath = path.join(projectRoot, 'platforms', 'ios');
    const config = getConfigParser(context, path.join(projectRoot, 'config.xml'));

    let projectName = config.name();
    let projectPath = path.join(platformPath, projectName);

    var AppDelegateFile = path.join(projectPath, 'Plugins/outsystems-plugin-square-inapppayments/AppDelegate+Square.m');
    
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

