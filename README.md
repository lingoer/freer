# Freer

###A Freer Monad implemented in elixir.

So, what is a Freer Monad? Hmmmm, it's just a monad even freer than an free monad:

If you still have no idea about ```Free Monad```
Free Monad: http://www.haskellforall.com/2012/06/you-could-have-invented-free-monads.html

If you really want to know about the detail on ```Freer Monad```
Freer Monad: http://okmij.org/ftp/Haskell/extensible/more.pdf

###Basic Usage

Say you wanted to  build a ```Error Monad``` to chain a series of failable functions: 
With Freer, well, you don't need to build any thing at all, you just write your monadic code in the ```charm``` block
```elixir
require Freer
# x is some initial value, eg: a file path on the disk
# and in the charm block, you just have the 'bind' 'return' 'map' and 'apply' functions already free to use!
# eg:
f_result = Freer.charm do
return(x) 
|> bind(failable_fun1) 
|> bind(failable_fun2)
|> map(transform_fun)
end
```
After all your logic and operation is wrote done, you simple use the real ```return``` and ```bind``` of your Monads to interpret the final result:
```elixir
#you can build or update your interpreter at the final step after all of your business logic is done.
# the first parameter of 'interpret' is the real 'return' function
# and the second parameter is the real 'bind' function
interpreter = Freer.interpret(
&({:ok, &1}), 
fn
{:ok, x}, fun -> fun.(x)
e, _fun -> e
end
)
result = interpreter.(f_result)
# now result is {:ok, final_value} or {:error, some_reason}
```
This approach of interpreter pattern can be useful, take a look at the Facebook's Haxl library, and a series of talk in the community.

### Rune Word
For most common use case of Monads, this library provides a ```runes```  macro, which behaviours exactly like the ```for``` or ```with``` statement in elixir. 
```elixir
f = Freer.charm do
runes x <- [1,3,5],
y <- [2,4,6],
do: x * y
end
#[2, 4, 6, 6, 12, 18, 10, 20, 30] after interpret.
```
```elixir
f = Freer.charm do
runes line1 <- read_file1,
line2 <- read_file2,
do: line1 <> line2
end
# if both file read successfully, it returns the value, or if any fails, it returns the error reason of the failed one.
```
