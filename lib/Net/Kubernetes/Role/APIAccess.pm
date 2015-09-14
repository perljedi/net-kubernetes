package Net::Kubernetes::Role::APIAccess;
# ABSTRACT: Role allowing direct access to the REST api

use Moose::Role;
require LWP::UserAgent;
require HTTP::Request;
use JSON::MaybeXS;
require Cpanel::JSON::XS;
require URI;
use MIME::Base64;


has url => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	default  => 'http://localhost:8080',
);

has api_version => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
);

has base_path => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
	lazy     => 1,
	builder  => '_create_default_base_path'
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
    isa      => JSON::MaybeXS::JSON,
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
			my $fh = $input{token};
			$input{token} = do{ local $/; <$fh>};
		}
	}elsif (exists $input{token} && -f $input{token}) {
		open(my $fh, '<', $input{token});
		$input{token} = do{ local $/; <$fh>};
		close($fh);
	}
	if(! exists $input{api_version}){
		if(exists $input{base_path}){
			if($input{base_path} =~ m{/api/(v[^/]+)}){
				$input{api_version} = $1;
			}
		}
		else {
			$input{api_version}='v1';
		}
	}
	return $class->$orig(%input);
};

sub _create_default_base_path {
	my($self) = @_;
	return '/api/'.$self->api_version;
}

sub path {
	my($self) = @_;
	return $self->url.$self->base_path;
}

sub _build_lwp_agent {
	my $self = shift;
	my $ua = LWP::UserAgent->new(agent=>'net-kubernetes-perl/0.20');
	$ua->ssl_opts(verify_hostname=>0);
	return $ua;
}

sub _build_json {
    return JSON::MaybeXS->new->allow_blessed(1)->convert_blessed(1);
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
