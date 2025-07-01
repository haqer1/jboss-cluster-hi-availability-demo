package resat.sabiq.jboss.cluster.hi.availability.demo;

/**
 * @author	Reşat SABIQ
 */
class PureDockerBasedReplicationTest extends AbstractReplicationTest {
	public PureDockerBasedReplicationTest() {
		super("pure-docker-replication-test.sh", (short)3);
	}
}
