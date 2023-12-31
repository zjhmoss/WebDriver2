unit role WebDriver2::Test::Config-From-File;

my IO::Path $browser-file = $*PROGRAM.parent.parent.add: 'browser';
my IO::Path $debug-file = $*PROGRAM.parent.parent.add: 'debug';

method set-from-file ( Str $browser is rw, IO::Path :$test-root = $*CWD.add: 't'  #`[, Int $debug is rw ] ) {
    unless $browser {
        die 'must provide valid browser argument or specify in browser file'
            unless $test-root.add( 'browser' ).e;
        $browser = .trim.lc with $browser-file.slurp: :close;
    }
}
