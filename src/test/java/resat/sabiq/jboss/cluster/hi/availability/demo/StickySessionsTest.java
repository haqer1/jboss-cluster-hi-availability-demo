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
 * @author	Reşat SABIQ
 */
class StickySessionsTest extends AbstractTestTemplate {
	private static final Pattern ipPattern = Pattern.compile("(\\d{1,3}+\\.){3}\\d{1,3}+");

	@Test
	void givenSessionWithData_WhenNumerousRequests_allRequestsHaveSessionData()
			throws IOException, InterruptedException, ExecutionException {
		final int matchesCount
			= execTestScriptAndReturnMatchesCount("sticky-sessions-test.sh");
		float successRatio = toSuccessRatio(matchesCount);
		System.out.println(String.valueOf(matchesCount)+ '/' +GET_REQUEST_COUNT+ '='
				+percentFormat.format(successRatio));
		assertEquals(matchesCount, GET_REQUEST_COUNT,
				"With sticky sessions the data is expected to be there on each instance called.");
		assertEquals(1, successRatio);
	}

	@Test
	void givenSessionWithData_WhenNumerousRequests_allRequestsAreHandledByTheSameServerInstance()
			throws IOException {
		// For extra credit, confirm that all IPs are the same
		Matcher m;
		String ip = null;
		int ipMatchesCount = 0;
		try (BufferedReader bf = new BufferedReader(new FileReader(logFile))) {
			String line;
			while ((line = bf.readLine()) != null) {
				m = ipPattern.matcher(line);
				if (m != null) {
					if (m.find()) {
						if (ip == null) {
							ip = m.group();
							ipMatchesCount = 1;
						} else if (ip.equals(m.group()))
							ipMatchesCount++;
					}
				}
			}
		}
		assertEquals(GET_REQUEST_COUNT, ipMatchesCount);
	}
}
