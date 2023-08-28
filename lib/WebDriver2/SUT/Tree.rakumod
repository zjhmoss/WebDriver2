use WebDriver2::Command::Element::Locator;
use WebDriver2::Command::Element::Locator::Tag-Name;
use WebDriver2;
use WebDriver2::Command::Result;
use WebDriver2::Command::Execution-Status;

role WebDriver2::SUT::Tree::Subject { ... }

role WebDriver2::SUT::Tree::Observer {
	method update ( WebDriver2::SUT::Tree::Subject:D $subject ) { ... }
}

role WebDriver2::SUT::Tree::Subject {
	has WebDriver2::SUT::Tree::Observer @!observer;

	method add-observer ( WebDriver2::SUT::Tree::Observer:D $observer ) {
		@!observer.push: $observer;
	}

	method notify {
		.update: self for @!observer;
	}
}

role WebDriver2::SUT::Tree::APage { ... }
role WebDriver2::SUT::Tree::AFrame { ... }
role WebDriver2::SUT::Tree::ANode { ... }

role WebDriver2::SUT::Tree::Visitor { ... }

role WebDriver2::SUT::Tree::Visitable {
	method accept ( WebDriver2::SUT::Tree::Visitor:D $v ) { ... }
	method accept-depth ( WebDriver2::SUT::Tree::Visitor:D $v ) { ... }
}

role WebDriver2::SUT::Tree::Visitor {
	method visit-page ( WebDriver2::SUT::Tree::APage:D $page ) { ... }
	method visit-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) { ... }
	method visit-element ( WebDriver2::SUT::Tree::ANode:D $element ) { ... }

	method visit-depth-page ( WebDriver2::SUT::Tree::APage:D $page ) { ... }
	method visit-depth-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) { ... }
	method visit-depth-element ( WebDriver2::SUT::Tree::ANode:D $element ) { ... }

	method exit-element { ... }
	method exit-frame { ... }
	method exit-page { ... }
}

role WebDriver2::SUT::Tree::Resolvable[ WebDriver2::Model::Context ::T ] {
	method resolve ( --> T:D ) { ... }
	method present ( --> T ) { ... }
}
role WebDriver2::SUT::Tree::Resolve-Allable {
	method resolve-all ( --> Array of WebDriver2::Model::Element ) { ... }
}

role WebDriver2::SUT::Tree::Named {
	has Str $.name is required;
	submethod BUILD ( Str :$!name ) { }
}

role WebDriver2::SUT::Tree::AFrame { ... }

class WebDriver2::SUT::Tree::URL {
	has Str $.protocol is required;
	has Str $.address;
	has UInt $.port;
	has Str $.path is required;
	submethod BUILD (
			Str:D :$!protocol, Str:D :$!address = '', UInt :$!port, Str:D :$path
	) {
		$!path = IO::Spec::Unix.canonpath: $path;
	}
	method new ( Str $url ) {
		my Str ( $protocol, $rest ) = $url.split: /'://'/, 2;
		if $protocol eq 'file' {
			unless $rest.starts-with: '/' {
				my IO::Path $cdir = $*PROGRAM.parent.parent.parent; # add: 'content';
				$rest = $rest.IO.cleanup.absolute: base => $cdir;
			}
			return self.bless: :$protocol, path => $rest;
		}
		my Str ( $addr-port, $path ) = $rest.split: /\//, 2;
		$path = '/' ~ $path;
		my Str ( $address, $port-str ) = $addr-port.split: /\:/, 2;
		my UInt $port = $port-str ?? $port-str.UInt !! UInt;
		self.bless: :$protocol, :$address, :$port, :$path
	}
	method Str ( --> Str:D ) {
		$!port
				?? "$!protocol://$!address:$!port$!path"
				!! "$!protocol://$!address$!path";
	}
}

role WebDriver2::SUT::Tree::ANode
		does WebDriver2::SUT::Tree::Named
		does WebDriver2::SUT::Tree::Subject
		does WebDriver2::SUT::Tree::Visitable
{
	has WebDriver2::SUT::Tree::ANode $.parent is rw;
	has WebDriver2::SUT::Tree::AFrame $.parent-frame is rw;

	method add ( WebDriver2::SUT::Tree::ANode:D $child ) { ... }

	method get ( Str:D $name --> WebDriver2::SUT::Tree::ANode:D ) { ... }

	method children ( --> Array of WebDriver2::SUT::Tree::ANode ) { ... }
}

role WebDriver2::SUT::Tree::AFrame does WebDriver2::SUT::Tree::ANode { }

