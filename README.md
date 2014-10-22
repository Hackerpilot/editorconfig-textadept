# editorconfig-textadept
[EditorConfig](http://editorconfig.org/) plugin for [Textadept](http://foicica.com/textadept/).

### Installation
* Clone this repository.
* Copy or symlink the editorconfig.lua file into your ".textadept" folder.
* add ```require "editorconfig"``` to your ".textadept/init.lua" file.

### What works
* *, **, ?, [], and [!] style section headers
* Tests
	* indentation tests
	* end\_of\_line tests
* Properties
	* indent\_style
	* indent\_size
	* tab\_width
	* end\_of\_line
	* root

### What doesn't work
* {}-style section headers
* Tests
	* insert\_final\_newline tests
	* trim\_trailing\_whitespace tests
	* charset tests
* Properties
	* trim\_trailing\_whitespace
	* charset
	* insert\_final\_newline
