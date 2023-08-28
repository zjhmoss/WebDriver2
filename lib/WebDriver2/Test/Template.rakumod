use Test;

unit role WebDriver2::Test::Template;

#has Int $.debug = 0;
has Int $.plan;
has Str:D $.name is required;
has Str:D $.description is required;

#submethod BUILD ( Int $!plan, Str:D $!name is required, Str:D $!description is required ) { }

method init { ... }
method pre-test { ... }
method test { ... }
method post-test { ... }
method close { ... }
method done-testing { done-testing }
method cleanup { ... }

method execute {
	plan $.plan if $.plan;
	try {
#		self.init;
		self.pre-test;
		self.test;
		self.post-test;
		self.close;
		CATCH {
			default {
				.note;
				self.handle-error: $_;
				self.cleanup;
			}
		}
	}
	self.done-testing unless self.plan;
}

method handle-error ( Exception $x ) { ... }
method handle-test-failure ( Str $descr ) { ... }
