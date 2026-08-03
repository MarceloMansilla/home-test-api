/**
 * Base configuration - runs for every environment.
 *
 * The environment is selected from the console with:
 *   mvn test -Dkarate.env=qa
 *
 * Karate then loads, in this order:
 *   1. this file
 *   2. config/environments/config-<env>.yml   (data: host, port, flags)
 *   3. config/api/config-<env>.path.yml       (data: endpoint paths)
 *   4. karate-config-<env>.js                 (logic/secrets, merged over the result)
 */
function fn() {

  // 'local' keeps a bare `mvn test` working instead of blowing up on a null env
  var env = karate.env || 'local';
  env = env.toLowerCase();

  var envConfig = karate.read('classpath:config/environments/config-' + env + '.yml');
  var apiPath = karate.read('classpath:config/api/config-' + env + '.path.yml');

  var url = envConfig.url;
  var baseUrl = url.protocol + '://' + url.host + (url.port ? ':' + url.port : '');

  //karate.log('karate.env =', env, '| baseUrl =', baseUrl);

  var config = {
    env: env,
    baseUrl: baseUrl,
    api: apiPath,
    // ids and thresholds the scenarios assert against - per environment, so a
    // feature never has to be edited to run somewhere else
    testData: envConfig.testData,
    debugMode: envConfig.config.debug,
    mockExternalServices: envConfig.config.mockExternalServices,
    // whether this environment may be written to. Absent means false: a new
    // environment has to opt in, it cannot be exposed to writes by omission
    allowWrites: envConfig.config.allowWrites === true,
    utils: karate.call('classpath:utils/functions/karateUtils.js'),
    functions: karate.call('classpath:utils/functions/DinamicsCalls.js'),
  };

  karate.configure('ssl', envConfig.config.ssl);
  karate.configure('connectTimeout', envConfig.config.connectTimeout);
  karate.configure('readTimeout', envConfig.config.readTimeout);

  // Verbose capture in reports + console only where it is useful.
  // The logback level has to be raised too: logback-test.xml deliberately
  // defaults com.intuit to INFO so that no environment leaks request and
  // response bodies into target/karate.log by omission. Driving it from the
  // same flag keeps config.debug the one switch - otherwise 'debug: false'
  // would silence the report while the log file kept recording everything.
  // An explicit -Dkarate.log.level is a deliberate per-run decision and wins;
  // logback already applied it, so leave it alone. Precedence is therefore:
  // system property > the environment's config.debug > INFO.
  if (!java.lang.System.getProperty('karate.log.level')) {
    var logLevel = config.debugMode ? 'DEBUG' : 'INFO';
    Java.type('org.slf4j.LoggerFactory')
      .getILoggerFactory()
      .getLogger('com.intuit')
      .setLevel(Java.type('ch.qos.logback.classic.Level').toLevel(logLevel));
  }

  if (config.debugMode) {
    karate.configure('report', { showLog: true, showAllSteps: true });
    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);
  }

  return config;
}
