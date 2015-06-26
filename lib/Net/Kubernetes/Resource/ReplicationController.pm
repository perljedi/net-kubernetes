package Net::Kubernetes::Resource::ReplicationController;

use Moose;
use URI;

=head1 NAME

Net::Kubernetes::Resource::ReplicationController

Object representaiton of a Kubernetes Replication Controller

=cut

extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Resource::Role::HasPods';

=head1 Methods

=over 1

=item my(@pods) = $rc->get_pods()

Fetch a list off all pods belonging to this replication controller

=back

=cut

return 42;