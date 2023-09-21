use Test;

unit role WebDriver2::Test::Adapter;

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

method dies-ok ( Str:D $descr, &cb ) {
	my Bool $result = dies-ok &cb, $descr;
	self.handle-test-failure: $descr unless $result;
	$result;
}

method throws-like ( Str:D $reason, $ex-type, $code, *%matcher ) {
	my Bool $result = 0 == throws-like $code, $ex-type, $reason, |%matcher;
	self.handle-test-failure: $reason unless $result;
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

method done-testing {
	done-testing;
}
