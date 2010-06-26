package DateTime::Helpers;
BEGIN {
  $DateTime::Helpers::VERSION = '0.57';
}

use strict;
use warnings;

use Scalar::Util ();

sub can {
    my $object = shift;
    my $method = shift;

    return unless Scalar::Util::blessed($object);
    return $object->can($method);
}

sub isa {
    my $object = shift;
    my $method = shift;

    return unless Scalar::Util::blessed($object);
    return $object->isa($method);
}

1;

# ABSTRACT: Helper functions for other DateTime modules



=pod

=head1 NAME

DateTime::Helpers - Helper functions for other DateTime modules

=head1 VERSION

version 0.57

=head1 AUTHOR

  Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2010 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0

=cut


__END__

