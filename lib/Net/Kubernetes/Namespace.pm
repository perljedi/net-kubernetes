package Net::Kubernetes::Namespace;
use Moose;

has namespace => (
	is       => 'ro',
	isa      => 'Str',
	required => 0,	
);

has _namespace_data => (
	is       => 'ro',
	isa      => 'HashRef',
	required => 0,	
);

with 'Net::Kubernetes::Role::APIAccess';


