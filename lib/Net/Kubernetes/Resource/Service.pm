package Net::Kubernetes::Resource::Service;
# ABSTRACT: Object representatioon of a Kubernetes Service

use Moose;


extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Resource::Role::HasPods';



=method my(@pods) = $service->get_pods()

Fetch a list off all pods belonging to this service.

=cut

return 42;