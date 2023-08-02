enum WebDriver2::Command::Execution-Status::Type
	<OK
		Method
		Intercepted Interactable
		Alert Element Frame Window
		Stale Timeout Unexpected
		Session
	Unimplemented>;

class WebDriver2::Command::Execution-Status {
	
	has Cool $.code;
	# TODO : implement OS data ?
	has WebDriver2::Command::Execution-Status::Type $.type;
	has Str $.message;
	
	method Str( --> Str ) {
		"$!type\n$!message";
	}
	
}
