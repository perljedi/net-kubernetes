package Net::Kubernetes::Resource::Endpoint;
# ABSTRACT: Object representatioon of a Kubernetes Endpoint

use Moose;

extends 'Net::Kubernetes::Resource';

has subsets => (
    is    => 'ro',
    isa   => 'ArrayRef[HashRef]',
);


return 42;
