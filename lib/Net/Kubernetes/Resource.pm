package Net::Kubernetes::Resource;

use Moose;

=head1 NAME

Net::Kubernetes::Resource

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

sub delete {
	my($self) = @_;
	my($res) = $self->ua->request($self->create_request(DELETE => $self->url.'/'.$self->base_path));
	if ($res->is_success) {
		return 1;
	}
	return 0;
}


return 42;