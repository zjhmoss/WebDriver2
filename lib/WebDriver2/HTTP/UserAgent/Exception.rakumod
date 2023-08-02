module WebDriver2::HTTP::UserAgent::Exception {
    use WebDriver2::HTTP::Message;

    class X::HTTP is Exception {
        has $.rc;
        has WebDriver2::HTTP::Message $.response;
    }

    class X::WebDriver2::HTTP::Internal is Exception {
        has $.rc;
        has $.reason;

        method message {
            "Internal Error: '$.reason'";
        }
    }

    class X::WebDriver2::HTTP::Response is X::HTTP {
        has $.message;
        method message {
            $!message //= "Response error: '$.rc'";
        }
    }

    class X::WebDriver2::HTTP::Server is X::HTTP {
        method message {
            "Server error: '$.rc'";
        }
    }

    class X::WebDriver2::HTTP::Header is X::WebDriver2::HTTP::Server {
    }

    class X::WebDriver2::HTTP::ContentLength is X::WebDriver2::HTTP::Response {
    }

    class X::WebDriver2::HTTP::NoResponse is X::WebDriver2::HTTP::Response {
        has $.message = "missing or incomplete response line";
        has $.got;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
