package karate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.fail;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

class KarateRunnerTest {

  /** Used when -Dkarate.threads is absent - an IDE run, where pom.xml is not involved. */
  private static final int DEFAULT_THREADS = 5;

  @Test
  void run() {
    // resolved before the preflight on purpose: a malformed -Dkarate.threads is an
    // argument error, and it should be reported as one immediately rather than
    // after a network round trip that may itself fail for an unrelated reason
    final int threads = threads();

    preflight();

    // src/resources is a test resource, so the features resolve from the classpath;
    // the environment comes from -Dkarate.env and the thread count from
    // -Dkarate.threads (see pom.xml)
    final Results results = Runner.path("classpath:features")
        .outputCucumberJson(true)
        .parallel(threads);

    assertNotNull(results);
    assertEquals(0, results.getFailCount(), results.getErrorMessages());
  }

  /**
   * Thread count for the suite, from {@code -Dkarate.threads}.
   *
   * <p>A CI runner, a laptop and a debugging session want different numbers, and none
   * of them should require editing this file and recompiling. pom.xml supplies the
   * default and forwards it to the forked test JVM, exactly as it does for
   * {@code karate.env}; the constant here only covers running from an IDE, where
   * surefire never runs.
   *
   * <p>An unusable value fails with the value that was given, rather than a
   * {@link NumberFormatException} stack or - worse - a silent fallback to the default
   * that would let a run quietly use a concurrency it was never asked for.
   */
  private static int threads() {
    final String raw = System.getProperty("karate.threads");

    if (raw == null || raw.trim().isEmpty()) {
      return DEFAULT_THREADS;
    }

    final int parsed;
    try {
      parsed = Integer.parseInt(raw.trim());
    } catch (NumberFormatException e) {
      throw new IllegalArgumentException(
          "karate.threads must be a positive integer, but was '" + raw + "'."
              + " Example: mvn test -Dkarate.threads=10");
    }

    if (parsed < 1) {
      throw new IllegalArgumentException(
          "karate.threads must be at least 1, but was " + parsed + "."
              + " Use -Dkarate.threads=1 to run the suite sequentially.");
    }

    return parsed;
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
