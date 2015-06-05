package Net::Kubernetes::Resource::Service;

use Moose;

=head1 NAME

Net::Kubernetes::Resource::Service

=cut

extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::State';
with 'Net::Kubernetes::Resource::Spec';

return 42;