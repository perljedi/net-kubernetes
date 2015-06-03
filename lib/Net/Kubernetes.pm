package Net::Kubernetes;
use Moose;
use LWP::UserAgent;
use Data::Dumper;
use HTTP::Request;
use JSON;

has url => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	default  => 'http://localhost:8080/api/v1beta3'
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
	builder  => '_build_lwp_agent'
);

has 'json' => (
    is       => 'ro',
    isa      => 'JSON',
    required => 1,
    lazy     => 1,
    builder  => '_build_json',
);


sub list_pods {
	my $self = shift;
	my $res = $self->ua->request(HTTP::Request->new(GET => $self->url.'/pods'));
	if ($res->is_success) {
		return $self->json->decode($res->content);
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}


sub _build_lwp_agent {
	my $self = shift;
	return LWP::UserAgent->new(agent=>'net-kubernetes-perl/0.01');
}

sub _build_json {
    return JSON->new->allow_blessed(1)->convert_blessed(1);
}


package Net::Kubernetes::Exception;
use Moose;

with "Throwable";


has code => (
	is       => 'ro',
	isa      => 'Num',
	required => 1,
);

has message => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
);

return 42;
