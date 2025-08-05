# frozen_string_literal: true

require 'sinatra'
require 'json'
require_relative 'lib/application/ledger'

# Handles HTTP endpoints for EBANX assignment using a ledger for business logic.
class App < Sinatra::Base
  set :bind, '0.0.0.0'
  configure { set :ledger, Ledger.new }

  post '/reset' do
    settings.ledger.reset
    status 200
    'OK'
  end

  get '/balance' do
    balance = settings.ledger.balance(params['account_id'])
    if balance
      balance.to_s
    else
      status 404
      '0'
    end
  end

  post '/event' do
    content_type :json
    data = JSON.parse(request.body.read)

    result = case data['type']
             when 'deposit'
               settings.ledger.deposit(data['destination'], data['amount'].to_i)
             when 'withdraw'
               settings.ledger.withdraw(data['origin'], data['amount'].to_i)
             when 'transfer'
               settings.ledger.transfer(data['origin'], data['destination'], data['amount'].to_i)
             else
               halt 400, { error: 'Invalid event type' }.to_json
             end

    if result
      status 201
      result.to_json
    else
      status 404
      '0'
    end
  end
end

App.run! if __FILE__ == $PROGRAM_NAME
