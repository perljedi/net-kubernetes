package Net::Kubernetes::Resource::Event;
# ABSTRACT: Object representatioon of a Kubernetes event

use Moose;

extends 'Net::Kubernetes::Resource';

has reason => (
	is       => 'ro',
	isa      => 'Str',
	required => 0
);

has message => (
	is       => 'ro',
	isa      => 'Str',
	required => 0
);

has firstTimestamp => (
	is       => 'ro',
	isa      => 'Str',
	required => 0
);

has lastTimestamp => (
	is       => 'ro',
	isa      => 'Str',
	required => 0
);

has count => (
	is       => 'ro',
	isa      => 'Int',
	required => 0
);

has source => (
	is       => 'ro',
	isa      => 'HashRef',
	required => 0
);


has involvedObject => (
	is       => 'ro',
	isa      => 'HashRef',
	required => 0
);

return 42;