# NAME

API::ParallelsWPB - client for Parallels Presence Builder API

# SYNOPSYS

```perl
my $client = API::ParallelsWPB->new(username => 'admin', password => 'passw0rd', server => 'builder.server.mysite.ru');
my $response = $client->get_sites_info;
if ($response->success) {
    for my $site (@{$response->response}) {
        say "UUID: ". $site->{ uuid };
    }
}
else {
    warn "Error occured: " . $response->error . ", Status: " . $response->status;
}
```

# SEE ALSO
   
[Parallels Presence Builder Guide](http://download1.parallels.com/WPB/Doc/11.5/en-US/online/presence-builder-standalone-installation-administration-guide)

# AUTHORS

- Alexander Ruzhnikov, "<a.ruzhnikov@reg.ru>"

- Polina Shubina, "<shubina@reg.ru>"

# LICENSE AND COPYRIGHT

This software is copyright (c) 2013 by REG.RU LLC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

