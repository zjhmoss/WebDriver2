use Test;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Until;
use WebDriver2::Test::Locating-Test;
use WebDriver2::Test::Template;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;
use WebDriver2::Command::Keys;

my IO::Path $html-file = .add: 'focus.html'
	with $*PROGRAM.parent.parent.add: 'content';

class Focus-Test
		does WebDriver2::Test::Template
		does WebDriver2::Test::Locating-Test
{
	has Int:D $.plan = 37;
	has Str:D $.name = 'element element state / interaction tests';
	has Str:D $.description = 'tests element state / interaction endpoints';

	method test {
		$.driver.navigate: 'file://' ~ $html-file.absolute;
		
		# active
		self.cmp-ok: 'second input starts focused', self.element-by-id( 'two' ), &[~~], $.driver.active;
		self.cmp-ok: 'first input starts blurred', self.element-by-id( 'one' ), &[!~~], $.driver.active;
		self.cmp-ok: 'third input starts blurred', self.element-by-id( 'three' ), &[!~~], $.driver.active;
		self.cmp-ok: 'second input still focused', self.element-by-id( 'two' ), &[~~], $.driver.active;
		
		$.driver.active.send-keys: "2$WebDriver2::Command::Keys::TAB";
		self.cmp-ok: 'tab to third input', self.element-by-id( 'three' ), &[~~], $.driver.active;
		self.cmp-ok: 'second input no longer focused', self.element-by-id( 'two' ), &[!~~], $.driver.active;
		
		my WebDriver2::Model::Element $el = self.element-by-id: 'two';
		self.is: 'input was received', '2', $el.value;
		
		# selected
		my WebDriver2::Model::Element @options = self.elements-by-tag: 'option';
		self.is: 'correct number of option elements', 3, @options.elems;
		self.nok: 'first option not selected', @options[0].selected;
		self.nok: 'second option not selected', @options[1].selected;
		self.ok: 'last option is selected', @options[2].selected;
		
		# click
		.click with self.element-by-tag: 'select';
		@options[0].click;
		self.ok: 'click selected', @options[0].selected;
		self.nok: 'still not selected', @options[1].selected;
		self.nok: 'no longer selected', @options[2].selected;
		
		$el = self.element-by-id: 'three';
		self.nok: 'starts unchecked', $el.selected;
		$el.click;
		self.ok: 'click marks selected', $el.selected;
		
		# enabled
		$el = self.element-by-id: 'no-text';
		self.is: 'starts empty', '', $el.value;
		self.nok: 'is disabled', $el.enabled;
		if $.browser eq 'safari' {
			$el.send-keys: 'safari';
			skip 'safari ignores interaction with disabled elements', 1;
		} else {
			self.dies-ok: 'does not accept text', { $el.send-keys: 'ignored' };
		}
		self.is: 'text still empty', '', $el.value;
		
		$el = self.element-by-id: 'no-check';
		self.nok: 'starts unchecked', $el.selected;
		self.nok: 'is disabled', $el.enabled;
		$el.click;
		self.nok: 'still unchecked', $el.selected;
		
		# attribute / property
		$el = self.element-by-css-selector: 'label > input';
		self.is: 'correct name attribute value', 'radio-group', $el.attribute: 'name';
		
		# attribute / property + clear and send keys
		$el = self.element-by-id: 'attr-prop';
		self.is: 'initial value', 'start', $el.attribute: 'value';
		self.is: 'initial value', 'start', $el.property: 'value';
		self.is: 'initial value', 'start', $el.value;
		$el.clear;
		self.is: 'initial attribute value retained', 'start', $el.attribute: 'value';
		self.is: 'property value cleared', '', $el.property: 'value';
		self.is: 'value cleared', '', $el.value;
		$el.send-keys: 'changed';
		self.is: 'initial attribute value retained', 'start', $el.attribute: 'value';
		self.is: 'property value changed', 'changed', $el.property: 'value';
		self.is: 'value changed', 'changed', $el.value;
		
		# css value
		self.is: 'italics set', 'italic', $el.css-value: 'font-style';
		
		# tag-name
		$el = self.element-by-id: 'heading';
		self.is: 'locate by id; correct tag name', 'h2', $el.tag-name.lc;
		$el = self.element-by-tag: 'h2';
		self.is: 'locate by tag; correct tag name', 'h2', $el.tag-name.lc;
		
		# text
		self.is: 'correct text retrieved', 'element state / interaction', $el.text;
	}
	
	method prep-path ( IO::Path $path ) {
		return 'file://' ~ $path.absolute if $.browser eq 'safari';
		'file:///' ~ $path.absolute.subst: '\\', '/', :g;
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Focus-Test.new: $browser, :$debug, test-root => 'xt'.IO;
}

