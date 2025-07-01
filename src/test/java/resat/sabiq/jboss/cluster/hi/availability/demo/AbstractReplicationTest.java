package resat.sabiq.jboss.cluster.hi.availability.demo;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;

import org.junit.jupiter.api.Test;

/**
 * @author	Reşat SABIQ
 */
class AbstractReplicationTest extends AbstractStickySessionsOrReplicationTestBase {
	private static float FAIR_SHARE_LIMIT = .1f;
	private static String FAIR_SHARE_EXCESS_ERR_MSG = """
		First server instance must have ratio of requests handled that is no more than its fair
		share plus """
		+ ' ' +percentFormat.format(FAIR_SHARE_LIMIT)+ '.';
	private static String FAIR_SHARE_DEFICIT_ERR_MSG = """
		First server instance must have ratio of requests handled that is at least its fair
		share plus-minus """
		+ ' ' +percentFormat.format(FAIR_SHARE_LIMIT)+ '.';
	private static String DATA_REPLICATION_ERR_MSG
		= "With replication the data is expected to be there on each instance called.";

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
	void givenSessionWithData_whenNumerousRequests_1stServerHandlesFairSharePlusMinus10PercentOfRequests()
			throws IOException {
		int ipMatchesCount = calculateCountOfRequestsHandledByServerInstanceThatHandled1stRequest();
		float proportion = (float)1/numberOfServerInstances;
		float maxRatio = proportion + FAIR_SHARE_LIMIT;
		float minRatio = proportion - FAIR_SHARE_LIMIT;
		float firstServerLoadRatio = (float)ipMatchesCount/GET_REQUEST_COUNT;
		System.out.printf("firstServerLoadRatio=%s vs. min. %s & max. %s (requests handled: %s)%n"
				, firstServerLoadRatio, minRatio, maxRatio, ipMatchesCount);
		assertTrue(firstServerLoadRatio <= maxRatio, FAIR_SHARE_EXCESS_ERR_MSG);
		assertTrue(firstServerLoadRatio >= minRatio, FAIR_SHARE_DEFICIT_ERR_MSG);
	}
}