role WebDriver2::SUT::Tree::APage does WebDriver2::SUT::Tree::AFrame {
	has WebDriver2::SUT::Tree::ANode %!children;
	has WebDriver2::SUT::Tree::URL $.url is required;
	has Str $.id is required;
}

role WebDriver2::SUT::Tree::Locatable {
	has WebDriver2::Command::Element::Locator $.locator;
}

class WebDriver2::SUT::Tree::Fragile { ... }
class WebDriver2::SUT::Tree::List-Item { ... }

class WebDriver2::SUT::Tree::Frame-Visitor does WebDriver2::SUT::Tree::Visitor {
	has WebDriver2::SUT::Tree::AFrame @!stack;
	method exit-page {
		@!stack.shift;
	}
	method exit-frame {
		@!stack.shift;
	}
	method exit-element {

	}
	method visit-page ( WebDriver2::SUT::Tree::APage:D $page ) {
		@!stack.unshift: $page;
	}
	method visit-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) {
		$frame.parent-frame = @!stack[0];
		@!stack.unshift: $frame;
	}
	method visit-element ( WebDriver2::SUT::Tree::ANode:D $element ) {
		$element.parent-frame = @!stack[0];
	}
	method visit-depth-page ( WebDriver2::SUT::Tree::APage:D $page ) { }
	method visit-depth-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) { }
	method visit-depth-element ( WebDriver2::SUT::Tree::ANode:D $element ) { }
}

class WebDriver2::SUT::Tree::Fragile-Visitor { ... }

class WebDriver2::SUT::Tree::Element
		does WebDriver2::SUT::Tree::ANode
		does WebDriver2::SUT::Tree::Locatable
		does WebDriver2::SUT::Tree::Resolvable[ WebDriver2::Model::Element ]
{
	has WebDriver2::SUT::Tree::ANode %!children;
	submethod BUILD (
			Str:D :$!name,
			WebDriver2::Command::Element::Locator :$!locator
	) { }
	method update ( WebDriver2::SUT::Tree::Fragile:D $child ) {
		my Str $name = $child.name;
		die "no child named $name to update" unless %!children{ $name }:exists;
		%!children{ $name } = $child;
	}
	method add ( WebDriver2::SUT::Tree::ANode:D $child ) {
		my Str $name = $child.name;
		die "child with name $name already exists"
			if %!children{ $name }:exists;
		%!children{ $name } = $child;
		$child.parent = self;
		$child.parent-frame = $!parent-frame;
	}
	method get ( Str:D $name --> WebDriver2::SUT::Tree::ANode:D ) {
		die "no child with name $name" unless %!children{ $name }:exists;
		%!children{ $name }
	}
	method children ( --> Array of WebDriver2::SUT::Tree::ANode ) {
		my WebDriver2::SUT::Tree::ANode @children = %!children.values;
		@children
	}
	method present ( --> WebDriver2::Model::Element ) {
		my @results = $!parent.resolve.elements: $!locator;
		return .[0] with $!parent.resolve.elements: $!locator;
		Model::Element
	}
	method accept ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		$v.visit-element: self;
		my WebDriver2::SUT::Tree::ANode @children = self.children;
		.accept: $v for self.children;
		$v.exit-element;
	}
	method accept-depth ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		my WebDriver2::SUT::Tree::ANode @children = self.children;
		if @children.elems == 1 {
			@children[0].accept-depth: $v;
		} else {
			.accept-depth: $v for self.children;
		}
		$v.visit-depth-element: self;
	}
	method resolve ( --> WebDriver2::Model::Element:D ) {
		$!parent.resolve.element: $!locator
	}
}

