package resat.sabiq.jboss.cluster.hi.availability.demo;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.concurrent.ExecutionException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.jupiter.api.Test;

/**
 * Facilitates code re-use for sticky-sessions and replication tests.
 *
 * @author	Reşat SABIQ
 */
abstract class AbstractStickySessionsOrReplicationTestBase extends AbstractTestTemplate {
	private static final Pattern ipPattern = Pattern.compile(">((\\d{1,3}+\\.){3}\\d{1,3}+)<");
	private static final byte IP_GROUP = 1;

	private String script, assertionFailureMsg;

	protected AbstractStickySessionsOrReplicationTestBase(String script
			, String assertionFailureMsg) {
		this.script = script;
		this.assertionFailureMsg = assertionFailureMsg;
	}

	protected int calculateCountOfRequestsHandledByServerInstanceThatHandled1stRequest()
			throws IOException {
		Matcher m;
		String ip = null;
		int ipMatchesCount = 0;
		try (BufferedReader bf = new BufferedReader(new FileReader(logFile))) {
			String line;
			while ((line = bf.readLine()) != null) {
				m = ipPattern.matcher(line);
				if (m != null) {
					if (m.find()) {
						final String justMatchedIP = m.group(IP_GROUP);
						if (ip == null) {
							ip = justMatchedIP;
							System.out.printf("first server IP: %s%n", ip);
							ipMatchesCount = 1;
						} else if (ip.equals(justMatchedIP))
							ipMatchesCount++;
					}
				}
			}
		}
		return ipMatchesCount;
	}

	/**
	 * Montre que les données sont dispos pour toutes les requêtes servies (sur tous les conteneurs
	 * serveur à travers la grappe).
	 *
	 * @throws IOException
	 * @throws InterruptedException
	 * @throws ExecutionException
	 */
	@Test
	void givenSessionWithData_whenNumerousRequests_allRequestsHaveSessionData()
			throws IOException, InterruptedException, ExecutionException {
		final int matchesCount
			= execTestScriptAndReturnMatchesCount(script);
		float successRatio = toSuccessRatio(matchesCount);
		System.out.println(String.valueOf(matchesCount)+ '/' +GET_REQUEST_COUNT+ '='
				+percentFormat.format(successRatio));
		assertEquals(matchesCount, GET_REQUEST_COUNT, assertionFailureMsg);
		assertEquals(1, successRatio);
	}
}
