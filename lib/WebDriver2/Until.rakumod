use WebDriver2;

class WebDriver2::Until::Timeout::X is Exception {
	method message ( ) { 'timeout' }
}

class WebDriver2::Until {
	my Real $_interval = 1/10;
	my Int $_debug = 0;

	has &!operation is required;
	has &!matcher;
	has &!cleanup;
	has Duration $!duration is required;
	has Duration $!interval;
	has Bool $!soft = False;
	has Int $!debug = 0;

	method interval ( WebDriver2::Until:U: Real $val ) {
		$_interval = $val;
	}
	method debug ( WebDriver2::Until:U: Int $val ) {
		$_debug = $val;
	}

	submethod BUILD (
			:&!operation,
			:&!matcher,
			:&!cleanup,
			Duration :$!duration,
			Duration :$!interval,
			Bool :$!soft,
			Int :$!debug
	) { }

	method new (
			:&operation,
			:&matcher,
			:&cleanup,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		self.bless:
				:&operation,
				:&matcher,
				:&cleanup,
				duration => Duration.new( $duration ),
				interval => Duration.new( $interval // $_interval ),
				:$soft,
				debug => $debug // $_debug;
	}

	method retry {
		my Instant $start = now;
		say "\n\nSTARTING TRIALS " ~ $start.DateTime ~ "\n\n" if $!debug;
		repeat {
			say "\n\nTRYING " ~ $start.DateTime ~ "\n\n" if $!debug;
			my $return = &!operation();
			say "\n\nOP VAL ",$return.raku, "\n\n" if $!debug;
			return $return
				if &!matcher and &!matcher( $return )
				or not &!matcher and $return;
			&!cleanup() if &!cleanup;
			sleep $!interval;
		} while ( now - $start ) < $!duration;
		return if $!soft;
		WebDriver2::Until::Timeout::X.new.throw;
	}
}

class WebDriver2::Until::Throwable is WebDriver2::Until {
	method new (
			:&operation,
			:&matcher,
			:&cleanup,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith operation => sub () {
			try {
				CATCH {
					default { return $_ }
				}
				return &operation();
			}
		}, :&matcher, :&cleanup, :$duration, :$interval, :$soft, :$debug;
	}
}

class WebDriver2::Until::Throws is WebDriver2::Until::Throwable {
	method new (
			:&operation,
			:$exception,
			:&matcher,
			:&cleanup,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith :&operation, :$exception,
		matcher => -> $ret {
			$ret ~~ $exception and ! &matcher || &matcher( $ret );
		}, :&cleanup, :$duration, :$interval, :$soft, :$debug;
	}
}

class WebDriver2::Until::No-Throw is WebDriver2::Until::Throwable {
	method new (
			:&operation,
			:$exception,
			:&matcher,
			:&cleanup,
			Real :$duration,
			Real :$interval,
			Bool :$soft,
			Int :$debug
	) {
		callwith :&operation, :$exception,
		matcher => -> $ret {
			say "\n\nTRYING MATCH\n\n" if $debug;
			$ret.throw
				if $ret
						and $ret ~~ Exception
						and ! &matcher( $ret )
							|| ! &matcher && $ret !~~ $exception;
			say "\n\nNO THROW\n\n" if $debug;
			say $ret.raku if $debug;
			say so $ret ~~ $exception if $debug;
			say $exception.raku if $debug;
			$ret !~~ $exception;
		}, :&cleanup, :$duration, :$interval, :$soft, :$debug;
	}
}

class WebDriver2::Until::Title-Is is WebDriver2::Until {
	method new (
			WebDriver2 :$driver!,
			Str :$title!,
			Real :$duration = 5,
			Real :$interval = 1 / 10,
			Int :$debug = 0,
			Bool :$soft = False
	) {
		callwith
				operation => { $driver.title eq $title },
				:$duration,
				:$interval,
				:$debug,
				:$soft;
	}
}
