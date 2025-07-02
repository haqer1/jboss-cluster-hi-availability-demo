package resat.sabiq.jboss.cluster.hi.availability.demo;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;

import org.junit.jupiter.api.Test;

/**
 * Facilitates code re-use for replication tests.
 *
 * @author	Reşat SABIQ
 */
abstract class AbstractReplicationTest extends AbstractStickySessionsOrReplicationTestBase {
	/**
	 * Facilitates fair-share load assertions, whether there are 2 containers or 2000 or 2 million
	 * in the cluster.
	 *
	 * @author Reşat SABIQ
	 */
	private static class FairShare {
		private static float LIMIT = .1f;
		private static float UPPER_PERCENTAGE = 1 + LIMIT;
		private static float LOWER_PERCENTAGE = 1 - LIMIT;
		private static final class ErrorMessage {
			private static final String FORMAT = "First server container in the cluster must"
					+ " have ratio of requests handled that is %s %s of its fair share"
					+ " (container loads are equally weighted: e.g., %s %s for 10 containers).";
			private static final String EXCESS_MESSAGE = String.format(FORMAT
					, "no more than",	percentFormat.format(FairShare.UPPER_PERCENTAGE)
					, "maximum", "11%");
			private static final String DEFICIT_MESSAGE = String.format(FORMAT
					, "at least",		percentFormat.format(FairShare.LOWER_PERCENTAGE)
					, "minimum", "9%");
		}
	}
	private static final String DATA_REPLICATION_ERR_MSG
		= "With replication the data is expected to be there on each instance called.";
	private static final String FIRST_SERVER_LOAD_RATIO_MSG_FORMAT
		= "first server load ratio=%s vs. min. %s & max. %s (requests handled: %s)%n";

	private short numberOfServerInstances;

	public AbstractReplicationTest(final String script, short numberOfServerInstances) {
		super(script, DATA_REPLICATION_ERR_MSG);
		this.numberOfServerInstances = numberOfServerInstances;
	}

	/**
	 * For extra credit, confirm that 1st server handled at most fair share + 10% of requests.
	 *
	 * @throws IOException
	 */
	@Test
	void givenSessionWithData_when50Requests_then1stServerHandlesBetween90And110PercentOfFairShare()
			throws IOException {
		int ipMatchesCount = calculateCountOfRequestsHandledByServerInstanceThatHandled1stRequest();
		float proportion = (float)1/numberOfServerInstances;
		float maxRatio = proportion * FairShare.UPPER_PERCENTAGE;
		float minRatio = proportion * FairShare.LOWER_PERCENTAGE;
		float firstServerLoadRatio = (float)ipMatchesCount/GET_REQUEST_COUNT;
		System.out.printf(FIRST_SERVER_LOAD_RATIO_MSG_FORMAT
				, firstServerLoadRatio, minRatio, maxRatio, ipMatchesCount);
		assertTrue(firstServerLoadRatio <= maxRatio, FairShare.ErrorMessage.EXCESS_MESSAGE);
		assertTrue(firstServerLoadRatio >= minRatio, FairShare.ErrorMessage.DEFICIT_MESSAGE);
	}
}
