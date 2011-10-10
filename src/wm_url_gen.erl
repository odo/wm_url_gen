-module (wm_url_gen).
-export ([url_for/5]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-type proplist()::[{atom(), string()}].

-spec url_for(Resource :: atom(), Arguments :: proplist(),  Parameters :: proplist(), Host :: string(), Port :: pos_integer()) -> binary().
url_for(Resource, Arguments, Parameters, Host, Port) ->
	DispatchList = proplists:get_value(dispatch_list, application:get_all_env(webmachine)),
	MatchingRules = [Rule || Rule = {_, Res, _} <- DispatchList, Res =:= Resource],
	Rule = case MatchingRules of
		[] ->
			throw({no_matching_rule_found, Resource});
		[OneRule] ->
			OneRule;
		_ ->
			throw({several_matching_rules_found, Resource, MatchingRules})
	end,
	{Templates, _, _} = Rule,
	Elements = [replace_element(Template, Arguments) ||Template <- Templates],
	PortString = case Port of
		80 ->
			"";
		_ ->
			lists:flatten([":", integer_to_list(Port)])
	end,
	list_to_binary(string:join(["http:/" | [string:concat(Host, PortString) | Elements]], "/") ++ paramter_str(Parameters)).

replace_element(Template, _Arguments) when is_list(Template) ->
	Template;
	
replace_element(Template, Arguments) ->
	Val = proplists:get_value(Template, Arguments),
	case Val of
		_ when is_binary(Val) ->
			binary_to_list(Val);
		_ ->
			Val
	end.
	
paramter_str([]) ->
	"";

paramter_str(Params) ->
	"?" ++ mochiweb_util:urlencode(Params).


-ifdef(TEST).

url_for_test() ->
	Dispatch = [{["resource", "action", "from", sender_id, "to", recipient_id], resource_module, []}],
	application:set_env(webmachine, dispatch_list, Dispatch),
	?assertEqual(
		<<"http://the_host/resource/action/from/the_sender_id/to/the_recipient_id">>,
		?MODULE:url_for(resource_module, [{sender_id, "the_sender_id"}, {recipient_id, "the_recipient_id"}], [], "the_host", 80)),
	?assertEqual(
		<<"http://the_host:8080/resource/action/from/the_sender_id/to/the_recipient_id?passwd=the_password&user=Rico+%C3%9Cmlaut">>,
		?MODULE:url_for(resource_module, [{sender_id, "the_sender_id"}, {recipient_id, "the_recipient_id"}], [{passwd, "the_password"}, {user, "Rico Ümlaut"}], "the_host", 8080)).

-endif.
