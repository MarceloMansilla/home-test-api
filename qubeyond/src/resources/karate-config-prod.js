/**
 * Production overrides - merged on top of karate-config.js.
 *
 * URL, timeouts and flags live in config/environments/config-prod.yml.
 * Only what needs logic belongs here: secrets are never committed, they are
 * read from the shell / CI environment.
 */
function fn() {

  var apiKey = java.lang.System.getenv('PROD_API_KEY');
  var clientSecret = java.lang.System.getenv('PROD_CLIENT_SECRET');

  // Fail fast: a missing credential should not surface as a 401 in every scenario
  if (!apiKey) {
    throw new Error('PROD_API_KEY environment variable is required');
  }
  if (!clientSecret) {
    throw new Error('PROD_CLIENT_SECRET environment variable is required');
  }

  return {
    credentials: {
      apiKey: apiKey,
      clientSecret: clientSecret
    }
  };
}
