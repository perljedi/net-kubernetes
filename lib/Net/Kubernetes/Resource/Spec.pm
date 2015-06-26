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

around "as_hashref" => sub {
	my ($orig, $self) = @_;
	my $ref = $self->$orig;
	$ref->{spec} = $self->spec;
	return $ref;
};

return 42;