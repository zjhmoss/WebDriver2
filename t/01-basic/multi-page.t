use Test;

use lib 'lib', 't/lib';

use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Navigator;
use WebDriver2::SUT::Build;
use WebDriver2::Test::PO-Test;
use WebDriver2::Mock-Driver;
use WebDriver2;

class Frame-Recorder does WebDriver2::SUT::Tree::Visitor {
	has WebDriver2::SUT::Tree::AFrame @.frames;
	method exit-page { }
	method exit-frame { }
	method exit-element { }
	method visit-page ( WebDriver2::SUT::Tree::APage:D $page ) {
		@!frames.push: $page;
	}
	method visit-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) {
		@!frames.push: $frame;
	}
	method visit-element ( WebDriver2::SUT::Tree::ANode:D $element ) { }
	method visit-depth-page ( WebDriver2::SUT::Tree::APage:D $page ) { }
	method visit-depth-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) { }
	method visit-depth-element ( WebDriver2::SUT::Tree::ANode:D $element ) { }
}

class Page-Recorder does WebDriver2::SUT::Tree::Visitor {
	has WebDriver2::SUT::Tree::AFrame @.pages;
	method exit-page { }
	method exit-frame { }
	method exit-element { }
	method visit-page ( WebDriver2::SUT::Tree::APage:D $page ) {
		@!pages.push: $page;
	}
	method visit-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) { }
	method visit-element ( WebDriver2::SUT::Tree::ANode:D $element ) { }
	method visit-depth-page ( WebDriver2::SUT::Tree::APage:D $page ) { }
	method visit-depth-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) { }
	method visit-depth-element ( WebDriver2::SUT::Tree::ANode:D $element ) { }
}

sub MAIN( Int :$debug = 0 ) {
	plan 8;
	my Str @frames = <frames frame iframe>;
	my WebDriver2 $driver =  WebDriver2::Mock-Driver.new;
	my WebDriver2::SUT::Tree::SUT $sut =
			WebDriver2::SUT::Build.page: { $driver }, 'frames'; # 't/def/frames.sut'.IO;

	my Frame-Recorder $frames = Frame-Recorder.new;
	.accept: $frames with $sut.get: 'frames';
	is-deeply
			( Array[Str].new: $frames.frames.map: { ( .does: WebDriver2::SUT::Tree::APage ) ?? .id !! .name } ),
			@frames;
#	is $frames.frames.elems, @frames.elems, 'all frames covered';
	isa-ok $frames.frames.[0], WebDriver2::SUT::Tree::Page;
	does-ok $frames.frames.[0], WebDriver2::SUT::Tree::AFrame;
	nok $frames.frames.[1].isa: WebDriver2::SUT::Tree::Page;
	isa-ok $frames.frames.[1], WebDriver2::SUT::Tree::Frame;
	nok $frames.frames.[2].isa: WebDriver2::SUT::Tree::Page;
	isa-ok $frames.frames.[2], WebDriver2::SUT::Tree::Frame;

	my Page-Recorder $pages = Page-Recorder.new;
	.accept: $pages with $sut.get: 'frames';
	is-deeply
			( Array[Str].new: $pages.pages.map: { .id } ),
			Array[Str].new: <frames>;
	
	done-testing;
}
