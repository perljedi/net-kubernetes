package Net::Kubernetes::Exception;

use Moose;

=head1 NAME

Net::Kubernetes::Exception

=cut

extends "Throwable::Error";


has code => (
	is       => 'ro',
	isa      => 'Num',
	required => 1,
);

return 42;