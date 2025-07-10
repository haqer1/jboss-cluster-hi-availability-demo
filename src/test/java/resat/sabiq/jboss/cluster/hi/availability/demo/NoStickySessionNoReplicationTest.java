package resat.sabiq.jboss.cluster.hi.availability.demo;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

import org.junit.jupiter.api.Test;

/**
 * @author	Reşat SABIQ
 */
class NoStickySessionNoReplicationTest extends AbstractTestTemplate {
	private static String DATA_PRESENCE_ERR_MSG = """
			With no sticky sessions & no replication sometimes data is expected to not be
			there on the container called.""";

	/**
	 * Confirme que sans ni sessions collantes, ni réplication, les données ne sont pas dispos pour
	 * une partie de requêtes servies à travers la grappe.
	 *
	 * @throws IOException
	 */
	@Test
	void givenSessionWithData_whenNumerousRequests_someRequestsDontHaveSessionData()
			throws IOException, InterruptedException, ExecutionException {
		final int matchesCount = execTestScriptAndReturnMatchesCount(
									"no-sticky-sessions-no-replication-test.sh", Optional.empty());
		System.out.printf("Success rate < 100%% as expected for %d requests: %s%n"
				, GET_REQUEST_COUNT, percentFormat.format(toSuccessRatio(matchesCount)));
		assertTrue(matchesCount < GET_REQUEST_COUNT, DATA_PRESENCE_ERR_MSG);
	}
}
