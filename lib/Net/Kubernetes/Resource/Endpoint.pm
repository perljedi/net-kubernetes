package Net::Kubernetes::Resource::Endpoint;
# ABSTRACT: Object representatioon of a Kubernetes Endpoint

use Moose;

extends 'Net::Kubernetes::Resource';

has subsets => (
    is    => 'ro',
    isa   => 'ArrayRef[HashRef]',
);

augment as_hashref => sub {
    my($self) = @_;
    return ( subsets =>$self->subsets );
};

return 42;
