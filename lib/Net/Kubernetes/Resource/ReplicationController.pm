package Net::Kubernetes::Resource::ReplicationController;
use Moose;

extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::State';
with 'Net::Kubernetes::Resource::Spec';

return 42;