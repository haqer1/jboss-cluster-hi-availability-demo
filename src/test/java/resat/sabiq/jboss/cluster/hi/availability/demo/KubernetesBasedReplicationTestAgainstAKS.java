package resat.sabiq.jboss.cluster.hi.availability.demo;

import java.util.Optional;

/**
 * Confirme fonctionnement approprié de replication dans grappe de 2 conteneurs serveur JBoss
 * (WildFly) déployée sur AKS dans le cadre d'un essaie gratuit de 30 jours (€200).
 *
 * @author	Reşat SABIQ
 */
class KubernetesBasedReplicationTestAgainstAKS extends AbstractReplicationTest {
	public KubernetesBasedReplicationTestAgainstAKS() {
		super("k8s-replication-test.sh", Optional.of(
			new String[] {"https://jboss-replication-ha-demo.francecentral.cloudapp.azure.com"})
			, (short)2);
	}
}
