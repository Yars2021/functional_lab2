-module(trie_tests).

-include_lib("eunit/include/eunit.hrl").

-define(EMPTY_TREE, {nil, nil, []}).

% Тест пустого дерева
empty_tree_test() -> ?assertEqual(trie:empty_tree(), ?EMPTY_TRIE).