class WebDriver2::SUT::Tree::Fragile
		is WebDriver2::SUT::Tree::Element
		does WebDriver2::Model::Element
{
	has Int $!max-tries = 3;
	has WebDriver2::SUT::Tree::Element $!element
			is required
			handles <
					update get children present parent parent-frame
					name locator
					add-observer notify
			>;
	has WebDriver2::Model::Element $.internal-element;
	submethod BUILD ( WebDriver2::SUT::Tree::Element:D :$!element ) { }
	method new ( WebDriver2::SUT::Tree::Element:D $element ) {
		return $element if $element.isa: WebDriver2::SUT::Tree::Fragile;
		self.bless:
				:$element,
				name => $element.name,
				locator => $element.locator
	}
	method bare-resolve ( --> WebDriver2::Model::Element:D ) {
		self.resolve;
		$!internal-element
	}
	method resolve ( --> WebDriver2::Model::Element:D ) {
		$!internal-element = $!element.resolve;
		self
	}
	method attempt ( &cb ) {
		my Int $tries;
		loop {
			try {
				CATCH {
					when WebDriver2::Command::Result::X
							and *.status.type
							==  ( WebDriver2::Command::Execution-Status::Type::Frame,
							WebDriver2::Command::Execution-Status::Type::Stale ).any
					{
						if $tries >= $!max-tries {
							warn 'bailing due to max tries';
							.throw;
						}
						warn 'retrying';
#						self.resolve.switch-to;
						self.resolve;
					}
					default {
						warn 'caught non stale exception ' ~ $_;
						.raku.say;
						.throw;
					}
				}
				++$tries;
				return &cb();
			}
		}
	}
	method add ( WebDriver2::SUT::Tree::ANode:D $child ) {
		my $c = $child;
		$c = WebDriver2::SUT::Tree::Fragile.new: $child
			unless $child.isa: WebDriver2::SUT::Tree::List-Item;
		$!element.add: $c;
		$c.parent = self;
		$c.parent-frame = self.parent-frame;
	}
	method accept ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		$v.visit-element: self;
		my WebDriver2::SUT::Tree::ANode @children = self.children;
		.accept: $v for self.children;
		$v.exit-element;
	}
	method accept-depth ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		my WebDriver2::SUT::Tree::ANode @children = self.children;
		if @children.elems == 1 {
			@children[0].accept-depth: $v;
		} else {
			.accept-depth: $v for self.children;
		}
		$v.visit-depth-element: self;
	}
	method internal-id ( --> Str ) {
		self.resolve.internal-element.internal-id
	}
	method frame ( --> WebDriver2::Model::Frame:D ) { !!! }
	method top ( --> WebDriver2::Model::Context:D ) {
		self.resolve.internal-element.top
	}
	method element ( WebDriver2::Command::Element::Locator:D $loc --> WebDriver2::Model::Element:D ) {
		self.attempt: { self.resolve.internal-element.element: $loc }
	}
	method elements(
			WebDriver2::Command::Element::Locator:D $locator
			--> Array of WebDriver2::Model::Element
	) {
		self.attempt: { self.resolve.internal-element.elements: $locator }
	}
	method tag-name ( --> Str:D ) {
		self.attempt: { self.resolve.internal-element.tag-name }
	}
	method rect ( --> Hash of Int ) {
		self.attempt: { self.resolve.internal-element.rect }
	}
	method stale ( --> Bool:D ) {
		$!internal-element.stale
	}
	method property ( Str:D $property --> Str ) {
		self.attempt: { self.resolve.internal-element.property: $property }
	}
	method attribute ( Str:D $attribute --> Str ) {
		self.attempt: { self.resolve.internal-element.attribute: $attribute }
	}
	method id ( --> Str ) {
		self.attempt: { self.resolve.internal-element.id }
	}
	method value ( --> Str ) {
		self.attempt: { self.internal-element.value }
	}
	method text ( --> Str:D ) {
		self.attempt: { self.resolve.internal-element.text }
	}
	method displayed ( --> Bool:D ) {
		self.attempt: { self.resolve.internal-element.displayed }
	}
	method selected ( --> Bool:D ) {
		self.attempt: { self.resolve.internal-element.selected }
	}
	method enabled ( --> Bool:D ) {
		self.attempt: { self.resolve.internal-element.enabled }
	}
	method css-value ( --> Str ) {
		self.attempt: { self.resolve.internal-element.css-value }
	}
	method send-keys ( Str:D $text ) {
		self.attempt: { self.resolve.internal-element.send-keys: $text }
	}
	method clear ( --> WebDriver2::Model::Element:D ) {
		self.attempt: { self.resolve.internal-element.clear; self }
	}
	method click ( --> WebDriver2::Model::Element:D ) {
		self.attempt: { self.resolve.internal-element.click; self }
	}
	method debug ( --> Str:D ) {
		$!internal-element.debug
	}
}

my WebDriver2::Command::Element::Locator $OPT =
		WebDriver2::Command::Element::Locator::Tag-Name.new: 'option';

role WebDriver2::SUT::Tree::Select
		does WebDriver2::SUT::Tree::Resolvable[ WebDriver2::Model::Element ]
{
	method select ( Str:D $text --> Bool:D ) {
		for self.resolve.elements( $OPT ) -> WebDriver2::Model::Element $opt {
			if $opt.text eq $text {
				$opt.click;
				return True;
			}
		}
		False
	}
	method selected ( --> Str ) {
		for self.resolve.elements( $OPT ) -> WebDriver2::Model::Element $opt {
			return $opt.text if $opt.property: 'selected';
		}
		Str
	}
	method selected-value ( --> Str ) {
		for self.resolve.elements( $OPT ) -> WebDriver2::Model::Element $opt {
			return $opt.value if $opt.property: 'selected';
		}
		Str
	}
}



