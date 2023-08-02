use v6;

use Test;

use lib 'lib', 't/lib';

use WebDriver2::SUT::Build;
use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Navigator;
use  WebDriver2::Mock-Driver;
use WebDriver2;

sub MAIN(
		Bool :$check = False,
		Int :$debug = 0
) {
	my WebDriver2 $driver =  WebDriver2::Mock-Driver.new;
	my IO::Path $page-def = $*PROGRAM.parent.parent.add: 'def';
	$page-def .= add: 'test.page';
	WebDriver2::SUT::Build.page: { $driver }, 'test' #`[ $page-def ], :$check, :$debug;

	my WebDriver2::SUT::Tree::URL $url =
			WebDriver2::SUT::Tree::URL.new: 'file://t/content/test.html';
	my WebDriver2::SUT::Tree::Page $root =
			WebDriver2::SUT::Tree::Page.new: :$url, id => '', :$driver;
	$root.add: WebDriver2::SUT::Tree::Element.new: name => 'grandparent';
	$root.get( 'grandparent' ).add:
			WebDriver2::SUT::Tree::Element.new: name => 'parent';
	$root.get( 'grandparent' ).get( 'parent' ).add:
			WebDriver2::SUT::Tree::Element.new: name => 'child';

	is $root.name, '/', 'root name set correctly';
	is
			$root.get( 'grandparent' ).name,
			'grandparent',
			'grandparent added correctly';
	is
			$root.get( 'grandparent' ).get( 'parent' ).name,
			'parent',
			'parent added correctly';
	is
			$root.get( 'grandparent' ).get( 'parent' ).get( 'child' ).name,
			'child',
			'child added correctly';
	is
			$root.get( 'grandparent' ).get( 'parent' ).get( 'child' )
				.parent.parent.parent.name,
			'/',
			'parents set correctly';

	my WebDriver2::SUT::Navigator::Path $path =
			WebDriver2::SUT::Navigator::Path.new: '/grandparent/parent/child';
	ok $_, 'path parts match' for $path.flat Zeq <grandparent parent child>;

	my WebDriver2::SUT::Navigator $nav = WebDriver2::SUT::Navigator.new: tree => $root, :$debug;
	is
			$nav.traverse( 'grandparent/parent/child' ).name,
			'child',
			'traversed to leaf';
	is $nav.traverse( '../../..' ).name, '/', 'traversed to root';
	is
			$nav.traverse( 'grandparent/parent' ).name,
			'parent',
			'traversed back down to parent';
	is
			$nav.traverse( '/grandparent' ).name,
			'grandparent',
			'traversed to grandparent via absolute';
	is
			$nav.traverse( 'parent/child' ).name,
			'child',
			'traversed to leaf via relative';
	is $nav.traverse.name, '/', 'traverse to root by default';



	done-testing;
}
