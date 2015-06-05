package Net::Kubernetes;
use Moose;
use Data::Dumper;
require Net::Kubernetes::Namespace;
require LWP::UserAgent;
require HTTP::Request;
require JSON;
require URI;;
require Throwable::Error;
use MIME::Base64;
require Net::Kubernetes::Exception;

# ABSTRACT: Perl interface to kubernetes

=head1 NAME

Net::Kubernetes

=head1 SYNOPSIS

  my $kube = Net::Kubernets->new(url=>'http://127.0.0.1:8080', username=>'dave', password=>'davespassword');
  my $pod_list = $kube->list_pods();

=cut

with 'Net::Kubernetes::Role::APIAccess';
with 'Net::Kubernetes::Role::ResourceLister';
with 'Net::Kubernetes::Role::ResourceCreator';

=head1 Methods

=over 1

=item $kube->list_pods([label=>{label=>value}], [fields=>{field=>value}])

=cut

=item $kube->list_rc([label=>{label=>value}], [fields=>{field=>value}])

=item $kube->list_replication_controllers([label=>{label=>value}], [fields=>{field=>value}]) (alias to list_rc)

=cut

=item $kube->get_namespace("myNamespace");

=cut

sub get_namespace {
	my($self, $namespace) = @_;
	if (! defined $namespace || ! length $namespace) {
		Throwable::Error->throw(message=>'$namespace cannot be null');
	}
	
	my $res = $self->ua->request($self->create_request(GET => $self->url.'/namespaces/'.$namespace));
	if ($res->is_success) {
		my $ns = $self->json->decode($res->content);
		my(%create_args) = (url => $self->url.'/namespaces/'.$namespace	, namespace=> $namespace, _namespace_data=>$ns);
		$create_args{username} = $self->username if(defined $self->username);
		$create_args{password} = $self->password if(defined $self->password);
		return Net::Kubernetes::Namespace->new(%create_args);
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>"Error getting namespace $namespace:\n".$res->message);
	}
}

return 42;

=back

=head1 AUTHOR

  Dave Mueller <dave@perljedi.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Dave Mueller.

This is free software; you can redistribute it and/or modify it under the
same terms as the Perl 5 programming language system itself.
