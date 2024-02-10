-module(trie_tests).

-include_lib("eunit/include/eunit.hrl").

-define(EMPTY_TRIE, {nil, nil, []}).

% Тест пустого дерева
empty_tree_test() -> ?assertEqual(trie:empty_trie(), ?EMPTY_TRIE).

% Тест поиска
find_test() ->
    Trie = trie:insert_all([{"Key", "Value"},
                            {"ABCD", "1234"},
                            {"1357", "0000"},
                            {"1", "True"}],
                            ?EMPTY_TRIE),

    ?assertEqual(trie:find("Key", Trie), "Value"),
    ?assertEqual(trie:find("ABCD", Trie), "1234"),
    ?assertEqual(trie:find("1357", Trie), "0000"),
    ?assertEqual(trie:find("1", Trie), "True"),
    ?assertEqual(trie:find("Key", ?EMPTY_TRIE), key_not_found).

% Тест вставки
insert_test() ->
    Trie1 = trie:insert_all([{"Key", 1}, {"Ke1", 2}], ?EMPTY_TRIE),
    Trie2 = trie:insert_all([{"Ke1", 2}, {"Key", 1}], ?EMPTY_TRIE),
    ?assertEqual(trie:compare(Trie1, Trie2), true),
    trie:insert("Key", 2222, Trie1),
    trie:insert("New", 2222, Trie2),
    ?assertEqual(trie:find("Key", Trie1), 2222),
    ?assertEqual(trie:find("New", Trie2), 2222).

% Property-based единственность корневого элемента
unique_root_test() ->
    Trie = trie:insert_all([{"Key", "Value"},
                            {"ABCD", "1234"},
                            {"1357", "0000"},
                            {"1", "True"},
                            {"232", "232"}],
                            ?EMPTY_TRIE),
    trie:remove("1", Trie),
    Filtered = trie:filter_trie(fun({Key, _}) -> Key == nil end, Trie),
    ?assertEqual(Filtered, ?EMPTY_TRIE).

% Property-based свойства моноида, операции с нулевым элементом
monoid_zero_test() ->
    Trie = trie:insert_all([{"Key", "Value"},
                            {"ABCD", "1234"},
                            {"1357", "0000"},
                            {"1", "True"},
                            {"232", "232"}],
                            ?EMPTY_TRIE),
    ?assertEqual(trie:compare(?EMPTY_TRIE, ?EMPTY_TRIE), true),
    ?assertEqual(trie:compare(?EMPTY_TRIE, Trie), false),
    ?assertEqual(trie:compare(Trie, ?EMPTY_TRIE), false),
    ?assertEqual(trie:compare(trie:merge(Trie, ?EMPTY_TRIE), Trie), true),
    ?assertEqual(trie:compare(trie:merge(?EMPTY_TRIE, Trie), Trie), true).
