use Test;
use MIME::Base64;

use WebDriver2;
use WebDriver2::Driver::Chrome;
use WebDriver2::Driver::Edge;
use WebDriver2::Driver::Firefox;
use WebDriver2::Driver::Safari;

my WebDriver2 %driver = (
		chrome => WebDriver2::Driver::Chrome,
		edge => WebDriver2::Driver::Edge,
		firefox => WebDriver2::Driver::Firefox,
		safari => WebDriver2::Driver::Safari
);

my WebDriver2 $driver;

unit role WebDriver2::Driver::Provider;

#method os ( --> Str:D ) { ... }
method browser ( --> Str:D ) { ... }
method debug ( --> Int ) { ... }

method driver ( --> WebDriver2:D ) {
	$driver //= %driver{ $.browser }.new: :$.debug;
}
