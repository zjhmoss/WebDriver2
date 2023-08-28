use WebDriver2::SUT::Tree;

class WebDriver2::SUT::Navigator::Path does Iterable {
	has Str @!parts is required;

	submethod BUILD ( :@!parts ) { }

	multi method new ( Str:D $path ) {
		return self.bless: parts => [] unless $path;
		return self.bless: parts => [ '/' ] if $path eq '/';
		my Str @parts = IO::Spec::Unix.canonpath( $path, :parent ).split: '/';
		@parts[0] ||= '/';
		self.bless: :@parts
	}

	multi method new ( WebDriver2::SUT::Tree::ANode:D $node is rw ) {
		my Str @parts = [ $node.name ];
		@parts.unshift: .name with @parts[0].parent;
		self.bless: :@parts
	}

	method abs ( --> Bool ) {
		so @!parts and @!parts[0] eq '/'
	}

	method iterator ( WebDriver2::SUT::Navigator::Path:D: ) {
		if self.abs {
			return @!parts[ 1 .. * ].iterator if @!parts.elems > 1;
			return [].iterator;
		}
		@!parts.iterator
	}
}

class WebDriver2::SUT::Navigator {
	has WebDriver2::SUT::Tree::ANode $!tree is required;
	has WebDriver2::SUT::Tree::ANode $!curr;
	has Int $!debug;

	submethod BUILD ( WebDriver2::SUT::Tree::ANode:D :$!tree, Int :$!debug = 0 ) {
		say $!tree.name if $!debug > 1;
		$!curr = $!tree;
	}

	multi method traverse ( --> WebDriver2::SUT::Tree::ANode:D ) {
		until $!curr === $!tree {
			$!curr .= parent;
			$!curr.notify;
		}
		$!curr
	}

	multi method traverse ( Str $path --> WebDriver2::SUT::Tree::ANode:D ) {
		my WebDriver2::SUT::Navigator::Path $nav-path = WebDriver2::SUT::Navigator::Path.new: $path;
		if $!debug > 1 {
			.say for $nav-path.flat;
		}
#		self.traverse if $nav-path.abs;
		if $nav-path.abs {
say 'abs path - to root';
			self.traverse.children>>.name>>.say;
		}
		for $nav-path.flat -> Str $part {
			if $part eq '..' {
				return $!curr if $!curr === $!tree;
				say 'ascending' if $!debug > 1;
				$!curr .= parent;
				$!curr.notify;
			} else {
				say "getting $part" if $!debug > 1;
				$!curr .= get: $part;
				$!curr.notify;
			}
		}
		$!curr
	}

	method frames ( --> Array of WebDriver2::SUT::Tree::AFrame ) {
		my WebDriver2::SUT::Tree::AFrame @frames;
		@frames.push:
				( $!curr.does: WebDriver2::SUT::Tree::AFrame )
						?? $!curr
						!! $!curr.parent-frame;
		@frames.unshift: @frames[0].parent-frame while @frames[0].parent-frame;
		@frames
	}
}
