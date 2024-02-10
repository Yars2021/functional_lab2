# Лабораторная работа №2

Вариант: Prefix Tree Dict

Цель: освоиться с построением пользовательских типов данных, полиморфизмом, рекурсивными алгоритмами и средствами тестирования (unit testing, property-based testing).
В рамках лабораторной работы вам предлагается реализовать одну из предложенных классических структур данных (список, дерево, бинарное дерево, hashmap, граф...).
Требования:

Функции:

1. добавление и удаление элементов;
   + фильтрация; 
   + отображение (map); 
   + свертки (левая и правая); 
   + структура должна быть моноидом.

1. Структуры данных должны быть неизменяемыми.
1. Библиотека должна быть протестирована в рамках unit testing.
1. Библиотека должна быть протестирована в рамках property-based тестирования (как минимум 3 свойства, включая свойства моноида).
1. Структура должна быть полиморфной.
1. Требуется использовать идиоматичный для технологии стиль программирования. Примечание: некоторые языки позволяют получить большую часть API через реализацию небольшого интерфейса. Так как лабораторная работа про ФП, а не про экосистему языка -- необходимо реализовать их вручную и по возможности -- обеспечить совместимость.

Содержание отчёта:

- титульный лист;
- требования к разработанному ПО;
- ключевые элементы реализации с минимальными комментариями;
- тесты, отчет инструмента тестирования, метрики;
- выводы (отзыв об использованных приёмах программирования).

---

## Выполнение

Реализация словаря:
[trie.erl](src/trie.erl)


Тесты:
[trie_tests.erl](test/trie_tests.erl)

Свойства проверяемые в property-based тестах:
1. Корневой элемент (с ключом nil) единственный во всем дереве.
2. Получивший словарь на префиксном дереве — моноид, нулевым элементом является {nil, nil, []}.
3. Получивший словарь на префиксном дереве — моноид, merge(A, merge(B, C)) == merge(merge(A, B), C).

Более подробно в комментариях в коде.

## Выводы

Было реализовано префиксное дерево на Erlang, я впервые реализовал какую-то структуру данных, используя функциональный язык. Я р азобрался в свойствах структуры и в свойствах, которыми должен обладать моноид, и на основе этого сделал property-based тесты для кода.
