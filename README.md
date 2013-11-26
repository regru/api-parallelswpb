NAME
    API::ParallelsWPB - client for Parallels Presence Builder API

SYNOPSYS
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

METHODS
    new($class, %param)
        Creates new client instance.

        Required parameters: username password server

        Optional parameters:

            api_version - API version, used in API url constructing.
            debug - debug flag, requests will be loogged to stderr
            timeout - connection timeout

    f_request($self, $url_array_ref, $data)
        "Free" request. Now for internal usage only.

        $data: req_type : HTTP request type: get, post, put, delete. GET by
        default. post_data: data for POST request. Must be hashref.

SEE ALSO
    <a href="http://download1.parallels.com/WPB/Doc/11.5/en-US/online/presence-builder-standalone-installation-administration-guide">Parallels Presence Builder Guide</a>

AUTHORS
    Alexander Ruzhnikov, "<a.ruzhnikov@reg.ru>"

    Polina Shubina, "<shubina@reg.ru>"

LICENSE AND COPYRIGHT
    This software is copyright (c) 2013 by REG.RU LLC.

    This is free software; you can redistribute it and/or modify it under
    the same terms as the Perl 5 programming language system itself.

