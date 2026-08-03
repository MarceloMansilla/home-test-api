package karate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.fail;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

class KarateRunnerTest {

  @Test
  void run() {
    preflight();

    // src/resources is a test resource, so the features resolve from the classpath;
    // the environment comes from -Dkarate.env (see pom.xml)
    final Results results = Runner.path("classpath:features")
        .outputCucumberJson(true)
        .parallel(5);

    assertNotNull(results);
    assertEquals(0, results.getFailCount(), results.getErrorMessages());
  }

  /**
   * One request against the target before the suite starts.
   *
   * An unreachable API fails every scenario with the same connection error, which
   * buries the one fact that matters in 25 stack traces. Checking first turns that
   * into a single message naming the environment and the URL, and the suite never
   * runs - so nothing else can be mistaken for a product defect.
   *
   * <p>The health feature reads baseUrl from karate-config.js, so the host is still
   * resolved from the environment YAML and is not duplicated here.
   */
  private static void preflight() {
    // kept out of target/karate-reports entirely: this is a gate, not a test
    // result, and it must not replace or back up the real report
    final Results health = Runner.path("classpath:health")
        .reportDir("target/karate-preflight")
        .backupReportDir(false)
        .outputHtmlReport(false)
        .outputCucumberJson(false)
        .outputJunitXml(false)
        .parallel(1);

    if (health.getFailCount() > 0) {
      final String env = System.getProperty("karate.env", "local");
      fail("PREFLIGHT FAILED - the target for karate.env=" + env + " did not answer,"
          + " so the suite was not run.\n"
          + "Start the API and try again ('local' expects http://localhost:3100),"
          + " or check the host in config/environments/config-" + env + ".yml.\n"
          + health.getErrorMessages());
    }
  }
}
