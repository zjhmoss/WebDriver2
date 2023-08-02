use Test;
use MIME::Base64;

use lib <lib t/lib>;

use WebDriver2;
use WebDriver2::Test::Config-From-File;

use WebDriver2::SUT::Build;
use WebDriver2::SUT::Navigator;
use WebDriver2::SUT::Service;
use WebDriver2::Test::Service-Test;
use WebDriver2::Until;
use WebDriver2::Until::SUT;
use WebDriver2::Until::Command;



class ML does WebDriver2::SUT::Service {
    my IO::Path $html-file =
            .add: 'ml.html' with $*PROGRAM.parent.parent.add: 'content';

    method name (--> Str:D) {
        'ml'
    }

    method li {
        my $url = WebDriver2::SUT::Tree::URL.new: 'file://' ~ $html-file;
        $!driver.navigate: $url.Str;
        my WebDriver2::Until $stale =
                WebDriver2::Until::Command::Stale.new:
                        duration => 3,
                        interval => 1 / 10,
                        element => .resolve with self.get: 'button';
        .resolve.click with self.get: 'button';
        $stale.retry;
    }
}

class L does WebDriver2::SUT::Service {
    method name (--> Str:D) {
        'l'
    }

    multi method i ( --> Str:D ) {
        my $f = self.get: 'l';
        $f.resolve;
        $f.present.switch-to;
        .resolve.value with self.get: 'li';
    }

    multi method i ( Str:D $i ) {
        my $f = self.get: 'l';
        $f.resolve;
        $f.present.switch-to;
        my $input = .resolve with self.get: 'li';
        $input.send-keys: $i;
    }
}

class R does WebDriver2::SUT::Service {

    method name (--> Str:D) {
        'r'
    }

    multi method i ( --> Str:D ) {
        my $f = self.get: 'r';
        $f.resolve;
        $f.present.switch-to;
        .resolve.value with self.get: 'ri';
    }

    multi method i ( Str:D $i ) {
        my $el = self.get: 'r';
        $el.resolve;
        $el.present.switch-to;
        my $input = .resolve with self.get: 'ri';
        $input.send-keys: $i;
    }
    method loaded {
        my WebDriver2::Until $input-present =
                WebDriver2::Until::SUT::Present.new:
                        duration => 10,
                        interval => 1 / 10,
                        element => self.get: 'ri';
        $input-present.retry;
    }
}

class LR
        is WebDriver2::Test::Service-Test
        does WebDriver2::Test::Config-From-File
{

    has ML $!mls;
    has L $!ls;
    has R $!rs;

    method new ( Str $browser? is copy, Int :$debug is copy ) {
        self.set-from-file: $browser, $debug;
        callwith
                :$browser,
                :$debug,
                sut-name => 'lr',
                name => 'lr',
                description => 'lr service and frames test',
                plan => 4;
    }

    method services ( WebDriver2::SUT::Service::Loader $loader ) {
        $!mls = ML.new: $loader;
        $!ls = L.new: $loader;
        $!rs = R.new: $loader;
    }

    method test {
        $!mls.li;
        self.is: 'main title', 'lr root', $.driver.title;

        $.driver.refresh;
        $!ls.i: 'l';
        $!rs.loaded;
        $!rs.i: 'r';
        self.is: 'l', 'l', $!ls.i;
        self.is: 'r', 'r', $!rs.i;
    }
}

sub MAIN(
        Str $browser?,
        Int :$debug
) {
    .execute with LR.new: $browser, :$debug;
}

