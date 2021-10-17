[//]: # (This file was autogenerated from the man page with 'make README.md')

# hx(1) - log files highlighter

[![Build Status](https://travis-ci.org/mle86/hx.svg?branch=master)](https://travis-ci.org/mle86/hx)


Version 0.25.0, October 2021

<pre><code><b>hx</b> [<i>OPTIONS</i>] [<i>LOGFILE</i>...]</code></pre>

#### Screenshots

**Apache logs,** original vs. colored with hx:

[<img alt="Apache2 logs, original" src="/doc/img/apache0.png" width="49%">](/doc/img/apache0.png)
[<img alt="Apache2 logs using hx" src="/doc/img/apache1.png" width="49%">](/doc/img/apache1.png)

**Syslog:**

[<img alt="Syslog, original" src="/doc/img/syslog0.png" width="49%">](/doc/img/syslog0.png)
[<img alt="Syslog using hx" src="/doc/img/syslog1.png" width="49%">](/doc/img/syslog1.png)


→ [More Screenshots](/doc/Screenshots.md)



<a name="description"></a>

# Description

**hx** is a log files highlighter.

Its main purpose is to make long log files
with long lines
easier to grasp at a glance
through simple, consistent coloring.

It will never change any of its input
besides adding ANSI color sequences to it
(with two exceptions:
it will add a very visible dot
at the start of every line
for better visual line separation,
and it will add a dashed separator line
once after the stdin input pauses
for better visual separation
between “old” and “new” lines).

It understands a few more or less commonly-used log entry formats,
most importantly the standard **syslog** format.
Apart from that, it can guess some less-defined formats
such as a leading timestamp
or a trailing error source filename.

It is well suited for handling running logs
such as returned by “**tail&nbsp;-f /var/log/syslog**”.

<a name="installation"></a>

# Installation

```
# make install
```

This will copy the hx script to <code>/usr/local/bin/<b>hx</b></code>
and the man page to <code>/usr/local/share/man/man1/<b>hx.1</b>.gz</code>.
The script's internal modules
will be copied to `/usr/local/lib/hx-modules/`.



<a name="options"></a>

# Options


* **--ecma48**  
  Forces the program to output only basic, ECMA-48-compatible ANSI coloring codes.
  This will lead to less colorful output
  but should increase compatibility
  in case your terminal does not support the extended coloring sequences.

<a name="output"></a>

# Output

**hx** makes extensive use of ANSI coloring sequences,
including the “**CSI&nbsp;38;5;**_n_&nbsp;**m**” sequence
for extended color selection
and the “**CSI&nbsp;38;2;**_r_**;**_g_**;**_b_&nbsp;**m**” sequence
for RGB true-color selection.
They may not be supported by all terminals currently in use.
Use the **--ecma48** option
if you want **hx** to use ECMA-48-compatible ANSI sequences only.
This will lead to less colorful output
but should increase compatibility.
Alternatively, the
[_HX_COLORS_ environment variable](#hx_colors-environment-variable)
can be used
to manually set all coloring to compatible sequences.

The default colors are optimized for a black terminal background.

<a name="coloring-rationale"></a>

### Coloring Rationale

Generally the program tries to identify to the main log message part
and print it in the terminal's _default color_ (white).
All other parts of the log message will be colored differently
to visually separate them:
the metadata prefix will be _yellow_,
additional information at the end will be _grey_,
and additional information
between the yellow metadata prefix and the white message
will be _yellowish-grey_.

The following sections
list typical log line parts
and how they fit into these broader categories.

<a name="metadata-prefix"></a>

### Metadata Prefix

Most log lines start with metadata.
The program will color all of it _yellow_.
This includes the
**timestamp**,
the
**application name**
and/or
**PID**,
the
**hostname**,
the
**username**,
and the
**log level**.

<a name="informational-prefix"></a>

### Informational Prefix

This is log metadata considered non-essential
or additional information
located between the log metadata prefix and the message content,
including
syslog **message IDs**,
**client addresses** and **usernames**,
or
RFC-5424 **structured data**.
It'll be colored _yellowish-grey_.

<a name="log-message"></a>

### Log Message

The only part which will be printed in the terminal's
_standard&nbsp;color_ (usually _white_),
this is the actual log message content.
Any recognized
**exception class name** prefix
or
**error code** prefix
will also be _bolded_.

<a name="informational-suffix"></a>

### Informational Suffix

This is data considered non-essential to the log message,
including 
**bracketed suffixes**,
error source **file/lineno**,
**stack traces**,
and
**JSON error data**.

<a name="others"></a>

### Others


* Additionally, all “informational” sections
  may contain HTTP status codes
  which will be colored appropriately:
  1xx&nbsp;Info/​3xx Redirection&nbsp;= _yellow_,
  2xx&nbsp;Success&nbsp;= _green_,
  4xx&nbsp;Client Error&nbsp;= _red_,
  5xx&nbsp;Server Error&nbsp;= _pink_.
* Similar coloring will be applied to Postfix DSN codes.
* JSON object keys will be _bolded_.
* File basenames will be _bolded_.
* The syslog prefix “message repeated N times: [”
  will be colored _blue_.

<a name="hx_colors-environment-variable"></a>

# HX_COLORS Environment Variable

The _HX_COLORS_ environment variable, if set and non-empty,
is read on start-up for color definitions
which will overwrite the default colors
(described in the
“[Output](#output)”
section above).

The variable supports section—color assignments
like this: “**ap=38;5;90**”.
This assigns the ANSI color 38;5;90 (dark violet)
to the _ap_ section (app name/PID).

Multiple assignments must be separated with colons (**:**).
Multiple assignments to the same section overwrite earlier assignments.
If the equals sign is not followed by a digit, the trailing part is assumed to be a section name;
for example, “**ap=hn**” assigns the _hn_ (hostname) color to _ap_ (app/PID).
The special section name “<b>\*</b>”
assigns a color definition
to all sections not previously assigned in the variable.

<a name="valid-sections"></a>

### Valid sections:


* **SY**  
  The line-start symbol in case of a normal line.
* **ML**  
  The line-start symbol in case of a meta line (such as “tail&nbsp;-f” filename headers).
  Also the meta line content.
* **CL**  
  The line-start symbol in case of a continuation line.
* **RP**  
  Syslog repeated message wrapper.
* **FS**  
  Separator line on input read pause.
* **dt**  
  Date/time.
* **ap**  
  Application name or process ID (PID).
* **hn**  
  Source hostname.
* **ix**  
  Informational message prefix.
* **in**  
  Informational message suffix.
* **le**  
  Log levels _error_ and higher.
* **lw**  
  Log levels _warning_ and higher.
* **ll**  
  All other log levels.
* **ms**  
  Message content.
* **er**  
  Error class name or error code.
* **eq**  
  Error class namespace.
* **tr**  
  Stack traces
  and error source (file/lineno).
* **st**  
  Exception stacks.
* **sm**  
  Exception stack single messages (only if more than one).
* **fl**  
  File basenames and/or line numbers.
* **fn**  
  Function names (in stack traces).
* **jw**  
  Top-level JSON enclosure characters ([] or {}).
* **ke**  
  Keys in key—value structures such as JSON.
* **h1**  
  HTTP&nbsp;1xx status codes (Informational).
* **h2**  
  HTTP&nbsp;2xx status codes (Success).
* **h3**  
  HTTP&nbsp;3xx status codes (Redirection).
* **h4**  
  HTTP&nbsp;4xx status codes (Client Error).
* **h5**  
  HTTP&nbsp;5xx status codes (Server Error).
* **h6**  
  HTTP&nbsp;4xx status codes considered less important,
  such as HTTP&nbsp;404&nbsp;Not Found.
* <b>*</b>  
  All sections not previously assigned.

<a name="defaults"></a>

### Defaults

By default,
**hx** produces output
as if it had been given
this _HX_COLORS_ value:

**SY**=33:​**CL**=38;2;113;97;25:​**ML**=38;2;114;204;204:​**FS**=32;2:​**RP**=34:​**dt**=SY:​**hn**=SY:​**ap**=SY:​**ms**=0:​**ll**=SY:​**lw**=38;5;220:​**le**=38;2;255;145;36:​**in**=38;5;243:​**ix**=38;2;125;117;83:​**tr**=in:​**st**=in:​**sm**=ms:​**eq**=ms:​**er**=1:​**fl**=1:​**fn**=1:​**jw**=1:​**ke**=1:​**h1**=38;2;202;214;98:​**h2**=38;2;98;214;113:​**h3**=h1:​**h4**=38;2;235;41;41:​**h5**=38;5;199;1:​**h6**=38;2;155;72;72

When using the **--ecma48** option,
**hx** uses output settings
equivalent to these _HX_COLORS_ settings:

**SY**=33:​**CL**=33;2:​**ML**=36:​**FS**=32;2:​**RP**=34:​**dt**=SY:​**hn**=SY:​**ap**=SY:​**ms**=0:​**ll**=33:​**lw**=33;1:​**le**=33;1:​**in**=37;2:​**ix**=in:​**tr**=in:​**st**=in:​**sm**=ms:​**eq**=ms:​**er**=1:​**fl**=1:​**fn**=1:​**jw**=1:​**ke**=1:​**h1**=33:​**h2**=32:​**h3**=h1:​**h4**=31;1:​**h5**=31;1:​**h6**=31

<a name="hx_settings-environment-variable"></a>

# HX_SETTINGS Environment Variable

The _HX_SETTINGS_ environment variable,
if set and non-empty,
is read on start-up
to change various run-time settings.

Boolean options can be switched on simply by including their option keyword
and switched off by prefixing them with “**no**”.
For example, the **--ecma48** compatibility output mode
is enabled by adding the “_ecma48_” keyword
to the variable
and explicitly disabled
by adding the “_noecma48_” keyword.
Some options take an optional or required value;
supply it after an equals sign (**=**).
Option values may be enclosed with doublequotes (**"**).
This is required for values which contain spaces or doublequotes
(which must be escaped with backslashes).
Multiple option keywords must be separated by one or more spaces.

<a name="supported-options"></a>

### Supported options:


* **ecma48**, **48**  
  Enables the compatibility output mode.
  Equivalent to the **--ecma48** command line option.  
  Default: disabled.
* **pausewait**[**=**_delay_], **pw**  
  Enables printing the separator line once
  as soon as the input pauses for at least _delay_ milliseconds.
  (The _delay_ default is **200** if missing.)
  Has no effect if **pausesep** is unset.  
  Default: enabled, 200ms.
* **pausesep**[=_char_], **ps**  
  Enables printing the separator line once
  as soon as the input pauses for several milliseconds.
  The line will consist of this _char_,
  repeated until the terminal line is filled.
  (The _char_ default is "**⁻**" if missing.)
  Has no effect if **pausewait** is unset.
* **lineprefix**=_symbol_, **px**  
  Enables or disables line prefixes
  for all line types at once.
  See **loglineprefix**,
  **metalineprefix**,
  and **contlineprefix** below.  
  Default: enabled, "● ".
* **loglineprefix**=_symbol_, **lp**  
  Line prefix string for regular output lines.
  (See **lineprefix**.)
* **contlineprefix**=_symbol_, **cp**  
  Line prefix string for continuation lines.
  (See **lineprefix**.)
* **metalineprefix**=_symbol_, **mp**  
  Line prefix string for meta lines.
  (See **lineprefix**.)

<a name="defaults"></a>

### Defaults:

By default,
**hx** produces output
as if it had been given
this _HX_SETTINGS_ value:

**px**="● " **ps**="⁻" **pw**=200 **no48** 


<a name="standards"></a>

# Standards

_Control Functions for Character-Imaging I/O Devices_,
[Standard ECMA-48](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-48,%202nd%20Edition,%20August%201979.pdf),
August 1979.

<a name="see-also"></a>

# See Also

**tail**(1),
**console_codes**(4).