class WebDriver2::SUT::Tree::List-Item
		does WebDriver2::SUT::Tree::ANode
		does WebDriver2::SUT::Tree::Locatable
		does Iterable does Iterator
		does WebDriver2::SUT::Tree::Resolvable[ WebDriver2::Model::Element ]
		does WebDriver2::SUT::Tree::Resolve-Allable
{
	has Iterator $!it;
	has WebDriver2::Model::Element $!el;
	has WebDriver2::SUT::Tree::ANode %!children;
	submethod BUILD (
			Str:D :$!name,
			WebDriver2::Command::Element::Locator :$!locator
	) { }
	method add ( WebDriver2::SUT::Tree::ANode:D $child ) {
		my Str $name = $child.name;
		die "child with name $name already exists"
			if %!children{ $name }:exists;
		%!children{ $name } = $child;
		$child.parent = self;
		$child.parent-frame = self.parent-frame;
	}
	method get ( Str:D $name --> WebDriver2::SUT::Tree::ANode:D ) {
		die "no child with name $name" unless %!children{ $name }:exists;
		%!children{ $name }
	}
	method children ( --> Array of WebDriver2::SUT::Tree::ANode ) {
		my WebDriver2::SUT::Tree::ANode @children = %!children.values;
		@children
	}
	method present ( --> WebDriver2::Model::Element ) {
		$!el
	}
	method iterator {
		$!it = self.resolve-all.iterator;
		self
	}
	method pull-one {
		my Mu $next := $!it.pull-one;
		if $next =:= IterationEnd {
			$!el = WebDriver2::Model::Element;
			return IterationEnd;
		}
		$!el = $next;
		self
	}
	method resolve { $!el }
	method resolve-all {
		$!parent.resolve.elements: $!locator
	}
	method accept ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		$v.visit-element: self;
		my WebDriver2::SUT::Tree::ANode @children = self.children;
		if @children.elems == 1 {
			@children[0].accept: $v;
		} else {
			.accept: $v for self.children;
		}
		$v.exit-element;
	}
	method accept-depth ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		my WebDriver2::SUT::Tree::ANode @children = self.children;
		if @children.elems == 1 {
			@children[0].accept-depth: $v;
		} else {
			.accept-depth: $v for self.children;
		}
		$v.visit-depth-element: self;
	}
}

class WebDriver2::SUT::Tree::Fragile-Visitor does WebDriver2::SUT::Tree::Visitor {
	method exit-page { }
	method exit-frame { }
	method exit-element { }
	method !visit ( WebDriver2::SUT::Tree::ANode:D $element ) {
		return unless $element.isa: WebDriver2::SUT::Tree::Fragile;
		for $element.children -> WebDriver2::SUT::Tree::ANode $child is rw {
			next
					if $child.isa: WebDriver2::SUT::Tree::Fragile
					or $child.isa: WebDriver2::SUT::Tree::List-Item;
			$child = WebDriver2::SUT::Tree::Fragile.new: $child;
			$element.update: $child;
		}
	}
	method visit-page ( WebDriver2::SUT::Tree::APage:D $page ) { }
	method visit-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) {
		self!visit: $frame;
	}
	method visit-element ( WebDriver2::SUT::Tree::ANode:D $element ) {
		self!visit: $element;
	}
	method visit-depth-page ( WebDriver2::SUT::Tree::APage:D $page ) { }
	method visit-depth-frame ( WebDriver2::SUT::Tree::AFrame:D $frame ) { }
	method visit-depth-element ( WebDriver2::SUT::Tree::ANode:D $element ) { }
}

