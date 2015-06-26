package Net::Kubernetes::Resource::Service;

use Moose;

=head1 NAME

Net::Kubernetes::Resource::Service

=cut

extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';

return 42;