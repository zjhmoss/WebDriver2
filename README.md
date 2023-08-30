# WebDriver2

WebDriver level 2 bindings implementing
[W3C's specification](https://www.w3.org/TR/webdriver/).
Current implementation status is
[documented below](#implementation-status).

## Usage

### Using a driver directly

To use a driver directly for all [endpoint commands](#implementation-status), create a
test class that extends `WebDriver2::Test`.  The test class
will need to specify the browser and debug level upon
instantiation:

```perl6
use Test;
use WebDriver2::Test;

my IO::Path $html-file =
		.add: 'test.html' with $*PROGRAM.parent.parent.add: 'content';

class Local does WebDriver2::Test {
	has Bool $!screenshot;
	
	method new ( Str $browser? is copy, Int:D :$debug = 0 ) {
		self.set-from-file: $browser; #, $debug;
		my Local:D $self =
				self.bless:
						:$browser,
						:$debug,
						plan => 39,
						name => 'local',
						description => 'local test';
		$self.init;
		$self;
	}
	
	method test {
		$.driver.navigate: 'file://' ~ $html-file.absolute;
		
		is $.driver.title, 'test', 'page title';
		
		ok
				self.element-by-id( 'outer' )
						~~ self.element-by-tag( 'ul' ),
				'same element found different ways';
		
		my WebDriver2::Command::Element::Locator $by-tag-ul =
				WebDriver2::Command::Element::Locator::Tag-Name.new: 'ul';
		my WebDriver2::Model::Element $el = $.driver.element: $by-tag-ul;
		nok $el ~~ $el.element( $by-tag-ul ), 'different elements';
		
		my WebDriver2::Command::Element::Locator $locator =
				WebDriver2::Command::Element::Locator::Tag-Name.new: 'li';
		$el = $.driver.element: $locator;
		my Str $outer-li = $el.text;
		my Str $inner-li =
				self.element-by-id( 'inner' ).element( $locator ).text;
		
		isnt $inner-li, $outer-li, 'inner li != outer li';
		
		# test continues ...
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

### Defining a site's pages and the services they provide

A simple page description language is defined in the
[page grammar file](lib/WebDriver2/SUT/Build/Page.rakumod).

For a multi-page site, e.g., with a login page and a
main page with an iframe, in addition to the html
files, a "system under test" definition,
which could optionally be split into multiple `.page`
files, and `.service` definitions are needed.

For example, for

`doc-site.sut`
```
#include 'doc-login.page'
#include 'doc-main.page'
```
\
\
`doc-login.html`
```html
<html>
	<head><title>start page</title></head>
	<body>
		<form action="doc-main.html">
			<input type="text" id="user" name="user"/>
			<input type="text" id="pass" name="pass"/>
			<button name="k" value="v">log in</button>
		</form>
	</body>
</html>
```
\
`doc-login.page`
```
page doc-login 'file://relative/path/to/doc-login.html' {
	elemt username id 'user';
	elemt password id 'pass';
	elemt login-button tag-name 'button';
}
```
\
`doc-login.service`
```
#page: doc-login

username: /username
password: /password
login-button: /login-button
```
\
\
`doc-main.html`
```html
<html>
	<head><title>simple example</title></head>
	<body>
		<h1>simple example</h1>
		<p id="before">text</p>
		<form><input type="text" value="main-1"/></form>
		<iframe src="doc-frame.html"></iframe>
		<form><input type="text" value="main-2"/></form>
		<p>other content</p>
		<form><input type="text" value="main-3"/></form>
		<form><input type="text" value="main-4"/></form>
		<p id="after">more text</p>
	</body>
</html>
```
\
`doc-main.page` - with only content we're interested in outlined
```
page doc-main 'file://relative/path/to/doc-main.html' {
	elemt heading tag-name 'h1';
	elemt first-para id 'before';
#include 'doc-frame.page'
list of
#include 'doc-form.page'
	elemt last-para id 'after';
}
```
\
`doc-main.service`
```
#page: doc-main

heading: /heading
pf: /first-para
iframe: /iframe
form: /form
pl: /last-para
```
\
\
`doc-frame.html`
```html
<html>
	<head><title>iframe</title></head>
	<body>
		<form><input type="text" value="head"/></form>
		<ul>
			<li>
				<ol>
					<li>Mirzakhani</li>
					<li>Noether</li>
					<li>Oh</li>
				</ol>
			</li>
			<li>
				<ol>
					<li>Delta</li>
					<li>Echo</li>
					<li>Foxtrot</li>
				</ol>
			</li>
			<li>
				<ol>
					<li>apple</li>
					<li>banana</li>
					<li>cantaloupe</li>
				</ol>
			</li>
		</ul>
		<div><form><input type="text" value="foot"/></form></div>
	</body>
</html>
```
\
`doc-frame.page` - again, only content we're interested in is outlined
```
frame iframe tag-name 'iframe' {
#include 'doc-form.page'
	list of elgrp outer xpath '*/ul/li' {
		list of elemt inner xpath 'ol/li';
	}
	elgrp div tag-name 'div' {
#include 'doc-form.page'
	}
}
```
\
`doc-frame.service`
```
#page: doc-main

iframe: /iframe

outer: /iframe/outer
inner: /iframe/outer/inner
```
\
\
if identical content exists in multiple parts of the SUT ( e.g.,
calendar widgets ), it can be defined once and included in those parts by
specifying a prefix

`doc-form.page`
```
elgrp form xpath 'form' {
	elemt input tag-name 'input';
}
```
\
`doc-form.service`
```
#page: doc-main

form: /form
input: /form/input
```
\
\
script with supporting code:

```perl6
use Test;

use lib <lib t/lib>;

use WebDriver2::Test::Template;
use WebDriver2::Test::Service-Test;
use WebDriver2::SUT::Service::Loader;
use WebDriver2::SUT::Service;
use WebDriver2::SUT::Tree;

class Login-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-login';
	
	my IO::Path $html-file =
			.add: 'doc-login.html'
	with $*PROGRAM.parent.parent.add: 'content';
	
	my WebDriver2::SUT::Tree::URL $url =
			WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file.Str;
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method log-in ( Str:D $username, Str:D $password ) {
		$!driver.navigate: $url.Str;
		.resolve.send-keys: $username with self.get: 'username';
		.resolve.send-keys: $password with self.get: 'password';
		.resolve.click with self.get: 'login-button';
	}
}

class Main-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-main';
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method question ( --> Str:D ) {
		.resolve.text with self.get: 'question';
	}
	
	method interesting-text ( --> Str:D ) {
		my Str @text;
		@text.push: .resolve.text with self.get: 'heading';
		@text.push: .resolve.text with self.get: 'pf';
		@text.push: .resolve.text with self.get: 'pl';
		@text.join: "\n";
	}


}

class Form-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-form';
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver, Str:D :$!prefix = '' ) { }
	
	method value ( --> Str:D ) {
		.resolve.value with self.get: 'input';
	}
	method first ( &cb ) {
		for self.get( 'form' ).iterator {
			return self if &cb( self );
		}
		return Form-Service;
	}
	method each ( &action ) {
		for self.get( 'form' ).iterator {
			&action( self );
		}
	}
}