class WebDriver2::SUT::Tree::Frame
		does WebDriver2::SUT::Tree::AFrame
		does WebDriver2::SUT::Tree::Locatable
		does WebDriver2::SUT::Tree::Resolvable[ WebDriver2::Model::Frame ]
{
	has WebDriver2::Model::Frame $!frame;
	has WebDriver2::SUT::Tree::ANode %!children;

	submethod BUILD (
			Str:D :$!name,
			WebDriver2::Command::Element::Locator :$!locator
	) { }

	method add ( WebDriver2::SUT::Tree::ANode:D $child ) {
		my Str $name = $child.name;
		die "child with name $name already exists"
			if %!children{ $name }:exists;
		%!children{ $name } = $child;
		$child.parent = self;
		$child.parent-frame = self;
	}
	method get ( Str:D $name --> WebDriver2::SUT::Tree::ANode:D ) {
		die "no child with name $name" unless %!children{ $name }:exists;
		%!children{ $name }
	}
	method children ( --> Array of WebDriver2::SUT::Tree::ANode ) {
		my WebDriver2::SUT::Tree::ANode @children = %!children.values;
		@children
	}
	method accept ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		$v.visit-frame: self;
		my WebDriver2::SUT::Tree::ANode @children = self.children;
		.accept: $v for self.children;
		$v.exit-frame;
	}
	method accept-depth ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		my WebDriver2::SUT::Tree::ANode @children = self.children;
		if @children.elems == 1 {
			@children[0].accept-depth: $v;
		} else {
			.accept-depth: $v for self.children;
		}
		$v.visit-depth-frame: self;
	}
	method resolve ( --> WebDriver2::Model::Context:D ) {
		if not $!frame or not $!frame.is-curr-frame or $!frame.stale {
			$!frame = ( $!parent.resolve.element: $!locator ).frame;
			$!frame.switch-to;
		}
		$!frame.context.element: WebDriver2::Command::Element::Locator::Tag-Name.new: 'body';
	}
	method present ( --> WebDriver2::Model::Element ) {
		return $!frame if $!frame and not $!frame.stale;
		WebDriver2::Model::Frame
	}
}



class WebDriver2::SUT::Tree::Page
		does WebDriver2::SUT::Tree::APage
		does WebDriver2::SUT::Tree::Resolvable[ WebDriver2::Model::Context ]
{
	has &!resolver;
	submethod BUILD (
			Str:D :$!name,
			WebDriver2::SUT::Tree::URL:D :$!url,
			Str:D :$!id
	) { }
	method new (
			WebDriver2::SUT::Tree::URL:D :$url,
			Str:D :$id
	) {
		self.bless:
				name => '/',
				:$url,
				:$id,
#				:$driver
	}
	
	
	method add ( WebDriver2::SUT::Tree::ANode:D $child ) {
		my Str $name = $child.name;
		die "child with name $name already exists"
				if %!children{ $name }:exists;
say 'adding ', $child.name;
		%!children{ $name } = $child;
		$child.parent = self;
		$child.parent-frame = self;
	}
	method get ( Str:D $name --> WebDriver2::SUT::Tree::ANode:D ) {
		die "no child with name $name" unless %!children{ $name }:exists;
		%!children{ $name }
	}
	method children ( --> Array of WebDriver2::SUT::Tree::ANode ) {
		my WebDriver2::SUT::Tree::ANode @children = %!children.values;
		@children
	}
	method present ( --> WebDriver2::Model::Context ) {
		# return $!driver if $!driver.current-url eq $!url.Str;
		WebDriver2::Model::Context;
	}
	method accept ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		$v.visit-page: self;
		my WebDriver2::SUT::Tree::ANode @children = self.children;
#		if @children.elems == 1 {
#			@children[0].accept: $v;
#		} else {
			.accept: $v for self.children;
#		}
		$v.exit-page;
	}
	method accept-depth ( WebDriver2::SUT::Tree::Visitor:D $v ) {
		my WebDriver2::SUT::Tree::ANode @children = self.children;
		if @children.elems == 1 {
			@children[0].accept-depth: $v;
		} else {
			.accept-depth: $v for self.children;
		}
		$v.visit-depth-page: self;
	}
	method resolve ( --> WebDriver2::Model::Context:D ) {
		&!resolver().element:
				WebDriver2::Command::Element::Locator::Tag-Name.new: 'body';
	}
	method resolver ( &resolver ) {
		&!resolver = &resolver;
	}
}

class WebDriver2::SUT::Tree::SUT {
	has WebDriver2::SUT::Tree::APage %!page;
	# FIXME : revert when resolved https://github.com/rakudo/rakudo/issues/2544
	has SetHash $!url = SetHash.new; # = SetHash[Str].new;
	method add-page ( WebDriver2::SUT::Tree::APage:D $page ) {
		my Str $url = $page.url.Str;
		die "$url already added" if $!url{ $url };
		my Str $id = $page.id;
		die "$id already added" if %!page{ $id }:exists;
		$!url.set: $url;
		%!page{ $id } = $page;
		$page.accept: WebDriver2::SUT::Tree::Frame-Visitor.new;
		$page.accept: WebDriver2::SUT::Tree::Fragile-Visitor.new;
	}
	method get ( Str:D $id --> WebDriver2::SUT::Tree::APage:D ) {
		die "no page with id $id" unless %!page{ $id }:exists;
		%!page{ $id }
	}
	method page-resolver ( &resolver ) {
		.resolver: &resolver for %!page<>:v;
	}
}
