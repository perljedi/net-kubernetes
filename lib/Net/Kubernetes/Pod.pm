package Net::Kubernetes::Pod;
use Moose;

has metadata => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

has status => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

has spec => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);


return 42;