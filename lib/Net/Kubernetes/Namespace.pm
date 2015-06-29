package Net::Kubernetes::Namespace;

use Moose;
use MooseX::Aliases;
use syntax 'try';

=head1 NAME

Net::Kubernetes::Namespace

Provides access to kubernetes respources within a single namespace.

=cut


has namespace => (
	is       => 'ro',
	isa      => 'Str',
	required => 0,	
);

has _namespace_data => (
	is       => 'ro',
	isa      => 'HashRef',
	required => 0,
);

with 'Net::Kubernetes::Role::APIAccess';
with 'Net::Kubernetes::Role::ResourceLister';
with 'Net::Kubernetes::Role::ResourceCreator';
with 'Net::Kubernetes::Role::ResourceFactory';


=head1 Methods

=over 1

=item $ns->list_pods([label=>{label=>value}], [fields=>{field=>value}])

=item $ns->list_rc([label=>{label=>value}], [fields=>{field=>value}])

=item $ns->list_replication_controllers([label=>{label=>value}], [fields=>{field=>value}]) (alias to list_rc)

=item $ns->list_secrets([label=>{label=>value}], [fields=>{field=>value}])

=item $ns->list_services([label=>{label=>value}], [fields=>{field=>value}])

=item my $resource = $ns->create({OBJECT})

=item my $resource = $ns->create_from_file(PATH_TO_FILE) (accepts either JSON or YAML files)

=item $ns->get_pod('my-pod-name')

=item $ns->get_repllcation_controller('my-rc-name') (aliased as $ns->get_rc('my-rc-name'))

=item $ns->get_service('my-servce-name')

=item $ns->get_secret('my-secret-name')

=back

=cut

sub get_secret {
	my($self, $name) = @_;
	Net::Kubernetes::Exception->throw(message=>"Missing required parameter 'name'") if(! defined $name || ! length $name);
	return $self->get_resource_by_name($name, 'secrets');
}

sub get_pod {
	my($self, $name) = @_;
	Net::Kubernetes::Exception->throw(message=>"Missing required parameter 'name'") if(! defined $name || ! length $name);
	return $self->get_resource_by_name($name, 'pods');
}

sub get_service {
	my($self, $name) = @_;
	Net::Kubernetes::Exception->throw(message=>"Missing required parameter 'name'") if(! defined $name || ! length $name);
	return $self->get_resource_by_name($name, 'services');
}

sub get_replication_controller {
	my($self, $name) = @_;
	Net::Kubernetes::Exception->throw(message=>"Missing required parameter 'name'") if(! defined $name || ! length $name);
	return $self->get_resource_by_name($name, 'replicationcontrollers');
}
alias get_rc => 'get_replication_controller';


sub get_resource_by_name {
	my($self, $name, $type) = @_;
	my($res) = $self->ua->request($self->create_request(GET => $self->path.'/'.$type.'/'.$name));
	if ($res->is_success) {
		return $self->create_resource_object($self->json->decode($res->content));
	}
	else {
		my $message;
		try{
			my $obj = $self->json->decode($res->content);
			$message = $obj->{message};
		}
		catch($e) {
			$message = $res->message;
		}
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$message);
	}
}