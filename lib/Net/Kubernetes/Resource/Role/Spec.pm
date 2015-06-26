package Net::Kubernetes::Resource::Role::Spec;

use Moose::Role;

=head1 NAME

Net::Kubernetes::Resource::Role::Spec

Role for resource objects which has a "spec" attribute.

=cut


has spec => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

around "as_hashref" => sub {
	my ($orig, $self) = @_;
	my $ref = $self->$orig;
	$ref->{spec} = $self->spec;
	return $ref;
};

return 42;