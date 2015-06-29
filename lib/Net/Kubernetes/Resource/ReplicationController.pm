package Net::Kubernetes::Resource::ReplicationController;
# ABSTRACT: Object representatioon of a Kubernetes Replication Controller

use Moose;
use URI;


extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Resource::Role::HasPods';


=method my(@pods) = $rc->get_pods()

Fetch a list off all pods belonging to this replication controller.

=cut

return 42;