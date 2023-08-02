use v6;

use Test;

use lib 'lib', 't/lib';

use WebDriver2::Mock-Driver;
use WebDriver2::SUT::Build;
use WebDriver2::SUT::Navigator;
use WebDriver2::SUT::Tree;
use WebDriver2::Command::Element::Locator;

class Test-Observer
		does WebDriver2::SUT::Tree::Observer
		does WebDriver2::SUT::Tree::Visitor
{
	has Str @!path is required;
	submethod BUILD( Str :@!path ) { }
	method exit-element { }
	method exit-frame { }
	method exit-page { }
	method update ( WebDriver2::SUT::Tree::Subject:D $subject ) {
		is $subject.name, @!path.shift, 'notified';
	}
	method visit-page ( WebDriver2::SUT::Tree::Page $page ) {
		$page.add-observer: self;
	}
	method visit-frame ( WebDriver2::SUT::Tree::Frame $frame ) {
		$frame.add-observer: self;
	}
	method visit-element ( WebDriver2::SUT::Tree::Element $element ) {
		$element.add-observer: self;
	}
	method visit-depth-page ( WebDriver2::SUT::Tree::Page $page ) { }
	method visit-depth-frame ( WebDriver2::SUT::Tree::Frame $frame ) { }
	method visit-depth-element ( WebDriver2::SUT::Tree::Element $element ) { }
}

sub MAIN(
		Bool :$check = False,
		Int :$debug = 0
) {
	my WebDriver2::SUT::Tree::SUT $sut =
			WebDriver2::SUT::Build.page:
					{ WebDriver2::Mock-Driver.new },
					'test', # $*PROGRAM.parent.parent.add( 'def' ).add( 'test.page' ),
					:!check,
					:$debug;

	return 0 if $check;

	my Str @nav-seq = <
			outer li3 inner li3-2
			inner li3 outer /
			form iframe outer li3 inner li3-1
			inner li3 outer iframe form text
			form iframe form /
			form iframe
	>;

	my Test-Observer $observer = Test-Observer.new: path => @nav-seq;
	my WebDriver2::SUT::Tree::Page $page = $sut.get: 'test';
	dies-ok { $page.parent = WebDriver2::SUT::Tree::Page.new },
			'can\'t modify parent';
	$page.accept: $observer;

	my WebDriver2::SUT::Navigator $nav = WebDriver2::SUT::Navigator.new: tree => $page, :$debug;
	$nav.traverse: 'outer/li3/inner/li3-2';
	# diag 'traverse to page leaf done';
	$nav.traverse;
	# diag 'traverse to root done';
	$nav.traverse: 'form/iframe/outer/li3/inner/li3-1';
	# diag 'traverse to frame leaf done';
	$nav.traverse: '../../../../form/text';
	# diag 'traverse to frame text done';
	$nav.traverse;
	# diag 'traverse to root done';
	$nav.traverse: '/form/iframe';
	# diag 'rooted traverse to iframe from root done';

	my WebDriver2::SUT::Tree::AFrame @frames = $nav.frames;

	is @frames.elems, 2, 'all frames returned';
	is @frames[0].name, '/', 'bottom frame is /';
	is @frames[1].name, 'iframe', 'iframe';

	done-testing;
}
