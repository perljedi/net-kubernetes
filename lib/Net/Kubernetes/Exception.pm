package Net::Kubernetes::Exception;
use Moose;

extends "Throwable::Error";


has code => (
	is       => 'ro',
	isa      => 'Num',
	required => 1,
);

return 42;