package resat.sabiq.jboss.cluster.hi.availability.demo;

/**
 * @author	Reşat SABIQ
 */
class KubernetesBasedReplicationTest extends AbstractReplicationTest {
	public KubernetesBasedReplicationTest() {
		super("k8s-replication-test.sh", (short)2);
	}
}
