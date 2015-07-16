package Net::Kubernetes::Resource::Pod;
# ABSTRACT: Object representatioon of a Kubernetes Pod

use Moose;

extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';

sub logs {
	my($self) = @_;
	my $uri = URI->new($self->path.'/log');
	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		return $res->content;
	}
}

return 42;