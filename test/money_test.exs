defmodule MoneyTest do
  use ExUnit.Case
  doctest Money

  test "create a new money struct with a binary currency code" do
    money = Money.new(1234, "USD")
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)
  end

  test "create a new money struct with an atom currency code" do
    money = Money.new(1234, :USD)
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)
  end

  test "create a new money struct with a binary currency code with reversed params" do
    money = Money.new("USD", 1234)
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)
  end

  test "create a new money struct with a atom currency code with reversed params" do
    money = Money.new(:USD, 1234)
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)
  end

  test "create a new money struct with a lower case binary currency code with reversed params" do
    money = Money.new("usd", 1234)
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)
  end

  test "create a new money struct from a tuple" do
    money = Money.new({"USD", 1234})
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)
  end

  test "create a new money struct with a decimal" do
    money = Money.new(:USD, Decimal.new(1234))
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)

    money = Money.new("usd", Decimal.new(1234))
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)

    money = Money.new(Decimal.new(1234), :USD)
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)

    money = Money.new(Decimal.new(1234), "usd")
    assert money.currency == :USD
    assert money.value == Decimal.new(1234)
  end

  test "creating a money struct with an invalid currency code raises" do
    assert_raise Money.UnknownCurrencyError, ~r/The currency code :XYZ is not known/, fn ->
      Money.new(:XYZ, 100)
    end
  end

  test "string output of money is correctly formatted" do
    money = Money.new(1234, :USD)
    assert Money.to_string(money) == "$1,234.00"
  end

  test "adding two money structs with same currency" do
    assert Money.add(Money.new(:USD, 100), Money.new(:USD, 100)) == Money.new(:USD, 200)
  end

  test "subtracting two money structs with same currency" do
    assert Money.sub(Money.new(:USD, 100), Money.new(:USD, 40)) == Money.new(:USD, 60)
  end

  test "adding two money structs with different currency raises" do
    assert_raise ArgumentError, ~r/Cannot add two %Money/, fn ->
      Money.add(Money.new(:USD, 100), Money.new(:AUD, 100))
    end
  end

  test "subtracting two money structs with different currency raises" do
    assert_raise ArgumentError, ~r/Cannot subtract two %Money{}/, fn ->
      Money.sub(Money.new(:USD, 100), Money.new(:AUD, 100))
    end
  end

  test "multiply a money by an integer" do
    assert Money.mult(Money.new(:USD, 100), 2) == Money.new(:USD, 200)
  end

  test "multiply a money by a float" do
    m1 = Money.mult(Money.new(:USD, 100), 2.5)
    m2 = Money.new(:USD, 250)
    assert Money.equal?(m1, m2) == true
  end

  test "divide a money by an integer" do
    assert Money.div(Money.new(:USD, 100), 2) == Money.new(:USD, 50)
  end

  test "divide a money by a float" do
    m1 = Money.div(Money.new(:USD, 100), 2.5)
    m2 = Money.new(:USD, 40)
    assert Money.equal?(m1, m2) == true
  end

  test "Two %Money{} with different currencies are not equal" do
    m1 = Money.new(:USD, 250)
    m2 = Money.new(:JPY, 250)
    assert Money.equal?(m1, m2) == false
  end

  test "Split %Money{} into 4 equal parts" do
    m1 = Money.new(:USD, 100)
    assert Money.split(m1, 4) == {Money.new(:USD, 25), Money.new(:USD, 0)}
  end

  test "Split %Money{} into 3 equal parts" do
    m1 = Money.new(:USD, 100)
    assert Money.split(m1, 3) == {Money.new(:USD, 33.33), Money.new(:USD, 0.01)}
  end

  test "Money is rounded according to currency definition for USD" do
    assert Money.round(Money.new(:USD, 123.456)) == Money.new(:USD, 123.46)
  end

  test "Money is rounded according to currency definition for JPY" do
    assert Money.round(Money.new(:JPY, 123.456)) == Money.new(:JPY, 123)
  end

  test "Money is rounded according to currency definition for CHF" do
    assert Money.round(Money.new(:CHF, 123.456)) == Money.new(:CHF, 123.46)
  end

  test "Money is rounded according to currency cash definition for CHF" do
    assert Money.round(Money.new(:CHF, 123.456), cash: true) == Money.new(:CHF, 125)
  end

  test "Extract decimal from money" do
    assert Money.to_decimal(Money.new(:USD, 1234)) == Decimal.new(1234)
  end
end
