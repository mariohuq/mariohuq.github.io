# Тема III. Понятие `friend`

## `friend` (привилегированные) функции и классы

Одним из достоинств классов считается «сокрытие» данных, но,
общеизвестно, что как только возникает какое-либо правило, так сразу
же возникает и необходимость в исключениях из этого правила. Поэтому,
как только появились спецификаторы доступа private и protected, так
сразу же возникла необходимость иметь средство непосредственного
доступа к таким элементам класса, которое и было реализовано
посредством `friend`-функций или классов.

*Замечание:* существует мнение (и я с ним полностью согласна), что
введение понятия `friend` — это в большинстве случаев предоставление
программисту средства исправить плохо продуманную иерархию классов, и,
если возникает необходимость в таких функциях или классах, то зачастую
это признак того, что иерархия классов нуждается в исправлении. Но! В
некоторых случаях, а именно когда речь идет:

-   о перегруженных глобальными функциями операторах

-   или о вспомогательных классах

ключевое слово `friend` оказывается очень даже полезным.

### Внешняя (глобальная) `friend`-функция

Внешняя `friend`-функция это обычная глобальная функция, которой просто
предоставлены специальные привилегии доступа к защищенным элементам
того класса, в котором она объявлена как `friend`.

Пример (в приведенном примере с точки зрения проектирования корректнее
было бы пользоваться `public` методами для получения защищенных данных):

```cpp
class Rect
{
    int m_left, m_top, m_right, m_bottom;
public:
    ...
};
Rect BoundingRect(const Rect& r1, const Rect& r2)
{ //это не метод класса, а обычная глобальная функция ⇒ любая
  //попытка обращения к защищенным членам класса Rect вызывает 
  //ошибку компилятора
    int l = (r1.m_left < r2.m_left) ? r1.m_left : r2.m_left;
        //ошибка — нарушение прав доступа
    ...
}
```

Для того, чтобы в глобальной функции Вы могли обращаться к защищенным
переменным класса, эта функция должна быть объявлена в классе с
ключевым словом `friend`:

```cpp
class Rect
{
    ...
    friend Rect BoundingRect(const Rect&, const Rect&);
    //объявление глобальной friend-функции
```

> Замечание: не имеет значения, в какой секции (`private`, `protected` или `public`) объявлена `friend` функция, так как она не является членом класса.

```cpp
};
Rect BoundingRect(const Rect& r1, const Rect& r2)
{ //так как эта глобальная функция «стала другом» класса Rect, в
  //теле этой функции компилятор позволит обращаться к защищенным 
  //членам этого класса
    int l = (rl.m_left < r2.m_left) ? rl.m_left : r2.m_left; //ОК
}
```

> Замечание: для всех остальных функций правила доступа остаются
> прежними, то есть компилятор выдаст ошибку при попытке обращения к
> защищенному члену класса.

```cpp
int main()
{
    Rect r = BoundingRect(Rect(1,2,3,4), Rect(5,6,7,8));
//  r.l = 1; //ошибка доступа
}
```

Замечание 1: дружба с функцией автоматически не передается по
наследству

```cpp
class B;
class A
{
    friend void F(B& b);
    int m_a;
};
class B : public A
{
    int m_b;
};
void F(B& b)
{
    std::cout << b.m_a; //OK, так как функция является другом
                        //класса А
//std::cout << b.m_b; //ошибка — нет доступа к В::m_b. Для того,
                      //чтобы иметь доступ к защищенным переменным 
                      //производного класса, функция должна быть 
                      //другом этого производного класса
}
```

Замечание 2: с другой стороны, дружественная производному классу
функция имеет право обращаться к `protected` (не `private`!) членам
базового класса:

```cpp
class A
{
    int m_a1;
protected:
    int m_a2;
};
class B : public A
{
    int m_b;
    friend void F(B& b);
};
void F(B& b)
{
//  std::cout<<b.m_al; //ошибка — нет доступа
    std::cout << b.m_a2; //OK
    std::cout << b.m_b; //OK
}
```

### `friend`-класс

Можно сделать все методы одного класса «Дружественными» другому
классу, то есть позволить компилятору в любом методе `friend`-класса
обращаться к защищенным членам данного класса, например:

```cpp
//Circle.h
class Circle
{
    int x, y, r;
public:
    Circle(const Rect& r); //объявление конструктора, который
                           //«вписывает» создаваемый кружок в 
                           //заданный в качестве параметра 
                           //прямоугольник
};
//Circle.срр
Circle::Circle(const Rect& r)//реализация конструктора
{
    int w = r.m_right - r.m_left; //ошибка доступа
    int h = r.m_bottom - r.m_top; //ошибка доступа
    x = r.m_left + w / 2;
    y = r.m_top + h / 2;
    r = (w > h) ? h / 2 : w / 2;
}
```

Объявим класс `Circle` другом класса `Rect`:

```cpp
class Rect
{
    friend class Circle; //все методы класса Circle имеют право
                         //обращаться к защищенным членам класса Rect
};
//Circle.срр
Circle::Circle(const Rect& r)//теперь методы класса Circle имеют
                             //право обращаться к защищенным членам 
                             //класса Rect
{
    int w = r.m_right - r.m_left; //ОК
    int h = r.m_bottom - r.m_Lop; //ОК
    ...
}
```

Замечание: «дружба» классов:

1.  не наследуется

    ```cpp
    class Z { friend class X; };
    class X { ... };
    class Y : public X { ... };
    ```

    Методы производного класса `Y` не имеют права обращаться к защищенным
    членам класса `Z`

    ```cpp
    class Z { int m_z; friend class X; };
    class X
    {
        void fX(Z& z) { std::cout << z.m_z; } //OK
    };
    class Y : public X
    {
        void fY(Z& z)
        {
            //std::cout<<z.m_z; //ошибка доступа
        }
    };
    ```

2.  не является транзитивной (если 
    класс `Z` объявлен `friend`-классом в классе `Y`, а 
    класс `Y` объявлен `friend`-классом в классе `X`, то
    класс `Z` не является `friend`-классом `X`).

    ```cpp
    class X { friend class Y; };
    class Y { friend class Z; };
    ```

    Методы класса `Z` не имеют права обращаться к защищенным членам класса `X`.

### friend-метод другого класса

Можно дать права не всем, а выборочно некоторым методам другого класса обращаться к защищенным переменным данного класса, например:

```cpp
class Rect
{
    friend Circle::Circle(const Rect&);
        //только данный метод класса Circle имеет право обращаться к
        //защищенным членам класса Rect -> в любом другом методе при 
        //аналогичной попытке компилятор выдаст ошибку
};
```

