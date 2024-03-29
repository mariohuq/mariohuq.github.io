# Тема XIII. Обобщенное программирование

## Идеи обобщенного программирования. Зачем нужны шаблоны. Понятия, связанные с шаблонами

При создании программ довольно часто приходится писать множество
одинаковых фрагментов для обработки разных типов данных. Например:

Функция выполняет одни и те же действия, текст на языке высокого
уровня будет одинаковым, но низкоуровневый код будет зависеть от типов
параметров.

```cpp
Т min(T х, Т у); //под Т можно подразумевать int, double, Point... -
                 //в зависимости от типа параметров компилятор 
                 //сгенерирует разные низкоуровневые команды!!!
```

Данные класса отличаются только типом, а реализация методов на языке
высоко уровня выглядит одинаково:

```cpp
class Point
{
    T х, у; //int, double, MyComplex... в зависимости от типа 
            //параметров компилятор будет резервировать разное 
            //количество памяти при создании объекта типа Point и 
            //генерировать разные тела методов класса
};
```

С помощью ключевого слова `template` на C++ можно задать компилятору
образец кода для некоторого обобщенного типа данных — шаблон.
Используя «скелет» кода, компилятор сам сгенерирует конечный код для
конкретного типа данных.

![](media/image59.svg)

### Объявление шаблона (общее)

> ```cpp
> template <список_параметров_шаблона>
>     объявление_функции_или_класса,
> ```

где `список_параметров_шаблона` — это разделенные запятой параметры
шаблона (где фигурирует один или несколько параметров обобщенного
типа). Параметры шаблона обозначают в общем случае **«отличающиеся»**
части того кода, который будет сгенерирован компилятором по данному
шаблону (это могут быть обобщенные типы данных, константы, а также
«вложенные» шаблоны). **Могут иметь значения по умолчанию!**

![](media/image60.svg)

Замечания:

1)  без явного (`explicit`) указания при объявлении шаблона
    компилятор
    не создает никакого кода, шаблон является просто заготовкой для
    компилятора. Только встретив обращение к данному шаблону (вызов
    функции или создание экземпляра класса и вызов его методов) в
    тексте программы, компилятор сгенерирует соответствующий код.

2)  ключевого слово typename рекомендуется использовать вместо
    старого
    `class` (в ранних версиях ключевого слова typename просто не было).
    Пока нет причин, почему бы следовало использовать `typename`, но оно
    выглядит понятнее (не ассоциируются только с понятием `class`).

3)  в качестве обобщенного типа можно задать как имя сложного
    пользовательского типа данных (класс), так и простой (базовый) тип

4)  можно задать параметры шаблона по умолчанию. Например:

    ```cpp
    template<typename A, typename В = А> ...
    ```

### Термины, связанные с шаблонами

Процесс генерации компилятором как функции (тела), так и объявления
класса по шаблону и списку параметров шаблона называется
инстанцированием. Например, когда компилятор в первый раз встречает
вызов функции-шаблона, он создает соответствующий код (именно для
указанных в качестве параметров шаблона типов данных) — это неявное
инстанцирование. Далее, если компилятор встречает вызов функции с теми
же типами параметров, он просто генерирует вызов к уже созданному телу
функции Более того, если даже такие вызовы находятся в разных единицах
компиляции, только одна копия тела функции будет включена в
исполняемый файл.

Версия шаблона для конкретного набора аргументов называется
специализацией.

## Шаблоны функций

### Способы обобщения функций, выполняющих одинаковые действия, но оперирующих данными разных типов

Если функция, оперируя данными разного типа, выполняет одинаковые по
смыслу действия, удобно и логично для такой функции иметь одно и то же
имя. Такую возможность можно реализовать двумя способами (рассмотрим
на примере функции, возвращающей минимальное из двух заданных
значений):

1)  с помощью «перегрузки» функций. При этом программист должен
    объявить и определить нужное количество функций с одним и тем же
    именем, которые в нашем примере отличаются только типом
    параметров:

    ```cpp
    //min for ints
    int min(int a, int b) { return (a < b) ? a : b; }
    //min for doubles
    double min(double a, double b) { return (a < b) ? a : b; }
    //etc...
    ```

    При этом компилятор сгенерирует в точке вызова функции min() вызов
    одной из определенных функций в зависимости от типа параметров:

    ```cpp
    {
        int iX = 1000, iY = 500;
        int iResult = min(iX, iY); //вызов min(int, int)
        double dX = 1.0, dY = 3;
        double dResult = min(dX, dY); //вызов min (double, double)
    }
    ```

