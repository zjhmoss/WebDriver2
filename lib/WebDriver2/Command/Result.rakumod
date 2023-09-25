use WebDriver2::Command::Execution-Status;

role WebDriver2::Command::PreResult {
	has Str $.str;
	method Str( --> Str ) { $!str }
}

role WebDriver2::Command::Result does WebDriver2::Command::PreResult {
	
	has WebDriver2::Command::Execution-Status $.execution-status;
	
}

class WebDriver2::Command::Result::Single-Value does WebDriver2::Command::Result {
	has Str $.value;
	submethod BUILD( :$!str, :$!execution-status, :$!value ) { }
}

class WebDriver2::Command::Result::Bool-Value does WebDriver2::Command::Result {
	has Bool $.value;
	submethod BUILD( :$!str, :$!execution-status, :$!value ) { }
}

role WebDriver2::Command::Result::List-Value[::T] does WebDriver2::Command::Result {
	has T @.values;
}

class WebDriver2::Command::Result::Str-Hash-Value does WebDriver2::Command::Result {
	has %.values;
}

class WebDriver2::Command::Result::Accept-Alert does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Active is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Alert-Text is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Attribute is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Back is WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Clear does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Click does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::CSS-Value is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Delete-Session does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Dismiss-Alert is WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Displayed is WebDriver2::Command::Result::Bool-Value { }
class WebDriver2::Command::Result::Element is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Element-Screenshot is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Elements does WebDriver2::Command::Result::List-Value[Str] { }
class WebDriver2::Command::Result::Element-Rect does WebDriver2::Command::Result {
	has Int $.x;
	has Int $.y;
	has Int $.width;
	has Int $.height;

}
class WebDriver2::Command::Result::Enabled is WebDriver2::Command::Result::Bool-Value { }
class WebDriver2::Command::Result::Execute-Script is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Forward is WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Maximize-Window does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Navigate does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Property does WebDriver2::Command::Result {
	subset Prop-Val where * ~~ Str | Bool;
	has Prop-Val $.value;
}
role WebDriver2::Command::Result::Refresh does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Screenshot is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Selected is WebDriver2::Command::Result::Bool-Value { }
class WebDriver2::Command::Result::Send-Alert-Text is WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Send-Keys does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Session is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Set-Window-Rect does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Status does WebDriver2::Command::PreResult {
	has Str $.version;
	has Bool $.ready;
	has WebDriver2::Command::Execution-Status $.execution-status;
	has Str $.message;
}

class WebDriver2::Command::Result::Switch-to-Window is WebDriver2::Command::Result { }
class WebDriver2::Command::Result::New-Window is WebDriver2::Command::Result::Str-Hash-Value { }
class WebDriver2::Command::Result::Close-Window is WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Window-Handle is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Window-Handles does WebDriver2::Command::Result::List-Value[Str] {  }
class WebDriver2::Command::Result::SubElement is WebDriver2::Command::Result::Element { }
class WebDriver2::Command::Result::SubElements does WebDriver2::Command::Result::List-Value[Str] { }
class WebDriver2::Command::Result::Switch-To does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Switch-To-Parent does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Tag-Name is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Text is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::Timeouts does WebDriver2::Command::Result { }
class WebDriver2::Command::Result::Title is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::URL is WebDriver2::Command::Result::Single-Value { }
class WebDriver2::Command::Result::X is Exception {
	has WebDriver2::Command::Execution-Status $.execution-status;
	method message( WebDriver2::Command::Result::X:D: --> Str ) {
		~ $!execution-status
	}
}
