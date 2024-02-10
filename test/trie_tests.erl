-module(trie_tests).

-include_lib("eunit/include/eunit.hrl").

-define(EMPTY_TRIE, {nil, nil, []}).

% Тест пустого дерева
empty_tree_test() -> ?assertEqual(trie:empty_tree(), ?EMPTY_TRIE).

% Тест поиска
find_test() ->
    Trie = insert_all([{"Key", "Value"},
                       {"ABCD", "1234"},
                       {"1357", "0000"},
                       {"1", "True"}],
                       ?EMPTY_TRIE),

    ?assertEqual(trie:find("Key", Trie), "Value"),
    ?assertEqual(trie:find("ABCD", Trie), "1234"),
    ?assertEqual(trie:find("1357", Trie), "0000"),
    ?assertEqual(trie:find("1", Trie), "True"),
    ?assertEqual(trie:find("Key", ?EMPTY_TRIE), key_not_found).
