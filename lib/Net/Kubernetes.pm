package Net::Kubernetes;
use Moose;
use Data::Dumper;
use MooseX::Aliases;
require Net::Kubernetes::Resource::Pod;
require Net::Kubernetes::Resource::ReplicationController;
require LWP::UserAgent;
require HTTP::Request;
require JSON;
require URI;
require Throwable::Error;

# ABSTRACT: Perl interface to kubernetes

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

has 'json' => (
    is       => 'ro',
    isa      => 'JSON',
    required => 1,
    lazy     => 1,
    builder  => '_build_json',
);

=head1 Methods

=over 1

=item $kube->list_fields([label=>{label=>value}], [fields=>{field=>value}])

=cut

sub list_pods {
	my $self = shift;
	my(%options);
	if (ref($_[0])) {
		%options = %{ $_[0] };
	}else{
		%options = @_;
	}

	my $uri = URI->new($self->url.'/pods');
	my(%form) = ();
	$form{labelSelector}=$self->_build_selector_from_hash($options{labels}) if (exists $options{labels});
	$form{fieldSelector}=$self->_build_selector_from_hash($options{fields}) if (exists $options{fields});
	$uri->query_form(%form);

	my $res = $self->ua->request(HTTP::Request->new(GET => $uri));
	if ($res->is_success) {
		my $pod_list = $self->json->decode($res->content);
		my(@pods)=();
		foreach my $pod (@{ $pod_list->{items}}){
			push @pods, Net::Kubernetes::Resource::Pod->new(%$pod);
		}
		return wantarray ? @pods : \@pods;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

=item $kube->list_fields([label=>{label=>value}], [fields=>{field=>value}])

=cut

sub list_replication_controllers {
	my $self = shift;
	my(%options);
	if (ref($_[0])) {
		%options = %{ $_[0] };
	}else{
		%options = @_;
	}

	my $uri = URI->new($self->url.'/replicationcontrollers');
	my(%form) = ();
	$form{labelSelector}=$self->_build_selector_from_hash($options{labels}) if (exists $options{labels});
	$form{fieldSelector}=$self->_build_selector_from_hash($options{fields}) if (exists $options{fields});
	$uri->query_form(%form);

	my $res = $self->ua->request(HTTP::Request->new(GET => $uri));
	if ($res->is_success) {
		my $pod_list = $self->json->decode($res->content);
		my(@pods)=();
		foreach my $pod (@{ $pod_list->{items}}){
			push @pods, Net::Kubernetes::Resource::ReplicationController->new($pod);
		}
		return wantarray ? @pods : \@pods;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

alias list_rc => 'list_replication_controllers';

=item $kube->get_namespace("myNamespace");

=cut

sub get_namespace {
	my($self, $namespace) = @_;
	if (! defined $namespace || ! length $namespace) {
		Throwable::Error->throw(message=>'$namespace cannot be null');
	}
	
	my $res = $self->ua->request(HTTP::Request->new(GET => $self->url.'/namespaces/'.$namespace));
	if ($res->is_success) {
		my $ns = $self->json->decode($res->content);
		my(%create_args) = (url => $self->url.'/namespaces/'.$namespace	, namespace=> $namespace, _namespace_data=>$ns);
		$create_args{username} = $self->username if(defined $self->username);
		$create_args{password} = $self->password if(defined $self->password);
		return Net::Kubernetes->new(%create_args);
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>"Error getting namespace $namespace:\n".$res->message);
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

extends "Throwable::Error";


has code => (
	is       => 'ro',
	isa      => 'Num',
	required => 1,
);

return 42;

=back

=head1 AUTHOR

  Dave Mueller <dave@perljedi.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Dave Mueller.

This is free software; you can redistribute it and/or modify it under the
same terms as the Perl 5 programming language system itself.
