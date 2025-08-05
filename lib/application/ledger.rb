# frozen_string_literal: true

require_relative '../domain/account'
require_relative '../infrastructure/memory_account_repository'

# Application service orchestrating account operations.
class Ledger
  def initialize(repository = MemoryAccountRepository.new)
    @repository = repository
  end

  def reset
    @repository.reset
  end

  def balance(account_id)
    account = @repository.find(account_id)
    account&.balance
  end

  def deposit(destination_id, amount)
    account = @repository.find(destination_id) || Account.new(destination_id)
    account.deposit(amount)
    @repository.save(account)
    { destination: { id: account.id, balance: account.balance } }
  end

  def withdraw(origin_id, amount)
    account = @repository.find(origin_id)
    return nil unless account

    account.withdraw(amount)
    @repository.save(account)
    { origin: { id: account.id, balance: account.balance } }
  end

  def transfer(origin_id, destination_id, amount)
    origin = @repository.find(origin_id)
    return nil unless origin

    destination = @repository.find(destination_id) || Account.new(destination_id)
    origin.withdraw(amount)
    destination.deposit(amount)
    @repository.save(origin)
    @repository.save(destination)
    { origin: { id: origin.id, balance: origin.balance },
      destination: { id: destination.id, balance: destination.balance } }
  end
end
