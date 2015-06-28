package Net::Kubernetes::Resource::Service;

use Moose;

=head1 NAME

Net::Kubernetes::Resource::Service

=cut

extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Resource::Role::HasPods';


=head1 Methods

=over 1

=item my(@pods) = $service->get_pods()

Fetch a list off all pods belonging to this service.

=back

=cut

return 42;