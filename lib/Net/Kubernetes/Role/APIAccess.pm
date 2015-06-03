package Net::Kubernetes::Role::APIAccess;
use Moose::Role;
require LWP::UserAgent;
require HTTP::Request;
require JSON;
require URI;


has url => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	default  => 'http://localhost:8080/api/v1beta3',
);

has password => (
	is       => 'ro',
	isa      => 'Str',
	required => 0,
);

has username => (
	is       => 'ro',
	isa      => 'Str',
	required => 0,
);

has ua => (
	is       => 'ro',
	isa      => 'LWP::UserAgent',
	required => 1,
	builder  => '_build_lwp_agent',
);

has 'json' => (
    is       => 'ro',
    isa      => 'JSON',
    required => 1,
    lazy     => 1,
    builder  => '_build_json',
);


sub _build_lwp_agent {
	my $self = shift;
	return LWP::UserAgent->new(agent=>'net-kubernetes-perl/0.01');
}

sub _build_json {
    return JSON->new->allow_blessed(1)->convert_blessed(1);
}


return 42;