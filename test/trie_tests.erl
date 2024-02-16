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
    ?assertEqual(trie:find("NoKey", Trie), key_not_found),
    ?assertEqual(trie:find("Key", ?EMPTY_TRIE), structure_is_empty).

% Тест вставки
insert_test() ->
    Trie1 = trie:insert_all([{"Key", 1}, {"Ke1", 2}], ?EMPTY_TRIE),
    Trie2 = trie:insert_all([{"Ke1", 2}, {"Key", 1}], ?EMPTY_TRIE),
    ?assertEqual(trie:compare(Trie1, Trie2), true),
    New1 = trie:insert("Key", 2222, Trie1),
    New2 = trie:insert("New", 2222, Trie2),
    ?assertEqual(trie:find("Key", New1), 2222),
    ?assertEqual(trie:find("New", New2), 2222).

% Тест удаления
remove_test() ->
    Trie = trie:insert_all([{"Key", "Value"},
                            {"ABCD", "1234"},
                            {"1357", "0000"},
                            {"1", "True"},
                            {"232", "232"}],
                            ?EMPTY_TRIE),
    ?assertEqual(trie:find("1", trie:remove("1", Trie)) == "True", false).

% Property-based единственность корневого элемента
unique_root_test_case(SeqLen) ->
    Test = trie:insert_all(
        [
            {
                binary_to_list(
                    base64:encode(
                        crypto:strong_rand_bytes(
                            rand:uniform(16)))),
                rand:uniform(1000)
            }
            || _ <- lists:seq(1, SeqLen)
        ], trie:empty_trie()
    ),
    ?assertEqual(trie:compare(trie:filter_trie(fun({Key, _}) -> Key == nil end, Test),
        trie:empty_trie()), true).

monoid_root_test() ->
    [unique_root_test_case(rand:uniform(100) - 1) || _ <- lists:seq(1, 10000)].

% Property-based свойства моноида, нулевой элемент
monoid_zero_test_case(SeqLen) ->
    Test = trie:insert_all(
        [
            {
                binary_to_list(
                    base64:encode(
                        crypto:strong_rand_bytes(
                            rand:uniform(16)))),
                rand:uniform(1000)
            }
            || _ <- lists:seq(1, SeqLen)
        ], trie:empty_trie()
    ),
    Res1 = trie:merge(Test, trie:empty_trie()),
    ?assertEqual(trie:to_list(Test), trie:to_list(Res1)),
    Res2 = trie:merge(trie:empty_trie(), Test),
    ?assertEqual(trie:to_list(Test), trie:to_list(Res2)).

monoid_zero_test() ->
    [monoid_zero_test_case(rand:uniform(100) - 1) || _ <- lists:seq(1, 10000)].

% Property-based свойства моноида, ассоциативность операции merge
monoid_assoc_test_case(SeqLen1, SeqLen2, SeqLen3) ->
    Test1 = trie:insert_all(
        [
            {
                binary_to_list(
                    base64:encode(
                        crypto:strong_rand_bytes(
                            rand:uniform(16)))),
                rand:uniform(1000)
            }
            || _ <- lists:seq(1, SeqLen1)
        ], trie:empty_trie()
    ),
    Test2 = trie:insert_all(
        [
            {
                binary_to_list(
                    base64:encode(
                        crypto:strong_rand_bytes(
                            rand:uniform(16)))),
                rand:uniform(1000)
            }
            || _ <- lists:seq(1, SeqLen2)
        ], trie:empty_trie()
    ),
    Test3 = trie:insert_all(
        [
            {
                binary_to_list(
                    base64:encode(
                        crypto:strong_rand_bytes(
                            rand:uniform(16)))),
                rand:uniform(1000)
            }
            || _ <- lists:seq(1, SeqLen3)
        ], trie:empty_trie()
    ),
    ?assertEqual(trie:compare(trie:merge(Test1, Test2), trie:merge(Test2, Test1)), true),
    Merge1 = trie:merge(Test1, trie:merge(Test2, Test3)),
    Merge2 = trie:merge(trie:merge(Test1, Test2), Test3),
    ?assertEqual(trie:compare(Merge1, Merge2), true).

monoid_assoc_test() ->
    [monoid_assoc_test_case(rand:uniform(100) - 1,
                            rand:uniform(100) - 1,
                            rand:uniform(100) - 1) || _ <- lists:seq(1, 10000)].
