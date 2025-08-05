# frozen_string_literal: true

# Simple in-memory repository for Account entities.
class MemoryAccountRepository
  def initialize
    @accounts = {}
  end

  def reset
    @accounts.clear
  end

  def find(id)
    @accounts[id]
  end

  def save(account)
    @accounts[account.id] = account
  end
end
