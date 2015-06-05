package Net::Kubernetes::Resource::Pod;

use Moose;

=head1 NAME

Net::Kubernetes::Resource::Pod

=cut

extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::State';
with 'Net::Kubernetes::Resource::Spec';

return 42;