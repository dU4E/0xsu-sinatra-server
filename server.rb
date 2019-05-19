require 'sinatra'
require 'json'
require 'ethereum.rb'
require 'eth'
require 'dotenv/load'

abi = JSON.parse(File.open(ENV['ABI_PATH']).read)
key = Eth::Key.new
client = Ethereum::HttpClient.new(ENV['PROVIDER_URL'])
client.default_account = key.address
contract_address = ENV['CONTRACT_ADDRESS']

get '/:short' do
  contract = Ethereum::Contract.create(
    client: client,
    name: "URLShortner", 
    address: contract_address, 
    abi: abi
  )
  slug = params[:short]
  # some decoding if already encoded
  slug = slug[2..-1].scan(/../).map { |x| x.hex.chr }.join if slug.start_with?("0x")
  # grab the url and if it's been paid or not
  @destination, paid = contract.call.get_url(slug)
  unless paid
    erb :pre_redirect
  else
    redirect @destination != "FAIL" ? @destination : "/"
  end
end