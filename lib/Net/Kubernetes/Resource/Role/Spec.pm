package Net::Kubernetes::Resource::Role::Spec;
# ABSTRACT: Resource role for types that have a spec

use Moose::Role;

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