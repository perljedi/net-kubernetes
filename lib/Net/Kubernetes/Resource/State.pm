package Net::Kubernetes::Resource::State;

use Moose::Role;

=head1 NAME

Net::Kubernetes::Resource::State

=cut


has status => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

return 42;