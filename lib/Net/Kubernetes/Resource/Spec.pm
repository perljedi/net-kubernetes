package Net::Kubernetes::Resource::Spec;

use Moose::Role;

=head1 NAME

Net::Kubernetes::Resource::Spec

=cut


has spec => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

return 42;