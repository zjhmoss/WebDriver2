use v6;

use WebDriver2;

use WebDriver2::Command::Element::Locator;
use WebDriver2::Command::Element::Locator::ID;
use WebDriver2::Command::Element::Locator::CSS;
use WebDriver2::Command::Element::Locator::Tag-Name;
use WebDriver2::Command::Element::Locator::Xpath;

use WebDriver2::SUT::Tree;

grammar WebDriver2::SUT::Build::Page {
	rule TOP { ^ <page-def>+ $ }
	rule page-def { page <identifier> \'<service>\' \{ <component-def>+ \} }

	rule list-def {
		[
			list of <elgrp> <identifier> <locator> \{
				<restricted-component-def>+
			\}
		]
		| <list-element>
		| <list-select>
	}

	rule component-def {
		[ <branch-type> <identifier> <locator> \{ <component-def>+ \} ]
		| <list-def>
		| <element-def>
		| <select-def>
	}
	rule restricted-component-def {
		[ <fragile>? <elgrp> <identifier> <locator>
			\{ <restricted-component-def>+ \}
		]
		| <list-def>
		| <element-def>
		| <select-def>
	}
	rule branch-type { <frame> | <fragile>? <elgrp> }

	rule list-element { list of elemt <identifier> <locator> \; }
	rule list-select { list of selct <identifier> <locator> \; }

	rule element-def { <fragile>? elemt <identifier> <locator> \; }
	rule select-def { <fragile>? selct <identifier> <locator> \; }



	token identifier { <ident>+ [ '-' [ <ident>+ | \d+ ]* % '-' ]? }

	rule locator { <strategy> \'<selector>\' }
	proto token strategy {*}
	token strategy:sym<id> { <sym> }
	token strategy:sym<css> { <sym> }
	token strategy:sym<xpath> { <sym> }
	token strategy:sym<tag-name> { <sym> }
	token selector { <-[']>+ }

	token service { <protocol>'://'<address><rooted-path> | file'://'<path> }
	token address { <identifier>+ % '.' [ ':' \d+ ]? }
	proto token protocol {*}
	token protocol:sym<http> { <sym> }
	token protocol:sym<https> { <sym> }
	token rooted-path { '/'<path> }
	token path { ['/'<[a..zA..Z]>':']? [ [ \%<[\da..fA..F]> ** 2 ] | <[\w/.-]>]+ }
	token frame { frame }
	token elgrp { elgrp }
	token fragile { fragile }

}

class WebDriver2::SUT::Build::Page-Actions {
	has WebDriver2::SUT::Tree::SUT $!sut = WebDriver2::SUT::Tree::SUT.new;
	
	method TOP($/) {
		make $!sut
	}

	method site-def($/) {
		$!sut.add-page: $_ for $<page-def>>>.made;
	}

	method page-def($/) {
		my WebDriver2::SUT::Tree::Page $page =
				WebDriver2::SUT::Tree::Page.new:
						url => WebDriver2::SUT::Tree::URL.new( $<service>.Str ),
						id => $<identifier>.Str;
#						:$!driver;
		$page.add: $_ for $<component-def>>>.made;
		$!sut.add-page: $page;
		make $page
	}



	method list-def($/) {
		return make .made with $<list-element>;
		return make .made with $<list-select>;
		my WebDriver2::SUT::Tree::ANode $component =
				WebDriver2::SUT::Tree::List-Item.new:
						name => $<identifier>.Str,
						locator => $<locator>.made;
		$component.add: $_ for $<restricted-component-def>>>.made;
		make $component
	}

	method component-def($/) {
		return make .made with $<element-def>;
		return make .made with $<select-def>;
		return make .made with $<list-def>;
		my WebDriver2::SUT::Tree::ANode $component;
		given $<branch-type> {
			when .<frame> {
				$component = WebDriver2::SUT::Tree::Frame;
			}
			when .<elgrp> {
				$component = WebDriver2::SUT::Tree::Element;
			}
			default {
				die "unrecognized branch type $_";
			}
		}
		$component .= new:
				name => $<identifier>.Str,
				locator => $<locator>.made;
		$component = WebDriver2::SUT::Tree::Fragile.new: $component
			if $<branch-type><fragile>;
		$component.add: $_ for $<component-def>>>.made;
		make $component
	}
	method restricted-component-def($/) {
		return make .made with $<element-def>;
		return make .made with $<select-def>;
		return make .made with $<list-def>;
		my WebDriver2::SUT::Tree::ANode $component =
				WebDriver2::SUT::Tree::Element.new:
						name => $<identifier>.Str,
						locator => $<locator>.made;
		$component = WebDriver2::SUT::Tree::Fragile.new: $component
			if $<fragile>;
		$component.add: $_ for $<restricted-component-def>>>.made;
		make $component
	}

	method element-def($/) {
		my WebDriver2::SUT::Tree::Element $el =
				WebDriver2::SUT::Tree::Element.new:
						name => $<identifier>.Str,
						locator => $<locator>.made;
		$el = WebDriver2::SUT::Tree::Fragile.new: $el if $<fragile>;
		make $el
	}

	method select-def($/) {
		my WebDriver2::SUT::Tree::Element $el =
				WebDriver2::SUT::Tree::Element.new:
						name => $<identifier>.Str,
						locator => $<locator>.made;
		$el = WebDriver2::SUT::Tree::Fragile.new: $el if $<fragile>;
		$el does WebDriver2::SUT::Tree::Select;
		make $el
	}

	method list-element($/) {
		make WebDriver2::SUT::Tree::List-Item.new:
				name => $<identifier>.Str,
				locator => $<locator>.made
	}

	method list-select($/) {
		make ( ( WebDriver2::SUT::Tree::List-Item.new:
				name => $<identifier>.Str,
				locator => $<locator>.made
		) does WebDriver2::SUT::Tree::Select )
	}

	method locator($/) {
		make $<strategy>.made.new: $<selector>.Str
	}

	method strategy:sym<id>($/) { make WebDriver2::Command::Element::Locator::ID }
	method strategy:sym<css>($/) { make WebDriver2::Command::Element::Locator::CSS }
	method strategy:sym<xpath>($/) { make WebDriver2::Command::Element::Locator::Xpath }
	method strategy:sym<tag-name>($/) {
		make WebDriver2::Command::Element::Locator::Tag-Name
	}
}
