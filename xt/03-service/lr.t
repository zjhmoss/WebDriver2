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

    submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }

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
    
    submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }
    
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
    
    submethod BUILD ( WebDriver2::Driver:D :$!driver ) { }

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
        does WebDriver2::Test::Service-Test
        does WebDriver2::Test::Config-From-File
{

    has ML $!mls;
    has L $!ls;
    has R $!rs;

    submethod BUILD (
            Str   :$!browser,
            Str:D :$!name,
            Str:D :$!description,
            Str:D :$!sut-name,
            Int   :$!plan,
            Int   :$!debug = 0
    ) { }

    submethod TWEAK (
#			Str   :$browser is copy,
            Str:D :$name,
            Str:D :$description,
            Str:D :$sut-name,
            Int   :$plan,
            Int   :$debug
    ) {
        $!sut = WebDriver2::SUT::Build.page: { self.driver.top }, $!sut-name, debug => self.debug;
        $!loader =
                WebDriver2::SUT::Service::Loader.new:
                        driver => self.driver,
                        :$!browser,
                        :$sut-name,
                        :$debug;
    }

    method new ( Str $browser? is copy, Int :$debug is copy ) {
        self.set-from-file: $browser; # , $debug;
        my LR:D $self =
                callwith
                        :$browser,
                        :$debug,
                        sut-name => 'lr',
                        name => 'lr',
                        description => 'lr service and frames test',
                        plan => 4;
        $self.init;
        $self.services;
        $self;
    }

    method services {
        $!loader.load-elements: $!mls = ML.new: :$.driver;
        $!loader.load-elements: $!ls = L.new: :$.driver;
        $!loader.load-elements: $!rs = R.new: :$.driver;
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
        Int:D :$debug = 0
) {
    .execute with LR.new: $browser, :$debug;
}

