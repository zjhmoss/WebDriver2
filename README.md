# WebDriver2

WebDriver level 2 bindings implementing
[W3C's specification](https://www.w3.org/TR/webdriver/).
Current implementation status is documented in
[doc/doc.html](doc/doc.html).

## Usage

### Defining a site's pages and the services they provide

A simple page description language is defined in the
[page grammar file](lib/WebDriver2/SUT/Build/Page.rakumod).
Examples can be seen in the `xt/03-sut` subdirectory, which
use resources from `xt/content` and `xt/def`.



### Using a driver directly

To use a driver directly for all endpoint commands, create a
test class that extends `WebDriver2::Test`.  The test class
will need to specify the browser and debug level upon
instantiation:

```
use Test;
use WebDriver2::Test;

class MyTest is WebDriver2::Test {
	method new ( Str $browser, Int $debug ) {
		...
		self.bless:
			:$browser,
			:$debug,
			plan => 42,
			name => 'mytest',
			description => 'my test';
	}
}
```

`WebDriver2::Test` (indirectly) does
`WebDriver2::Test::Template`, which will call
```
method init { ... }
method pre-test { ... }
method test { ... }
method post-test { ... }
method close { ... }
method done-testing { done-testing }
method cleanup { ... }
```
when its `execute` method is called.

Before starting into the test code, `$.driver.session` needs
to be called, along with `$.driver.delete-session` after
test code has completed.  These two calls are made
automatically during `init` and `close` when extending the
provided `WebDriver2::Test`.



## HTTP::UserAgent

A minor fork of HTTP::UserAgent is provided under the
WebDriver2 directory so as to not collide with the original
and to avoid having to `use` an author-specific package.
Please see its license:
[LICENSE-HTTP-UserAgent](LICENSE-HTTP-UserAgent).

The changes are:
1. fix content length (geckodriver does not gracefully handle
incorrect content lengths)
2. increase amount of info logged (originally capped at 300
characters per entry)

## TODO

- [ ] cover all implemented endpoints with unit tests
- [ ] implement the rest of the endpoints
- [ ] page and service object features

### Feedback

Suggestions, design recommendations, and feature requests
welcome.
