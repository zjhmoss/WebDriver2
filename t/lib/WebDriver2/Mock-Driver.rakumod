use WebDriver2;

use WebDriver2::Command::Element::Locator;

unit class  WebDriver2::Mock-Driver does WebDriver2;

method start { !!! }

method session { !!! }
method status { !!! }

method maximize-window { !!! }
method set-window-rect( Int $width, Int $height, Int $x, Int $y ) { !!! }

method navigate( Str:D $url ) { !!! }
method refresh { !!! }
method title( --> Str:D ) { !!! }

method alert-text( --> Str:D ) { !!! }
method accept-alert { !!! }
method dismiss-alert { !!! }
method send-alert-text( Str:D ) { !!! }

multi method screenshot( WebDriver2: --> Str:D ) { !!! }
multi method screenshot( WebDriver2::Model::Element:D $element --> Str:D ) { !!! }

multi method element(
        WebDriver2::Command::Element::Locator:D $locator
        --> WebDriver2::Model::Element:D
) { !!! }
multi method element(
		WebDriver2::Model::Context:D $context,
        WebDriver2::Command::Element::Locator:D $locator
        --> WebDriver2::Model::Element:D
) { !!! }
multi method elements(
        WebDriver2::Command::Element::Locator:D $locator
        --> Array of WebDriver2::Model::Element
) { !!! }
multi method elements(
		WebDriver2::Model::Context:D $context,
        WebDriver2::Command::Element::Locator:D $locator
        --> Array of WebDriver2::Model::Element
) { !!! }
method execute-script( Str:D, Str @ ) { !!! }
method active( --> WebDriver2::Model::Element:D ) { !!! }
method tag-name( WebDriver2::Model::Element:D $element --> Str:D ) { !!! }
method frame( WebDriver2::Model::Element:D $element --> WebDriver2::Model::Frame:D ) { !!! }
method property(
		WebDriver2::Model::Element:D $element,
        Str:D $property
        --> Str
) { !!! }
method attribute(
		WebDriver2::Model::Element:D $element,
        Str:D $attribute
        --> Str
) { !!! }
method displayed ( WebDriver2::Model::Element:D $element ) { !!! }
method text( WebDriver2::Model::Element:D $element --> Str:D ) { !!! }
method id( WebDriver2::Model::Element:D $element --> Str ) { !!! }
method value( WebDriver2::Model::Element:D $element --> Str ) { !!! }
method enabled( WebDriver2::Model::Element:D $element --> Bool:D ) { !!! }
method selected( WebDriver2::Model::Element:D $element --> Bool:D ) { !!! }
method css-value(
		WebDriver2::Model::Element:D $element,
        Str:D $property
        --> Str
) { !!! }
method send-keys( WebDriver2::Model::Element:D $element, Str:D $keys ) { !!! }
method clear ( WebDriver2::Model::Element:D $element ) { !!! }
method click( WebDriver2::Model::Element:D $element ) { !!! }
multi method switch-to( WebDriver2::Model::Frame:D $frame ) { !!! }
multi method switch-to( Int:D $frame ) { !!! }
method timeouts( Int :$script, Int :$pageLoad, Int :$implicit ) { !!! }
method switch-to-parent { !!! }
method top { !!! }
method curr-frame( --> WebDriver2::Command::Param::ID-or-Index ) { !!! }
method window-handles { !!! }
method new-window { !!! }
method close-window { !!! }
method switch-to-window { !!! }
method window-handle { !!! }

method url { !!! }

method delete-session { !!! }

method stop { !!! }