class Frame-Service does WebDriver2::SUT::Service {
	has Str:D $.name = 'doc-frame';
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
	
	method each-outer ( &cb ) {
		for self.get( 'outer' ).iterator {
			&cb( self );
		}
	}
	
	method each-inner ( &cb ) {
		for self.get( 'inner' ).iterator {
			&cb( self );
		}
	}
	
	method item-text ( --> Str:D ) {
		.resolve.text with self.get: 'inner';
	}
}

class Readme-Test
		does WebDriver2::Test::Service-Test
		does WebDriver2::Test::Template
{
	has Login-Service $!ls;
	has Main-Service $!ms;
	has Form-Service $!fs-main;
	has Form-Service $!fs-div;
	has Form-Service $!fs-frame;
	has Frame-Service $!frs;
	
	submethod BUILD (
			Str   :$!browser,
			Str:D :$!name,
			Str:D :$!description,
			Str:D :$!sut-name,
			Int   :$!plan,
			Int   :$!debug = 0
					 ) { }
	
	submethod TWEAK (
			Str:D :$sut-name,
			Int   :$debug
					 ) {
		$!sut = WebDriver2::SUT::Build.page: { self.driver.top }, $!sut-name, debug => self.debug;
		$!loader =
				WebDriver2::SUT::Service::Loader.new:
						driver => self.driver,
						:$!browser,
						:$sut-name,
						:$debug;
	}
	
	method new ( Str $browser is rw, Int $debug = 0 ) {
		my $self = self.bless:
				:$browser,
				:$debug,
				sut-name => 'doc-site',
				name => 'readme example',
				description => 'service / page object example',
				plan => 26;
		$self.init;
		$self.services;
		$self;
	}
	
	method services {
		$!loader.load-elements: $!ls = Login-Service.new: :$.driver;
		$!loader.load-elements: $!ms = Main-Service.new: :$.driver;
		
		$!loader.load-elements: $!fs-main = Form-Service.new: :$.driver, prefix => '/';
		$!loader.load-elements: $!fs-frame = Form-Service.new: :$.driver, prefix => '/iframe';
		$!loader.load-elements: $!fs-div = Form-Service.new: :$.driver, prefix => '/iframe/div';
		
		$!loader.load-elements: $!frs = Frame-Service.new: :$.driver;
	}
	
	method test {
		$!ls.log-in: 'user', 'pass';
		
		self.is: 'sub xpath', 'subelement test', .resolve.text with $!ms.get: 'subelement';
		
		self.is:
				'interesting text',
				q:to /END/.trim,
				simple example
				text
				more text
				END
				$!ms.interesting-text;
		
		my Str:D @results =
				'Mirzakhani',
				'Noether',
				'Oh',
				'Delta',
				'Echo',
				'Foxtrot',
				'apple',
				'banana',
				'cantaloupe',
				;
		my Int $els = 9;
		my Bool:D $list-seen = False;
		$!frs.each-outer: {
			$list-seen = True;
			self.is: "correct number of elements left", $els, @results.elems;
			$!frs.each-inner: {
				self.is: "correct inner element : @results[0]", @results.shift,
						.item-text;
			}
			$els -= 3;
		}
		self.ok: 'outer', $list-seen;
		self.is: '$els decremented', 0, $els;
		self.is: '@results empty', 0, @results.elems;
		
		@results = 'main-1', 'main-2', 'main-3', 'main-4';
		
		$!fs-main.each: { self.is: 'correct form element', @results.shift, .value };
		self.is: '@results empty', 0, @results.elems;
		
		self.is: 'first frame form is head', 'head', $!fs-frame.value;
		self.is: 'main page form', 'main-1', $!fs-main.first( { True; } ).value;
		self.is: 'final frame form is foot', 'foot', $!fs-div.value;
	}
}

