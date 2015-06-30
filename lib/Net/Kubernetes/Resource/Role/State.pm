package Net::Kubernetes::Resource::Role::State;
# ABSTRACT: Resource role for types that have a status

use Moose::Role;

has status => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

=method refresh

Retrieve current state information from kubernetes.

=cut

sub refresh {
	my($self) = @_;
	my($res) = $self->ua->request($self->create_request(GET => $self->path));
	if ($res->is_success) {
		my($data) = $self->json->decode($res->content);
		$self->status($data->{status});
		return 1;
	}
	return 0;
}

return 42;