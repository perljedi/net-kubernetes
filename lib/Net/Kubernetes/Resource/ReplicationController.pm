package Net::Kubernetes::Resource::ReplicationController;
# ABSTRACT: Object representatioon of a Kubernetes Replication Controller

use Moose;
use URI;
use Time::HiRes;


extends 'Net::Kubernetes::Resource';
with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';
with 'Net::Kubernetes::Resource::Role::HasPods';


=method my(@pods) = $rc->get_pods()

Fetch a list off all pods belonging to this replication controller.

=cut

sub scale {
    my($self, $replicas, $timeout) = @_;
    $timeout ||= 5;
    $self->spec->{replicas} = $replicas;
    $self->update;
    my $st = time;
    while((time - $st) < $timeout){
        my $pods = $self->get_pods;
        if(scalar(@$pods) == $replicas){
            return "scaled";
        }
        sleep(0.3);
    }
    return 0;
}

return 42;
