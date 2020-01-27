package javatests.core;

import gust.Core;
import org.junit.Test;
import static org.junit.Assert.assertNotNull;


/**
 * Tests that J2CL classes can be used Java-side.
 */
public class DualStackTest {
  @Test
  public void testDualStackObject() {
    assertNotNull(
      "Core object should produce version",
      Core.getVersion());
  }
}