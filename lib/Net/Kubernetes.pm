package Net::Kubernetes;
use Moose;
use LWP::UserAgent;
use Data::Dumper;
use HTTP::Request;
use JSON;
use URI;

# ABSTRACT: Perl interface to t kubernetes

=head1 NAME

Net::Kubernetes

=head1 SYNOPSIS

  my $kube = Net::Kubernets->new(url=>'http://127.0.0.1:8080', username=>'dave', password=>'davespassword');
  my $pod_list = $kube->list_pods();

=cut

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

=head1 Methods

=head2 $kube->list_fields([label=>{label=>value}], [fields=>{field=>value}])

=cut

sub list_pods {
	my $self = shift;
	my(%options);
	if (ref($_[0])) {
		%options = %$_[0];
	}else{
		%options = @_;
	}

	my $uri = URI->new($self->url.'/pods');
	my(%form) = ();
	$form{labelSelector}=$self->_build_selector_from_hash($options{labels}) if (exists $options{labels});
	$form{fieldSelector}=$self->_build_selector_from_hash($options{fields}) if (exists $options{fields});
	$uri->query_form(%form);
	print "$uri\n";

	my $res = $self->ua->request(HTTP::Request->new(GET => $uri));
	if ($res->is_success) {
		return $self->json->decode($res->content);
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

sub _build_selector_from_hash {
	my($self, $select_hash) = @_;
	my(@selectors);
	foreach my $label (keys %{ $select_hash }){
		push @selectors, $label.'='.$select_hash->{$label};
	}
	return \@selectors;
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