2)  с помощью макроподстановки

    ```cpp
    #define min(a,b) (a < b) ? a : b
    ```

    Что гораздо «опаснее», так как макроподстановка — это всего лишь
    подстановка текста препроцессором

    a)  типы параметров `a` и `b` макроса могут быть разными, ⇒ 
        компилятор
        может неявно привести типы так, как посчитает нужным, или не
        сможет привести и выдаст ошибку, но покажет на ошибку в теле
        макроса (и разобраться в чем дело будет достаточно трудно)

    b)  некоторых «неожиданностей» при использовании макросов можно
        избежать с помощью скобок `(a) < (b) ? (a) : (b)` — например: без
        скобок вызов макро `min(x & y, z)` препроцессор превратит в
        `х & (у < b)`. а задумано было `(х & у) < b`

    c)  некоторых побочных эффектов даже при использовании скобок
        избежать не удастся:

        ```cpp
        int r = min(a++, b++); //превратится в
                               //(a++) < (b++) ? (a++) : (b++)
        ```

3)  с помощью шаблона функции можно

    a)  уменьшить количество «дублируемого» кода, определив только 
        один шаблон, оперирующий с некоторым обобщенным типом данных
        — `Т`,

    b)  шаблон лишен недостатков макроподстановок, так как тело
        функции по шаблону реализуется компилятором, который
        прекрасно знает семантику C++ (например, параметр шаблона
        гарантированно вычисляется только один раз).

#### 3.1. Объявление шаблона функции:

![](media/image61.svg)

Замечания:

1)  как и обычную функцию, шаблон такой короткой функции Вы можете
    объявить встраиваемым:

    ```cpp
    template <class T>
    inline T min(T a, T b) { return (a < b) ? а : b; }
    ```

2)  параметры шаблона (также как и параметры функции) могут иметь
    значения по умолчанию: `func(T а = Т())`{.cpp}

3)  так как тело шаблона — это только заготовка компилятору (шаблон),
    по которой он будет генерировать код для конкретной типа данных,
    всю заготовку целиком компилятор должен видеть в месте вызова
    функции ⇒ ее тело также должно быть в заголовочном файле. Обычно
    объявление совмещают с определением.

4)  функция-шаблон в свою очередь может быть перегружена и в
    частности наряду с параметрами обобщенного типа может принимать 
    параметры любого типа

    ```cpp
    template <class Т> Т min(Т* р, int num) { ... }
    // пример — поиск минимального элемента в массиве
    ```

#### 3.2. Создание и вызов функции по заданному шаблону:

Вызов функции-шаблона ничем не отличается от вызова обычной функции.
Когда компилятор в тексте программы встретит вызов функции, он создаст
конкретную реализацию функции (__специализацию шаблона__), исходя из
заданного шаблона и конкретных типов параметров, использованных при
вызове функции:

```cpp
{
    int iX = 1000, iY = 500;
    int iResult = min(iX, iY); //компилятор создаст и вызовет
                               //min(int, int)
    double dX = 1.0, dY = 3;
    double dResult = min(dX, dY); //компилятор создаст и вызовет
                                  //min(double, double)
    //Ho!!!
    iResult = min(iX, dX); //ошибка компилятора! — параметры paзного
                           //типа -> нужно явно указать компилятору 
                           //какую специализацию нужно вызывать(или 
                           //генерировать)
    iResult = min<int>(iX, dX);//компилятор преобразует «double dX»
                               //в «int dX», и вызовет min(int, int)
}
```

Таким образом, один раз определив в приведенном примере шаблон функции
`min()`, можно вызывать ее для любых сколь угодно сложных типов данных
(для которых определена операция сравнения — «`<`» ). Это существенно
снижает объем Вами написанного кода и в то же время повышает его
«гибкость» без уменьшения надежности.

### Шаблоны функций и объекты пользовательского типа

Рассмотрим шаблон функции `min()` и наш класс `Rect`:

```cpp
template <class T> const T& min(const T& a, const T& b)
{ return (a < b) ? a : b; }
```

Замечание:

1)  __Модификация шаблона__: так как мы распространили использование
    шаблона на пользовательские типы, эффективнее передавать __ссылки__ в
    качестве параметров (__+`const`__ — необходимо, иначе этот шаблон не сможет
    работать с `min(1,5)` — а) запретить модифицировать параметры, б)
    возвращаемое значение — позволить использовать только справа от `=`)

