use v6;

use Cro::HTTP::Router;
use Cro::HTTP::Server;

my $application = route {
	get -> 'iframe' {
		sleep 3;
		content 'text/html', q:to/END/;
<html><head><title>iframe test</title></head>
	<body>
		<form>
			<input type="text" id="text"/>
			<input type="checkbox" id="iframe-cb"/>
		</form>
	</body>
</html>
END
	}
}

my Cro::Service $hello = Cro::HTTP::Server.new:
	:host<localhost>, :port<10000>, :$application;

$hello.start;

react whenever signal(SIGINT) { $hello.stop; exit; }

