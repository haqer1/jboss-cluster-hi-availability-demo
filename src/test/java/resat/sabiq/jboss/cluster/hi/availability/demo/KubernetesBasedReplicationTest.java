package resat.sabiq.jboss.cluster.hi.availability.demo;

import java.util.Optional;

/**
 * @author	Reşat SABIQ
 */
class KubernetesBasedReplicationTest extends AbstractReplicationTest {
	public KubernetesBasedReplicationTest() {
		super("k8s-replication-test.sh"
				, Optional.of(new String[] {"load-balancing-replication-ingress-demo"}), (short)2);
	}
}