sub MAIN(
		Str:D $browser is copy = 'chrome',
		Int :$debug = 0
) {
	.execute with Readme-Test.new: $browser, $debug;
}
```



Extended examples can be seen in the `xt/02-driver` (direct driver use) 
and the `xt/03-service` (page definition and service use) subdirectories, which
use resources from `xt/content` and `xt/def`.



## HTTP::UserAgent

A minor fork of HTTP::UserAgent is provided under the
WebDriver2 directory.  Please see its license:
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

### Implementation Status

<table><tbody>
	<tr class="os">
		<th>&nbsp;</th>
		<th class="browser" colspan="3">Windows</th>
		<th class="browser">MacOS</th>
		<th>&nbsp;</th>
	</tr>
	<tr class="header">
		<th>endpoint</th>
		<th class="browser">chrome</th>
		<th class="browser">edge</th>
		<th class="browser">firefox</th>
		<th class="browser">safari</th>
		<th>method</th>
	</tr>
	<tr><td >new session</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.session</code></td>
	</tr>
	<tr><td>delete session</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.delete-session</code></td>
	</tr>
	<tr><td>status</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.status</code></td>
	</tr>
	<tr><td>get timeouts</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>set timeouts</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.timeouts ( Int $script, Int $page-load, Int $implicit )</code></td>
	</tr>
	<tr><td>navigate to</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.navigate ( Str $url )</code></td>
	</tr>
	<tr><td>get current url</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$driver.url</code></td>
	</tr>
	<tr><td>back</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>forward</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>refresh</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>get title</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.title</code></td>
	</tr>
	<tr><td>get window handle</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$driver.window-handle</code></td>
	</tr>
	<tr><td>close window</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.close-window</code></td>
	</tr>
	<tr><td>switch to window</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$driver.switch-to-window ( $handle )</code></td>
	</tr>
	<tr><td>get window handles</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.window-handles</code></td>
	</tr>
	<tr><td>new window</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$driver.new-window</code></td>
	</tr>
	<tr><td>switch to frame</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.switch-to ( Int $frame-id )</code>
			<code>$frame-element.switch-to</code>
		</td>
	</tr>
	<tr><td>switch to parent frame</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.switch-to-parent</code>
			<code>$element.switch-to-parent</code>
		</td>
	</tr>
	<tr><td>get window rect</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>set window rect</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.set-window-rect (
			Int $width, Int $height, Int $x, Int $y
		)</code></td>
	</tr>
	<tr><td>maximize window</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code>$driver.maximize-window</code></td>
	</tr>
	<tr><td>minimize window</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>fullscreen window</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>get active element</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.active</code></td>
	</tr>
	<tr><td>get element shadow root</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>find element</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.element ( Locator $loc )</code></td>
	</tr>
	<tr><td>find elements</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.elements ( Locator $loc )</code></td>
	</tr>
	<tr><td>find element from element</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.element ( Locator $loc )</code></td>
	</tr>
	<tr><td>find elements from element</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.elements ( Locator $loc )</code></td>
	</tr>
	<tr><td>find element from shadow root</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>find elements from shadow root</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>is element selected</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.selected</code></td>
	</tr>
	<tr><td>get element attribute</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.attribute</code></td>
	</tr>
	<tr><td>get element property</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.property</code></td>
	</tr>
	<tr><td>get element css value</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.css-value ( Str $css-prop )</code></td>
	</tr>
	<tr><td>get element text</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.text</code></td>
	</tr>
	<tr><td>get element tag name</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.tag-name</code></td>
	</tr>
	<tr><td>get element rect</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>is element enabled</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.enabled</code></td>
	</tr>
	<tr><td>get computed role</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>get computed label</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>element click</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.click</code></td>
	</tr>
	<tr><td>element clear</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.clear</code></td>
	</tr>
	<tr><td>element send keys</td>
		<td align="center" class="partial">/</td>
		<td align="center" class="partial">/</td>
		<td align="center" class="partial">/</td>
		<td align="center" class="partial">/</td>
		<td><code>$element.send-keys ( $text )</code></td>
	</tr>
	<tr><td>get page source</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>execute script</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.execute-script ( Str $scr, @args )</code></td>
	</tr>
	<tr><td>execute async script</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>get all cookies</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>get named cookie</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>add cookie</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>delete cookie</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>delete all cookies</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>perform actions</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>release actions</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>dismiss alert</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.dismiss-alert</code></td>
	</tr>
	<tr><td>accept alert</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.accept-alert</code></td>
	</tr>
	<tr><td>get alert text</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.alert-text</code></td>
	</tr>
	<tr><td>send alert text</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.send-alert-text ( Str $text )</code></td>
	</tr>
	<tr><td>take screenshot</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$driver.screenshot</code></td>
	</tr>
	<tr><td>take element screenshot</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td><code>$element.screenshot</code></td>
	</tr>
	<tr><td>print page</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td align="center" class="not-started">&nbsp;</td>
		<td><code></code></td>
	</tr>
	<tr><td>displayed ( optional endpoint )</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="complete">X</td>
		<td align="center" class="not-started">! apple does not implement</td>
		<td><code>$element.displayed</code></td>
	</tr>
</tbody></table>
