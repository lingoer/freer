defmodule FreerTest do
  use ExUnit.Case
  doctest Freer

  def inter(x), do: Freer.interpret(&([&1]), &Enum.flat_map/2).(x)

  test "left identity" do
    f = fn (x) -> Freer.return(x * x) end
    a = 2
    left = Freer.bind(Freer.return(a), f)
    right = f.(a)
    assert inter(left) == inter(right)
  end

  test "right identity" do
    m = Freer.return 42
    left = Freer.bind(m, &Freer.return/1)
    right = m
    assert inter(left) == inter(right)
  end

  test "associativity" do
    m = Freer.return(42)
    f = fn (x) -> Freer.return(x * x) end
    g = fn (x) -> Freer.return(x + 1) end
    left = Freer.bind(m, f) |> Freer.bind(g)
    right = Freer.bind(m, &Freer.bind(f.(&1), g))
    assert left == right
  end
end
