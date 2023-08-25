use Test;

use lib <lib t/lib>;

use WebDriver2::Test;

class MyTest is WebDriver2::Test {
    method new ( Str $browser, Int $debug ) {
#        ...
        self.bless:
                :$browser,
                :$debug,
                plan => 42,
                name => 'mytest',
                description => 'my test';
    }
}
