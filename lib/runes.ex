defmodule Freer.Runes do

  defp lift({:pure, _x} = freer), do: freer
  defp lift({:impure, _u, _c} = freer), do: freer 
  defp lift(g), do: Freer.eta(g)

  def return(x), do: Freer.return(x)

  def bind(freer, f) do
    etaf = &(&1 |> f.() |> lift)
    freer |> lift |> Freer.bind(etaf)
  end

  def apply(freer_f, freer), do: Freer.apply(lift(freer_f), lift(freer)) 

  def map(freer, f), do: freer |> lift |> Freer.map(f) 
end
