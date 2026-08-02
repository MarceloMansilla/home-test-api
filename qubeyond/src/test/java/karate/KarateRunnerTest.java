package karate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

class KarateRunnerTest {

  @Test
  void run() {
    // src/resources is a test resource, so the features resolve from the classpath;
    // the environment comes from -Dkarate.env (see pom.xml)
    final Results results = Runner.path("classpath:features")
        .outputCucumberJson(true)
        .parallel(5);

    assertNotNull(results);
    assertEquals(0, results.getFailCount(), results.getErrorMessages());
  }
}