2)  Модификация пользовательского типа данных: в тепе функции
    присутствует оператор `<`, который должен быть перегружен для
    пользовательского типа, если мы хотим использовать объекты `Rect` в
    качестве параметров. Так как мы будем вызывать эту функцию в
    константной функции и для константного параметра — она сама должна
    быть `const`.

```cpp
class Rect
{
    int m_l, m_t, m_r, m_b;
public:
    Rect(int l, int t, int r, int b)
    {
        m_l = 1; m_t = t; m_r = r; m_b = b;
    }
    bool operator<(const Rect& r) const
    { return Square() < r.Square(); }
    double Square() const
    { return (m_r - m_l) * (m_b - m_t); }
};
int main()
{
    Rect rl(1, 1, 3, 3), r2(0, 0, 10, 10);
    Rect res = min(rl, r2);
}
```

### Шаблоны классов

Шаблоны классов называют также «обобщенными классами» (generic
classes). Шаблон класса описывает, как компилятору сгенерировать класс
(то есть __выделить память под данные и сгенерировать код методов класса__) по соответствующему набору аргументов шаблона и «скелету»
класса. (Объявление шаблона является заготовкой класса, по которой
компилятор создаст конкретные классы, основываясь на конкретных типах
используемых данных).

Специфика:

1)  шаблоны могут участвовать в наследовании

2)  шаблоны методов могут быть виртуальными

    ```cpp
    template <typename Т> class A
    {
        Т m_а;
    public:
        A(const Т& a) { m_a = а; }
        virtual void f() { m_a++; }
    };
    template <typename T> class B : public A<T>
    {
        T m_b;
    public:
        B(const T& a, const T& b) :A<T>(а) { m_b = b; }
        virtual void f() { m_b++; }
    };
    void main()
    {
        B<int>* pB = new B<int>(1, 5);
        A<int>* pA = new B<int>(1, 5);
        pA->f();
        pB->f();
    }
    ```

3)  шаблоны классов могут содержать статические члены

    ```cpp
    //MyVector.h
    template <typename T> class MyVector
    {
    public:
        static int m_count;
    };
    //main.cpp
    int MyVector<int>::m_count = 0;
    int main()
    {
        int n = MyVector<int>::m_count;
    }
    ```

4)  у шаблонов могут быть `friend`-функции и классы

5)  классы могут содержать встроенные шаблоны, при этом действуют
    некоторые ограничения, которые перечислим по мере использования

Для примера рассмотрим шаблон класса, с помощью которого можно
реализовать «массив» заданного размера (`size`) для элементов любого
типа (обобщенный тип `T`):

![](media/image62.svg)

Методы шаблона класса вне объявления класса определяются следующим
образом:

```cpp
template <class T, int size> T& MyArray<T, size>::operator[](int i)
{
    if (i >= 0 && i < size) return m_ar[i];
    //исключение — out_of_range
}
```

Создание объектов конкретного типа на базе шаблона:

```cpp
int main()
{
    MyArray<int, 5> ar1; //создает массив для 5 элементов int
    ar1[1] = 1;
    int iTmp = ar1[1];
    MyArray<char, 6> ar2; //создает массив для 6 элементов char
    MyArray<Rect, 7> arЗ; //создает массив для 7 элементов типа Rect
    ...
}
```

*Замечания:*

1)  так как шаблоны являются механизмом времени компиляции, все
    параметры списка параметров базовых типов шаблона (такие как
    `int i`) должны быть константами:

    ```cpp
    int N = 5;
    MyArray<MyClass, N> ar4; //ошибка компилятора
                             //(N не является константой!)
    ```

2)  методы класса являются шаблонами функций ⇒ должны быть
    реализованы тоже в заголовочном файле

3)  параметры шаблона базового типа могут иметь значения по 
    умолчанию:

    ```cpp
    template<typename Т, int size=10> class MyArray { ... };
    MyArray<int> ar5;//размер массива по умолчанию ==10

    template<typename T=int, int size=10> class MyArray { ... };
    MyArray<> ar5;//тип элементов по умолчанию ==int, размер 
                  //массива по умолчанию ==10
    ```

4)  шаблон класса может содержать метод класса, который в свою 
    очередь
    является шаблоном, базирующимся на другом типе. При этом такой
    метод-шаблон должен быть встроенным — то есть должен быть
    «определен» внутри класса:

    ```cpp
    template<typename Т> class X
    {
    public:
        template<typename U> void f(const U& u) { ... } //OK
    };
    ```

    Некорректно:

    ```cpp
    template<typename Т> class X
    {
    public:
        template<typename U> void f(const U& u);
    };
    template<typename T> template <typename U>
    void X<T>::f(const U& u) { ... }
    ```
