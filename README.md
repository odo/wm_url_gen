wm_url_gen
=====

A basic URL generator for webmachine (https://github.com/basho/webmachine/).

Building
--------

get and install rebar: https://github.com/basho/rebar

<pre>git clone git://github.com/odo/wm_url_gen.git
cd wm_url_gen
rebar compile</pre>

Usage
--------

given the dispatch rule:

<pre>{["resource", "action", "from", sender_id, "to", recipient_id], resource_module, []}</pre>

you get:
<pre>1> wm_url_gen:url_for(resource_module, [{sender_id, "the_sender_id"}, {recipient_id, "the_recipient_id"}], [{passwd, "the_password"}, {user, "the_user_"}], "the_host", 8080)).
<<"http://the_host:8080/resource/action/from/the_sender_id/to/the_recipient_id?passwd=the_password&user=the_user">></pre>

Testing
--------

eunit:
rebar eunit skip_deps=true