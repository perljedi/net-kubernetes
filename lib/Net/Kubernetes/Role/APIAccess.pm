package Net::Kubernetes::Role::APIAccess;

use Moose::Role;
require LWP::UserAgent;
require HTTP::Request;
require JSON;
require URI;
use MIME::Base64;

=head1 NAME

Net::Kubernetes::Role::APIAccess

=cut


has url => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	default  => 'http://localhost:8080',
);

has base_path => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	default  => 'api/v1beta3',
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

has token => (
	is       => 'ro',
	isa      => 'Str',
	required => 0
);

has 'json' => (
    is       => 'ro',
    isa      => 'JSON',
    required => 1,
    lazy     => 1,
    builder  => '_build_json',
);

around BUILDARGS => sub {
	my $orig = shift;
	my $class = shift;
	my(%input) = @_;
	if(ref($input{token})){
		if($input{token}->can('getlines')){
			$input{token} = join('', $input{token}->getlines);
		}
		elsif (ref($input{token}) eq 'GLOB') {
			$input{token} = do{ local $/; <$input{file}>};
		}
	}elsif (exists $input{token} && -f $input{token}) {
		open(my $fh, '<', $input{token});
		$input{token} = do{ local $/; <$fh>};
		close($fh);
	}
	return $class->$orig(%input);
};

sub path {
	my($self) = @_;
	return $self->url.'/'.$self->base_path;
}

sub _build_lwp_agent {
	my $self = shift;
	my $ua = LWP::UserAgent->new(agent=>'net-kubernetes-perl/0.01');
	$ua->ssl_opts(verify_hostname=>0);
	return $ua;
}

sub _build_json {
    return JSON->new->allow_blessed(1)->convert_blessed(1);
}

sub create_request {
	my($self, @options) = @_;
	my $req = HTTP::Request->new(@options);
	if ($self->username && $self->password) {
		$req->header(Authorization=>"Basic ".encode_base64($self->username.':'.$self->password));
	}
	elsif($self->token){
		$req->header(Authorization=>"Bearer ".$self->token);
	}
	return $req;
}


return 42;