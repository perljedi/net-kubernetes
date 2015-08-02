package Net::Kubernetes::Resource::ServiceAccount;
# ABSTRACT: Object representatioon of a Kubernetes service account

use Moose;

extends 'Net::Kubernetes::Resource';

has secrets => (
    is      => 'ro',
    isa     => 'ArrayRef[HashRef]',
);

has imagePullSecrets => (
    is      => 'ro',
    isa     => 'ArrayRef[HashRef]',
);

return 42;
