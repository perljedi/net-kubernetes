package Net::Kubernetes::Resource::Spec;
use Moose::Role;

has spec => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

return 42;