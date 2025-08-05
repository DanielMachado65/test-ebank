# frozen_string_literal: true

# Domain entity representing a bank account with a balance.
class Account
  attr_reader :id, :balance

  def initialize(id, balance = 0)
    @id = id
    @balance = balance
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    @balance -= amount
  end
end
