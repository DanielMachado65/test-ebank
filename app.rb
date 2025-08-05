# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'rack/protection'
require_relative 'lib/application/ledger'

class App < Sinatra::Base
  set :bind, '0.0.0.0'

  configure :development do
    set :host_authorization, permitted_hosts: [
      '.localhost', '.test', '127.0.0.1', '::1',
      '.ngrok-free.app'
    ]
  end

  configure { set :ledger, Ledger.new }

  get('/') { 'EBANX Assignment API' }

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
