package Net::Kubernetes::Resource::Secret;

use Moose;

=head1 NAME

Net::Kubernetes::Resource::Secret

=cut

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