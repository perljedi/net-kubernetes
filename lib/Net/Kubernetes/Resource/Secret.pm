package Net::Kubernetes::Resource::Secret;
use Moose;

extends 'Net::Kubernetes::Resource';

has type => (
	is       => 'ro',
	isa      => 'Str',
	required => 1
);

has data => (
	is       => 'ro',
	isa      => 'HashRef',
	required => 1
);

return 42;