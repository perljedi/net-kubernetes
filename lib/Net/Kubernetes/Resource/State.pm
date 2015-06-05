package Net::Kubernetes::Resource::State;
use Moose::Role;

has status => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

return 42;