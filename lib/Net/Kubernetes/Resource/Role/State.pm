package Net::Kubernetes::Resource::Role::State;

use Moose::Role;

=head1 NAME

Net::Kubernetes::Resource::Role::State

Role for resource objects which have "state"

=cut


has status => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

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