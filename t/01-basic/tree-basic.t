use v6;

use Test;

use lib 'lib', 't/lib';

use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Navigator;
use WebDriver2::Mock-Driver;
use WebDriver2;

class Test-Observer does WebDriver2::SUT::Tree::Observer {
	has Str @!path is required;
	submethod BUILD( Str :@!path ) { }
	method update ( WebDriver2::SUT::Tree::Subject:D $subject ) {
		is $subject.name, @!path.shift, 'notified';
	}
}

sub MAIN( Int :$debug = 0 ) {
	plan 20;
	my Str @nav-seq = <
			form1 outer form2 inner form3 input
			form3 inner form2 outer form1 /
			form1 outer form2 inner
	>;
	my WebDriver2 $driver =  WebDriver2::Mock-Driver.new;
	my Test-Observer $observer = Test-Observer.new: path => @nav-seq;
	my WebDriver2::SUT::Tree::URL $url =
			WebDriver2::SUT::Tree::URL.new: 'file://t/content/test.html';
	my WebDriver2::SUT::Tree::ANode $root =
			WebDriver2::SUT::Tree::Page.new: :$url, id => '/', :$driver;
	dies-ok { $root.parent = WebDriver2::SUT::Tree::Page.new: $driver },
			'can\'t modify parent';
	$root.add-observer: $observer;
	my WebDriver2::SUT::Tree::ANode $node =
			WebDriver2::SUT::Tree::Element.new: name => 'form1';
	$node.add-observer: $observer;
	$root.add: $node;
	$node.add: WebDriver2::SUT::Tree::Frame.new: name => 'outer';
	$node .= get: 'outer';
	$node.add-observer: $observer;
	$node.add: WebDriver2::SUT::Tree::Element.new: name => 'form2';
	$node .= get: 'form2';
	$node.add-observer: $observer;
	$node.add: WebDriver2::SUT::Tree::Frame.new: name => 'inner';
	$node .= get: 'inner';
	$node.add-observer: $observer;
	$node.add: WebDriver2::SUT::Tree::Element.new: name => 'form3';
	$node .= get: 'form3';
	$node.add-observer: $observer;
	$node.add: WebDriver2::SUT::Tree::Element.new: name => 'input';
	$node .= get: 'input';
	$node.add-observer: $observer;

	my WebDriver2::SUT::Navigator $nav = WebDriver2::SUT::Navigator.new: tree => $root, :$debug;
	$nav.traverse: 'form1/outer/form2/inner/form3/input';
	# diag 'traverse to leaf done';
	$nav.traverse;
	# diag 'traverse to root done';
	$nav.traverse: 'form1/outer/form2/inner';
	# diag 'traverse to inner done';

	my WebDriver2::SUT::Tree::AFrame @frames = $nav.frames;

	is @frames[0].name, '/', 'bottom frame is /';
	is @frames[1].name, 'outer', 'outer frame';
	is @frames[2].name, 'inner', 'inner frame';

	done-testing;
}
