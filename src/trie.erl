-module(trie).

-export([empty_trie/0]).
-export([contains_key/2]).
-export([find/2]).
-export([to_list/1]).
-export([insert/3]).
-export([insert_all/2]).
-export([remove/2]).
-export([merge/2]).
-export([compare/2]).
-export([apply_to_val/2]).
-export([filter_trie/2]).
-export([map_trie/2]).
-export([foldl_trie/3]).
-export([foldr_trie/3]).

% {Key, Value, Children}
% Key - ключ для данного узла
% Value - значение, хранящееся в данном узле
% Children - список из кортежей типа {Key, Child}, где Key - символ перехода, а Child - узел-потомок

-define(KEY(Node), element(1, Node)).
-define(VALUE(Node), element(2, Node)).
-define(CHILDREN(Node), element(3, Node)).
-define(CHILD_KEY(Child), element(1, Child)).
-define(CHILD_NODE(Child), element(2, Child)).
-define(ROOT_KEY, nil).
-define(EMPTY_TRIE, {nil, nil, []}).

% Пустое дерево
empty_trie() -> ?EMPTY_TRIE.


% Поиск ветки для следующего шага вглубь
find_child(_, []) -> key_not_found;
find_child(CharKey, [Head | _]) when ?CHILD_KEY(Head) == CharKey -> ?CHILD_NODE(Head);
find_child(CharKey, [_ | Tail]) -> find_child(CharKey, Tail).


% Поиск по ключу
find(Key, Trie) -> find(Key, Key, Trie).

find(_, _, ?EMPTY_TRIE) -> structure_is_empty;
find(Key, _, {Key, Value, _}) -> Value;
find(Key, [KeyH | KeyT], {_, _, Children}) -> find(Key, KeyT, find_child(KeyH, Children));
find(_, _, Value) -> Value.


% Проверка принадлжености
contains_key(_, []) -> key_not_found;
contains_key(CharKey, [Head | _]) when ?CHILD_KEY(Head) == CharKey -> true;
contains_key(CharKey, [_ | Tail]) -> contains_key(CharKey, Tail).


% Получение списка клбчей и значений
to_list(nil) -> [];
to_list(?EMPTY_TRIE) -> [];
to_list(Trie) -> to_list(Trie, []).

to_list([], Acc) -> Acc;
to_list([{_, Node}], Acc) -> Acc ++ to_list(Node);
to_list([{_, Node} | Tail], Acc) -> (Acc ++ to_list(Node)) ++ to_list(Tail);
to_list({Key, Value, []}, Acc) -> [{Key, Value} | Acc];
to_list({nil, nil, Children}, _) -> to_list(Children);
to_list({Key, Value, Children}, Acc) -> [{Key, Value} | Acc] ++ to_list(Children).


% Проверка ключа на nil
check_nil(nil) -> [];
check_nil(Str) -> Str.


% Получение списка потомков за исключением символьного ключа
exclude_child(_, []) -> [];
exclude_child(CharKey, [{CharKey, _}]) -> [];
exclude_child(CharKey, [{CharKey, _} | Tail]) -> Tail;
exclude_child(CharKey, [Head | Tail]) -> [Head | exclude_child(CharKey, Tail)].


% Замена потомка по ключу
update_child(CharKey, {Key, Value, Children}, []) -> [{CharKey, {Key, Value, Children}}];
update_child(CharKey, {Key, Value, Children}, [{CharKey, _} | Tail]) ->
    [{CharKey, {Key, Value, Children}} | Tail];
update_child(CharKey, {Key, Value, Children}, [Head | Tail]) ->
    [Head | update_child(CharKey, {Key, Value, Children}, Tail)].


