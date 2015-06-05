package Net::Kubernetes::Resource::Service;
use Moose;

extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::State';
with 'Net::Kubernetes::Resource::Spec';

return 42;