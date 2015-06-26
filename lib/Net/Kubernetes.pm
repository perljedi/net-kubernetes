package Net::Kubernetes;

use Moose;
require Net::Kubernetes::Namespace;
require LWP::UserAgent;
require HTTP::Request;
require URI;;
require Throwable::Error;
use MIME::Base64;
require Net::Kubernetes::Exception;

# ABSTRACT: Perl interface to kubernetes

=head1 NAME

Net::Kubernetes

This package provides an object oriented interface to the REST API's provided by kubernetes.

=head1 STATUS

=begin html

<img src="https://travis-ci.org/perljedi/net-kubernetes.svg?branch=master" />

=end html

=head1 SYNOPSIS

  my $kube = Net::Kubernets->new(url=>'http://127.0.0.1:8080', username=>'dave', password=>'davespassword');
  my $pod_list = $kube->list_pods();
  
  my $nginx_pod = $kube->create_from_file('kubernetes/examples/pod.yaml');
  
  my $ns = $kube->get_namespace('default');
  
  my $services = $ns->list_services;
  
  my $pod = $ns->get_pod('my-pod');
  
  $pod->delete;
  
  my $other_pod = $ns->create_from_file('./my-pod.yaml');

=head1 Description

This package allows programatic access to the L<Kubernetes|http://kubernetes.io> rest api.

Please note this package is still a BETA release (as is kubernetes itself), and the methods
and API are still subject to change.  Use at your own risk.

=cut


with 'Net::Kubernetes::Role::APIAccess';
with 'Net::Kubernetes::Role::ResourceLister';
with 'Net::Kubernetes::Role::ResourceCreator';

=head1 Methods

By convention, methods will throw exceptions if kubernetes api server returns a non-successful status code.
Unless otherwise noted, assume this behavoir through out.

=over 1

=item new - Create a new $kube object

All parameters are optional and have some basic default values (where appropriate).

=over 1

=item url ['http://localhost:8080']

The base url for the kubernetes. This should include the protocal (http or https) but not "/api/v1beta3" (see base_path).

=item base_path ['/api/v1beta3']

The entry point for api calls, this may be used to set the api version with which to interact.

=item username

Username to use with basic authentication. If either username or password are not provided, basic authentication will not
be used.

=item password

Password to use with basic authentication. If either username or password are not provided, basic authentication will not
be used.

=item token

An authentication token to be used to access the apiserver.  This may be provided as a plain string, a path to a file
from which to read the token (like /var/run/secrets/kubernetes.io/serviceaccount/token from within a pod), or a reference
to a file handle (from which to read the token).

=back

=item $kube->get_namespace("myNamespace");

This method returns a "Namespace" object on which many methods can be called implicitly
limited to the specified namespace.

=item my(@pods) = $kube->list_pods([label=>{label=>value}], [fields=>{field=>value}])

=item my(@rcs) = $kube->list_rc([label=>{label=>value}], [fields=>{field=>value}])

=item my(@rcs) = $kube->list_replication_controllers([label=>{label=>value}], [fields=>{field=>value}]) (alias to list_rc)

=item my(@scerets) = $kube->list_secrets([label=>{label=>value}], [fields=>{field=>value}])

=item my(@services) = $kube->list_services([label=>{label=>value}], [fields=>{field=>value}])

=item my $resource = $kube->create({OBJECT})

=item my $resource = $kube->create_from_file(PATH_TO_FILE) (accepts either JSON or YAML files)

Create from file is really just a short cut around something like:

  my $object = YAML::LoadFile(PATH_TO_FILE);
  $kube->create($object);

=back

=cut

sub get_namespace {
	my($self, $namespace) = @_;
	if (! defined $namespace || ! length $namespace) {
		Throwable::Error->throw(message=>'$namespace cannot be null');
	}
	my $res = $self->ua->request($self->create_request(GET => $self->path.'/namespaces/'.$namespace));
	if ($res->is_success) {
		my $ns = $self->json->decode($res->content);
		my(%create_args) = (url => $self->url, base_path=>$ns->{metadata}{selfLink}, namespace=> $namespace, _namespace_data=>$ns);
		$create_args{username} = $self->username if(defined $self->username);
		$create_args{password} = $self->password if(defined $self->password);
		return Net::Kubernetes::Namespace->new(%create_args);
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>"Error getting namespace $namespace:\n".$res->message);
	}
}

return 42;

=head1 See Also

L<Net::Kubernetes::Namespace>, L<Net::Kubernetes::Resource>

=head1 AUTHOR

  Dave Mueller <dave@perljedi.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Dave Mueller.

This is free software; you can redistribute it and/or modify it under the
same terms as the Perl 5 programming language system itself.
