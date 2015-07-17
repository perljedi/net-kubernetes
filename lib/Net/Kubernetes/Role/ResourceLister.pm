package Net::Kubernetes::Role::ResourceLister;
# ABSTRACT: Role to give access to list_* methods.

use Moose::Role;
use MooseX::Aliases;
require Net::Kubernetes::Resource::Service;
require Net::Kubernetes::Resource::Pod;
require Net::Kubernetes::Resource::ReplicationController;

with 'Net::Kubernetes::Role::ResourceFactory';

requires 'ua';
requires 'create_request';
requires 'json';

=method list_pods([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Pod>s

=cut

sub list_pods {
	my $self = shift;
	my(%options);
	if (ref($_[0])) {
		%options = %{ $_[0] };
	}else{
		%options = @_;
	}

	my $uri = URI->new($self->path.'/pods');
	my(%form) = ();
	$form{labelSelector}=$self->_build_selector_from_hash($options{labels}) if (exists $options{labels});
	$form{fieldSelector}=$self->_build_selector_from_hash($options{fields}) if (exists $options{fields});
	$uri->query_form(%form);

	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $pod_list = $self->json->decode($res->content);
		my(@pods)=();
		foreach my $pod (@{ $pod_list->{items}}){
			$pod->{apiVersion} = $pod_list->{apiVersion};
			push @pods, $self->create_resource_object($pod, 'Pod');
		}
		return wantarray ? @pods : \@pods;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

=method list_rc([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::ReplicationController>s

=method list_replication_controllers([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::ReplicationController>s

=cut

sub list_replication_controllers {
	my $self = shift;
	my(%options);
	if (ref($_[0])) {
		%options = %{ $_[0] };
	}else{
		%options = @_;
	}

	my $uri = URI->new($self->path.'/replicationcontrollers');
	my(%form) = ();
	$form{labelSelector}=$self->_build_selector_from_hash($options{labels}) if (exists $options{labels});
	$form{fieldSelector}=$self->_build_selector_from_hash($options{fields}) if (exists $options{fields});
	$uri->query_form(%form);

	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $pod_list = $self->json->decode($res->content);
		my(@rcs)=();
		foreach my $rc (@{ $pod_list->{items}}){
			$rc->{apiVersion} = $pod_list->{apiVersion};
			push @rcs, $self->create_resource_object($rc, 'ReplicationController');;
		}
		return wantarray ? @rcs : \@rcs;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

alias list_rc => 'list_replication_controllers';

=method list_services([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Service>s

=cut

sub list_services {
	my $self = shift;
	my(%options);
	if (ref($_[0])) {
		%options = %{ $_[0] };
	}else{
		%options = @_;
	}

	my $uri = URI->new($self->path.'/services');
	my(%form) = ();
	$form{labelSelector}=$self->_build_selector_from_hash($options{labels}) if (exists $options{labels});
	$form{fieldSelector}=$self->_build_selector_from_hash($options{fields}) if (exists $options{fields});
	$uri->query_form(%form);

	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $pod_list = $self->json->decode($res->content);
		my(@services)=();
		foreach my $service (@{ $pod_list->{items}}){
			$service->{apiVersion} = $pod_list->{apiVersion};
			push @services, $self->create_resource_object($service, 'Service');
		}
		return wantarray ? @services : \@services;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

=method list_events([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Event>s

=cut

sub list_events {
	my $self = shift;
	my(%options);
	if (ref($_[0])) {
		%options = %{ $_[0] };
	}else{
		%options = @_;
	}

	my $uri = URI->new($self->path.'/events');
	my(%form) = ();
	$form{labelSelector}=$self->_build_selector_from_hash($options{labels}) if (exists $options{labels});
	$form{fieldSelector}=$self->_build_selector_from_hash($options{fields}) if (exists $options{fields});
	$uri->query_form(%form);

	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $event_list = $self->json->decode($res->content);
		my(@events)=();
		foreach my $service (@{ $event_list->{items}}){
			$service->{apiVersion} = $event_list->{apiVersion};
			push @events, $self->create_resource_object($service, 'Event');
		}
		return wantarray ? @events : \@events;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

=method list_secrets([label=>{label=>value}], [fields=>{field=>value}])

returns a list of L<Net::Kubernetes::Resource::Secret>s

=cut

sub list_secrets {
	my $self = shift;
	my(%options);
	if (ref($_[0])) {
		%options = %{ $_[0] };
	}else{
		%options = @_;
	}

	my $uri = URI->new($self->path.'/secrets');
	my(%form) = ();
	$form{labelSelector}=$self->_build_selector_from_hash($options{labels}) if (exists $options{labels});
	$form{fieldSelector}=$self->_build_selector_from_hash($options{fields}) if (exists $options{fields});
	$uri->query_form(%form);

	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $pod_list = $self->json->decode($res->content);
		my(@secrets)=();
		foreach my $secret (@{ $pod_list->{items}}){
			$secret->{apiVersion} = $pod_list->{apiVersion};
			push @secrets, $self->create_resource_object($secret, 'Secret');
		}
		return wantarray ? @secrets : \@secrets;
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

return 42;