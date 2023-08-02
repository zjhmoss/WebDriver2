use Test;

unit role WebDriver2::Test::Template;

#has Int $.debug = 0;
has Int $.plan;
has Str:D $.name is required;
has Str:D $.description is required;

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
		self.init;
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

method subtest ( Pair $test ) {
	my Bool $result = ? subtest $test;
	self.handle-test-failure: $test.key unless $result;
	$result;
}

method ok ( Str:D $descr, $val ) {
	my Bool $result = ok $val, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method nok ( Str:D $descr, $val ) {
	my Bool $result = nok $val, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method is ( Str:D $descr, $exp, $got ) {
	my Bool $result = is $got, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method is-deeply ( Str:D $descr, $exp, $got ) {
	my Bool $result = is-deeply $got, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method isa-ok ( Str:D $descr, $exp, $got ) {
	my Bool $result = isa-ok $got, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method does-ok ( Str:D $descr, $exp, $got ) {
	my Bool $result = does-ok $got, $exp, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method lives-ok ( Str:D $descr, &cb ) {
	my Bool $result = lives-ok &cb, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method flunk ( Str:D $descr ) {
	self.handle-test-failure: $descr;
	flunk $descr;
}

method bail ( Str:D $descr ) {
	self.handle-test-failure: $descr;
	bail-out $descr;
}
