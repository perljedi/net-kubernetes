package Net::Kubernetes::Resource;

use Moose;

=head1 NAME

Net::Kubernetes::Resource

Base class for all Net::Kubernetes::Resource objects.

=cut

with 'Net::Kubernetes::Role::APIAccess';


has kind     => (
	is       => 'ro',
	isa      => 'Str',
	required => 0,
);

has api_version => (
	is       => 'ro',
	isa      => 'Str',
	required => 0,
);

has metadata => (
	is       => 'rw',
	isa      => 'HashRef',
	required => 1
);

=head1 Methods

=over 1

=item $resource->delete

=item $resource->update (send local changes to api server)

=item $resource->refresh (update object from api server)

This method is only available for resources which have a status (currently everything
other than secrets).

=back

=cut

sub delete {
	my($self) = @_;
	my($res) = $self->ua->request($self->create_request(DELETE => $self->path));
	if ($res->is_success) {
		return 1;
	}
	return 0;
}

sub update {
	my($self) = @_;
	my($res) = $self->ua->request($self->create_request(PUT => $self->path, undef, $self->json->encode($self->as_hashref)));
	if ($res->is_success) {
		return 1;
	}
	return 0;
}

sub as_hashref
{
	my($self) = @_;
	return {
		inner(),
		apiVersion=>$self->api_version,
		kind=>$self->kind,
		metadata=>$self->metadata
	};
}


return 42;