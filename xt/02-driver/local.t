use Test;
use MIME::Base64;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::Tag-Name;

use WebDriver2::Test;
use WebDriver2::Test::Config-From-File;

my IO::Path $html-file =
		.add: 'test.html' with $*PROGRAM.parent.parent.add: 'content';

class Local does WebDriver2::Test does WebDriver2::Test::Config-From-File {
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
		$.driver.set-window-rect( 1200, 750, 8, 8 ) if $.browser eq 'safari';
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

		$el = self.element-by-id: 'inner';
		my Str $page-ul-text = $el.text;

		is $el.id, 'inner', 'id set on element correctly';

		$el = self.element-by-id: 'cb';

		is $el.tag-name.lc, 'input', 'cb tag is "input"';
		ok $el.property( 'checked' ), 'page cb is checked';

		$el = self.element-by-id: 'text' ;

		nok $el.value, 'page textbox starts empty';

		$el.send-keys: 'page test';

		is $el.value, 'page test', 'page textbox received text';

		$.driver.top;

		$el = self.element-by-id: 'iframe';
		$el.frame.switch-to;
		$el = self.element-by-id: 'inner';
		my Str $frame-ul-text = $el.text;

		isnt $frame-ul-text, $page-ul-text, 'inner ul != outer ul';

		$el = self.element-by-id: 'iframe-cb';

		nok $el.property( 'checked' ), 'frame cb not checked';

		$el = self.element-by-id: 'text';

		nok $el.value, 'textbox starts empty';

		$el.send-keys: 'test';

		is $el.value, 'test', 'textbox received text';

		$el.clear;

		nok $el.value, 'textbox cleared';

		$el.send-keys: "\xe004";

		ok
			( $.driver.active ~~ self.element-by-id: 'iframe-cb' ),
			'active matches';

		$.driver.switch-to-parent;

		$el = self.element-by-id: 'li3-2';

		is
				$el.css-value( 'font-weight' ),
				'700', # $!browser eq 'safari' ?? 'bold' !! '700',
				'inherited font weight';

		$el = self.element-by-id: 'disabled';

		nok $el.enabled, 'disabled cb not enabled';

		$el = self.element-by-id: 'cb';

		ok $el.property( 'checked' ), 'page cb still checked';

		ok $el.enabled, 'normal cb enabled';

		$el = self.element-by-id: 'text';

		is $el.value, 'page test', 'page text is still "page test"';

		$.driver.switch-to(0);
		$el = self.element-by-id( 'iframe-cb' );

		nok $el.property( 'checked' ), 'frame cb still not checked';

		$.driver.top;

		$el = self.element-by-id: 'toggle';

		nok $el.property( 'checked' ), 'toggle starts off';

		nok $el.selected, 'toggle starts unselected';

		$el.click;

		ok $el.selected, 'toggle selected after click';

		ok $el.property( 'checked' ), 'toggle checked after click';

		my WebDriver2::Model::Element @el = $.driver.elements: $locator;

		is @el.elems, 5, 'all lis';

		is .tag-name.lc, 'li', 'li is li' for @el[*];

		@el = self.element-by-id( 'inner' ).elements: $locator;

		is @el.elems, 2, 'inner lis';

		is .tag-name.lc, 'li', 'li is li' for @el[*];
		if $!screenshot {
			my $screenshot = $.driver.screenshot;

			IO::Path.new( 'window.png' ).spurt: MIME::Base64.decode: $screenshot;

			$screenshot = self.element-by-tag( 'ul' ).screenshot;

			IO::Path.new( 'element.png' ).spurt: MIME::Base64.decode: $screenshot;
		}

		$el = self.element-by-id: 'button';
		my @args = 0, $el.rect.<y>;
		$.driver.execute-script: 'window.scrollBy(0, arguments[1])', @args;

		$el.click;
		sleep 1;
		is $.driver.alert-text, 'hello', 'input submit button onclick triggers js';
		$.driver.accept-alert;
		sleep 1;
		is $.driver.alert-text, 'submit', 'triggered js calls submit';
		$.driver.accept-alert;
		sleep 1;
		is $.driver.alert-text, 'onsubmit', 'form submission triggers onsubmit';
		$.driver.accept-alert;
		sleep 3;
		is $.driver.title, 'Google', 'submitted';
	}
	method element-by-tag( Str $tag-name ) {
		$.driver.element( WebDriver2::Command::Element::Locator::Tag-Name.new: $tag-name )
	}

	method element-by-id( Str $id ) {
		$.driver.element( WebDriver2::Command::Element::Locator::ID.new: $id )
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Local.new: $browser, :$debug;
}
