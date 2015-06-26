package Net::Kubernetes::Resource::ReplicationController;

use Moose;
use URI;

=head1 NAME

Net::Kubernetes::Resource::ReplicationController

=cut

extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Role::ResourceFactory';

sub get_pods {
	my($self) = @_;
	my $uri = URI->new_abs("../pods", $self->path);
	$uri->query_form(labelSelector=>$self->_build_selector_from_hash($self->spec->{selector}));
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

sub _build_selector_from_hash {
	my($self, $select_hash) = @_;
	my(@selectors);
	foreach my $label (keys %{ $select_hash }){
		push @selectors, $label.'='.$select_hash->{$label};
	}
	return \@selectors;
}

return 42;