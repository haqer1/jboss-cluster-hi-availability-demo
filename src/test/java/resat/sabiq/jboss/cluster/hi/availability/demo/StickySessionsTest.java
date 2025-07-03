package resat.sabiq.jboss.cluster.hi.availability.demo;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.IOException;

import org.junit.jupiter.api.Test;

/**
 * @author	Reşat SABIQ
 */
class StickySessionsTest extends AbstractStickySessionsOrReplicationTestBase {
	private static String DATA_PRESENCE_ERR_MSG = """
			With sticky sessions the data is expected to be there for each request
			(with same instance called).""";
	public StickySessionsTest() {
		super("sticky-sessions-test.sh", DATA_PRESENCE_ERR_MSG);
	}

	/**
	 * Confirme que toutes les requêtes ont été servies par 1 seul conteneur serveur (adresse IP du
	 * conteneur est la même pour toutes les requêtes).
	 *
	 * @throws IOException
	 */
	@Test
	void givenSessionWithData_whenNumerousRequests_allRequestsAreHandledByTheSameServerInstance()
			throws IOException {
		int ipMatchesCount = calculateCountOfRequestsHandledByServerInstanceThatHandled1stRequest();
		assertEquals(GET_REQUEST_COUNT, ipMatchesCount);
	}
}
