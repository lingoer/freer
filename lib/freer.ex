defmodule Freer do


  defmacro charm(do: body) do
      quote do
       import Freer.Runes
       unquote Macro.postwalk(body, &runes/1)
       end
  end

  defp runes({:runes, ctx, [{:<-, _ctx, [lhs, rhs]} | exprs]}), do: binder(lhs, rhs, runes({:runes, ctx, exprs}))
  defp runes({:runes, _ctx, [[do: expr]| []]}), do: quote do: unquote(expr) |> Freer.return 
  defp runes({:runes, ctx, [expr| exprs]}), do: binder(quote do _  end, expr, runes({:runes, ctx, exprs})) 
  defp runes(x), do: x

  defp binder(lhs, rhs, body) do
    quote do
      unquote(rhs)
        |> Freer.eta
        |> Freer.bind(fn unquote(lhs) -> unquote(body) end)
    end
  end

  def return(x), do: {:pure, x}

  def bind({:pure, x}, f), do: f.(x)
  def bind({:impure, x, continuation}, f), do: {:impure, x, &(&1 |> continuation.() |> bind(f))}

  def map(freer, f), do: bind(freer, &(return f.(&1)))

  def apply(freer_f, freer), do: bind(freer_f, &(freer |> map(&1)))

  def eta(x), do: {:impure, x, &({:pure, &1})}

  def interpret(unit, flat_map) do
    fn 
    {:pure, x} -> unit.(x)
    {:impure, x, cont} -> x |> flat_map.(&(&1 |> cont.() |> interpret(unit, flat_map).()))
    end
  end

end