% Вставка символьной пары ключ-значение и возврат измененного узла
insert([CharKey], Value, Trie) ->
    Child = find_child(CharKey, ?CHILDREN(Trie)),
    case Child of
        key_not_found ->
            {
                ?KEY(Trie),
                ?VALUE(Trie),
                [{CharKey, {check_nil(?KEY(Trie)) ++ [CharKey], Value, []}} | ?CHILDREN(Trie)]
            };
        Otherwise ->
            {
                ?KEY(Trie),
                ?VALUE(Trie),
                update_child(CharKey, {?KEY(Child), Value, ?CHILDREN(Child)}, ?CHILDREN(Trie))
            }
    end;

insert([KeyH | KeyT], Value, Trie) ->
    Child = find_child(KeyH, ?CHILDREN(Trie)),
    case Child of
        key_not_found ->
            {
                ?KEY(Trie),
                ?VALUE(Trie),
                [{KeyH, insert(KeyT, Value,
                    {check_nil(?KEY(Trie)) ++ [KeyH],
                    nil,
                    []})} | ?CHILDREN(Trie)]
            };
        Otherwise ->
            {
                ?KEY(Trie),
                ?VALUE(Trie),
                [{KeyH, insert(KeyT, Value,
                    {check_nil(?KEY(Trie)) ++ [KeyH],
                    ?VALUE(Child),
                    ?CHILDREN(Child)})} | exclude_child(KeyH, ?CHILDREN(Trie))]
            }
    end.


% Добавление пар
insert_all([], Trie) -> Trie;
insert_all([{Key, Value}], Trie) -> insert(Key, Value, Trie);
insert_all([{Key, Value} | Tail], Trie) -> insert_all(Tail, insert(Key, Value, Trie)).


% Удаление значение по ключу (установка nil)
remove(Key, Trie) -> insert(Key, nil, Trie).


% Слияние деревьев
merge(?EMPTY_TRIE, ?EMPTY_TRIE) -> ?EMPTY_TRIE;
merge(?EMPTY_TRIE, RTrie) -> RTrie;
merge(LTrie, ?EMPTY_TRIE) -> LTrie;
merge(LTrie, []) -> LTrie;
merge(LTrie, [{Key, Value}]) -> insert(Key, Value, LTrie);
merge(LTrie, [{Key, Value} | Tail]) -> merge(insert(Key, Value, LTrie), Tail);
merge(LTrie, RTrie) -> merge(LTrie, to_list(RTrie)).


% Проверка эквивалентности (true/false)
compare(?EMPTY_TRIE, ?EMPTY_TRIE) -> true;
compare(_, ?EMPTY_TRIE) -> false;
compare(?EMPTY_TRIE, _) -> false;
compare([LH | LT], [RH | RT]) -> lists:sort([LH | LT]) =:= lists:sort([RH | RT]);
compare(LTrie, RTrie) -> compare(to_list(LTrie), to_list(RTrie)).


% Применение функции к Value списка
apply_to_val(_, []) -> [];
apply_to_val(Func, [{Key, Value}]) -> [{Key, Func(Value)}];
apply_to_val(Func, [{Key, Value} | Tail]) -> [{Key, Func(Value)} | apply_to_val(Func, Tail)].


% Получение из списка пар только списка значений
get_values([]) -> [];
get_values([{_, Value}]) -> [Value];
get_values([{_, Value} | Tail]) -> [Value | get_values(Tail)].


% Фильтрация по Func = fun({Key, Value}) -> ... end
filter_trie(Func, Trie) -> insert_all(lists:filter(Func, to_list(Trie)), ?EMPTY_TRIE).


% Отображение по Func = fun(Value) -> ... end
map_trie(Func, Trie) -> insert_all(apply_to_val(Func, to_list(Trie)), ?EMPTY_TRIE).


% Левая свертка по Func = fun(Value) -> ... end
foldl_trie(Func, Acc, Trie) ->
    insert_all(lists:foldl(Func, Acc, get_values(to_list(Trie))), ?EMPTY_TRIE).


% Правая свертка по Func = fun(Value) -> ... end
foldr_trie(Func, Acc, Trie) ->
    insert_all(lists:foldr(Func, Acc, get_values(to_list(Trie))), ?EMPTY_TRIE).
