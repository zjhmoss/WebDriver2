use Test;
use MIME::Base64;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::SUT::Build;
use WebDriver2::SUT::Navigator;
use WebDriver2::SUT::Service;
use WebDriver2::Test::Service-Test;

class Mixed-Content {
	has Str $.content1;
	has Str $.content2;
	has Str $.content3;
	has Str $.attached is rw;
}

my IO::Path $html-file =
		.add: 'mixed.html' with $*PROGRAM.parent.parent.add: 'content';

class Mixed does WebDriver2::SUT::Service {
	has Mixed-Content @!content;
	
	submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }

	method name ( --> Str:D ) { 'mixed' }

	method navigate {
		my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
		$!driver.navigate: $url.Str;
	}

	method title {
		$!driver.title;
	}
	
	method h2-text {
		%.elements<h2>.resolve.text
	}
	method header-text {
		%.elements<header-text>.resolve.text
	}
	method button1 {
		%.elements<button1>.resolve.value
	}
	method button2 {
		%.elements<button2>.resolve.value
	}
	method items {
		return @!content if @!content;
		for %.elements<main-content>.iterator {
			@!content.push: Mixed-Content.new:
				content1 => %.elements<content1>.resolve.text,
				content2 => %.elements<content2>.resolve.text,
				content3 => %.elements<content3>.resolve.text;
		}
		my Str @attached;
		@attached.push: %.elements<attached>.resolve.text
			for %.elements<attached-content>.iterator;
		die "{ @!content.elems } content vs { @attached.elems } attached"
			if @!content.elems != @attached.elems;
		for @!content Z @attached -> ( $m, $a ) {
			$m.attached = $a;
		}
		@!content
	}

}

class Mixed-Test does WebDriver2::Test::Service-Test {
	has Str:D $.sut-name = 'mixed';
	has Int:D $.plan = 22;
	has Str:D $.name = 'mixed';
	has Str:D $.description = 'tests for various feature levels';
	has IO::Path:D $.test-root = $*CWD.add: 'xt';
	
	has Mixed $!mixed;
	
#	submethod BUILD (
#			Str   :$!browser,
#			Str:D :$!name,
#			Str:D :$!description,
#			Str:D :$!sut-name,
#			Int   :$!plan,
#			Int   :$!debug = 0
#	) { }
#	
#	submethod TWEAK (
##			Str   :$browser is copy,
#			Str:D :$name,
#			Str:D :$description,
#			Str:D :$sut-name,
#			Int   :$plan,
#			Int   :$debug
#	) {
#		$!sut = WebDriver2::SUT::Build.page: { self.driver.top }, $!sut-name, debug => self.debug;
#		$!loader =
#				WebDriver2::SUT::Service::Loader.new:
#						driver => self.driver,
#						:$!browser,
#						:$sut-name,
#						:$debug;
#	}
	
	
	method services {
		$.loader.load-elements: $!mixed = Mixed.new: :$.driver;
	}

#	method new ( Str $browser? is copy, Int :$debug is copy ) {
#		self.set-from-file: $browser; # , $debug;
#		my Mixed-Test:D $self =
#				callwith
#						:$browser,
#						:$debug,
#						sut-name => 'mixed',
#						name => 'mixed',
#						description => 'tests for various feature levels',
#						plan => 23;
#		$self.init;
#		$self.services;
#		$self;
#	}
	
	method test {
#		$!mixed = $.service-loader.load: Mixed;
		$!mixed.navigate;
		
		is $!mixed.title, 'mixed content', 'page title';
		
		is $!mixed.h2-text, 'mixed content h2', 'h2 text';
		is $!mixed.header-text.trim, 'header text', 'header text';
		is $!mixed.button1, 'Value 1', 'button1 text';
		is $!mixed.button2, 'Value 2', 'button2 text';
		my Mixed-Content @content = $!mixed.items;
		is @content.elems, 4, 'number of items';
		is @content[0].content1, 'content 1-1', 'content 1-1';
		is @content[0].content2, 'content 1-2', 'content 1-2';
		is @content[0].content3, 'content 1-3', 'content 1-3';
		is @content[0].attached, 'attached 1', 'attached 1';
		is @content[1].content1, 'content 2-1', 'content 2-1';
		is @content[1].content2, 'content 2-2', 'content 2-2';
		is @content[1].content3, 'content 2-3', 'content 2-3';
		is @content[1].attached, 'attached 2', 'attached 2';
		is @content[2].content1, 'content 3-1', 'content 3-1';
		is @content[2].content2, 'content 3-2', 'content 3-2';
		is @content[2].content3, 'content 3-3', 'content 3-3';
		is @content[2].attached, 'attached 3', 'attached 3';
		is @content[3].content1, 'content 4-1', 'content 4-1';
		is @content[3].content2, 'content 4-2', 'content 4-2';
		is @content[3].content3, 'content 4-3', 'content 4-3';
		is @content[3].attached, 'attached 4', 'attached 4';
	}
}

sub MAIN(
		Str $browser?,
		Int:D :$debug = 0
) {
	.execute with Mixed-Test.new: $browser, :$debug;
}
