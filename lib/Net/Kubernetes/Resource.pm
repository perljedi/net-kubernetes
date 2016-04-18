package Net::Kubernetes::Resource;
# ABSTRACT: Base class for all Net::Kubernetes::Resource objects.

use Moose;

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

=method $resource->delete

Delete this rsource.

=method $resource->update (send local changes to api server)

Saves any changes made to metadata, or spec or any other resource type specific changes
made since this item was last pulled from the server.

=method $resource->refresh

Update status information from server.  This is only available for reosurce types which have
a status field (Currently that is everything other than 'Secret' objects)

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

        # It is possible for kuberentes to churn the resource version higher even if 
        # you just refresh it and then attempt an update operation. Let's ignore it for now.
        my $metadata = $self->metadata;
        delete $metadata->{resourceVersion};
	
	return {
		inner(),
		apiVersion=>$self->api_version,
		kind=>$self->kind,
		metadata=>$self->metadata
	};
}

return 42;
