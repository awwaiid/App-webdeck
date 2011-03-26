package App::WebDeck::SimpleRoute;

=head1 NAME

SimpleRoute - Minimalist path matching and routing

=head1 SYNOPSIS

  use SimpleRoute;

  my $path = shift @ARGV;

  route $path => [

    '/'                  => sub { say "Index!" },

    '/comment'           => sub { say "Adding a comment..." },

    # Now let's get fancy
    '/blog/:year/:month' => [ year => qr/\d{4}/, month => qr/\d{2}/ ] => sub {
      say "Blog posts from $+{year}/$+{month}";
    },

    # And a default
    '.*' => sub { say "Gimme something I can use!" },
  ];

=cut

use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw( route );

sub route {
  my $path = shift;
  my $routes = shift;
  while(my $route = shift @$routes) {
    my $action = shift @$routes;
    my $validation = {};
    if(ref $action eq 'ARRAY') {
      $validation = { @$action };
      $action = shift @$routes;
    }
    $route =~ s/:(\w+)/(?<$1>[^\/]+)/g;
    # Should we care about trailing /? We'll allow it for now...
    if($path =~ /^$route\/?$/) {
      my (%matches) = (%+);
      if( !%$validation
          || all { defined $matches{$_} && $matches{$_} =~ /$validation->{$_}/ }
            keys %$validation) {
        $path =~ /^$route\/?$/; # Re-fix %+
        $_ = { %matches };
        $action->(%matches);
        last;
      } else {
        # Validation failed :(
      }
    }
  }
}

1;

