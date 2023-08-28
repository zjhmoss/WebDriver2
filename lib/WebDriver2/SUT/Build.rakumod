use WebDriver2;
# use WebDriver2::SUT::ProviderR;
use WebDriver2::SUT::Tree;
use WebDriver2::SUT::Build::Page;

unit class WebDriver2::SUT::Build;

my IO::Path $def-dir = $*PROGRAM.parent.parent.add: 'def';

method page (
		Callable:D $page-resolver,
		Str:D $sut-name,
		Bool :$check,
		Int :$debug = 0
) {
	my IO::Path $page = .IO with $def-dir.add: "$sut-name.sut";
	my Str $contents = pre-process $page;
	my WebDriver2::SUT::Build::Page-Actions $actions =
			WebDriver2::SUT::Build::Page-Actions.new; # : :$driver;
	my Match $match = WebDriver2::SUT::Build::Page.parse: $contents, :$actions
			or die 'failed parse';
	$match.Str.say if $debug > 1;
	return if $check;
	my WebDriver2::SUT::Tree::SUT $sut = $match.made;
	$sut.page-resolver: $page-resolver;
	$sut;
}

my sub pre-process ( IO::Path $file --> Str ) {
	my Str $buff;
	for $file.lines -> Str $line {
		given $line {
			when /^ \s*\#include\s+\'(<-[']>+)\'/ {
				$buff ~= pre-process( $file.parent.add( $/[0].Str ) );
			}
			when /^ \s*\# / {
				next;
			}
			default {
				$buff ~= $line;
			}
		}
	}
	return $buff;
}
