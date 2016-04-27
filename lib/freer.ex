defmodule Freer do
  @moduledoc """
  The Freer Monad
  """

  @type freer :: {:pure, any()} | {:impure, any(), (any() -> freer)}
  @type monad :: any()
  @typep unit_f :: (any() -> monad)
  @typep bind_f :: (monad, (any() -> monad) -> monad)
  defmacro charm(do: body) do
    quote do
      import Freer.Runes
      unquote Macro.postwalk(body, &runes/1)
    end
  end

  defp runes({:runes, ctx, [{:<-, _ctx, [lhs, rhs]} | exprs]}), do: binder(lhs, rhs, runes({:runes, ctx, exprs}))
  defp runes({:runes, _ctx, [[do: expr] | []]}), do: quote do: unquote(expr) |> Freer.return
  defp runes({:runes, ctx, [expr | exprs]}), do: binder(quote do _  end, expr, runes({:runes, ctx, exprs}))
  defp runes(x), do: x

  defp binder(lhs, rhs, body) do
    quote do
      unquote(rhs)
        |> Freer.eta
        |> Freer.bind(fn unquote(lhs) -> unquote(body) end)
    end
  end

  @spec return(any()) :: freer
  def return(x), do: {:pure, x}

  @spec bind(freer, (any() -> freer)) :: freer
  def bind({:pure, x}, f), do: f.(x)
  def bind({:impure, x, continuation}, f), do: {:impure, x, fn m -> m |> continuation.() |> bind(f) end}

  @spec map(freer, (any() -> any())) :: freer
  def map(freer, f), do: bind(freer, &(return f.(&1)))

  @spec apply(freer, freer) :: freer
  def apply(freer_f, freer), do: bind(freer_f, &(freer |> map(&1)))

  @spec eta(monad) :: freer
  def eta(x), do: {:impure, x, &({:pure, &1})}

  @spec interpret(unit_f, bind_f) :: (freer -> monad)
  def interpret(unit, flat_map) do
    fn
    {:pure, x} -> unit.(x)
    {:impure, x, cont} ->
    f = fn m -> m |> cont.() |> interpret(unit, flat_map).() end
    flat_map.(x, f)
    end
  end

end

