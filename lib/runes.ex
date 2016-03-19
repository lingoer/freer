defmodule Freer.Runes do

  defp lift?({:pure, _x} = freer), do: freer
  defp lift?({:impure, _u, _c} = freer), do: freer 
  defp lift?(g), do: Freer.eta(g)

  def return(x), do: Freer.return(x)
  def bind(freer, f), do: lift?(freer) |> Freer.bind(f)
  def apply(freer_f, freer), do: lift?(freer_f) |> Freer.apply(lift?(freer)) 
  def map(freer, f), do: lift?(freer) |> Freer.map(f) 
end
