package App::WebDeck::SimpleRoute;

=head1 NAME

App::WebDeck::SimpleRoute - Minimalist path matching and routing

=head1 SYNOPSIS

  use SimpleRoute;

  my $path = shift @ARGV;

  route $path => [

    '/'                  => sub { say "Index!" },

    '/comment'           => sub { say "Adding a comment..." },

    # Now let's get fancy. Params are in $_, @_, and %+, take your pick.
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

=head1 EXPORTS

=head2 route $path => [ ... rules ... ];

This is the only sub, and the only export. It takes two parameters -- the path that we're going to match against, and a list of rules to try.

Each rule consists of at least two parts -- a pattern, and a callback. You may optionally include an arrayref of regex validators as well.

Patterns are basically paths, but you can add named captures. Internally these are turned into plain old regexes that we match against.

Some examples:

  # Just a path and a callback
  '/comment' => sub { say "Adding a comment..." },

  # A fancier path, which has a parameter
  '/post/:postname' => sub { say "You want $_->{postname}, eh?" },

  # Super fancy -- path with params, regex validation, and the callback
  '/blog/:year/:month'
    => [ year => qr/\d{4}/, month => qr/\d{2}/ ]
    => sub { say "Blog posts from $+{year}/$+{month}" },

The named parameters can be gotten at 3 ways. Most normal-like is that they are passed through @_, like C<< callback(year => '2011', month => '02') >>. Next is that a hashref of the commands is put into $_. Finally, since we do a by-name regex match, you can get to them through %+, like C<< $+{year} >>.

Since we are really just turning the pattern into a regex, you can do any sort of regex type stuff as well. You could even ignore the :name syntax altogether if you want.

=cut

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

=head1 SEE ALSO

There are a bunch of modules just like this one but different. Miyagawa has gathered a lovely list of ones that can be used with Plack over at L< https://github.com/miyagawa/plack-dispatching-samples >. Notably, the closest to this interface is the one provided by L<Mojolicious::Lite>.

=head1 AUTHOR

  Brock Wilcox <awwaiid@thelackthereof.org> - http://thelackthereof.org/

=head1 COPYRIGHT

  Copyright (c) 2011 Brock Wilcox <awwaiid@thelackthereof.org>. All rights
  reserved. This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

=cut

1;

