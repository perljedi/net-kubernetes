package Net::Kubernetes::Resource::ReplicationController;

use Moose;

=head1 NAME

Net::Kubernetes::Resource::ReplicationController

=cut

extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::State';
with 'Net::Kubernetes::Resource::Spec';

return 42;