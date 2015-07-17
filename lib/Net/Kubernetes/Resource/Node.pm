package Net::Kubernetes::Resource::Node;
# ABSTRACT: Object representatioon of a Kubernetes Pod

use Moose;

extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';


return 42;