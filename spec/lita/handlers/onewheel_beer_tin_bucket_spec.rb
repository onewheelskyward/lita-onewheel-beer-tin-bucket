require 'spec_helper'

describe Lita::Handlers::OnewheelBeerTinBucket, lita_handler: true do
  it { is_expected.to route_command('tinbucket') }
  it { is_expected.to route_command('tinbucket 4') }
  it { is_expected.to route_command('tinbucket nitro') }
  it { is_expected.to route_command('tinbucket CASK') }
  it { is_expected.to route_command('tinbucket <$4') }
  it { is_expected.to route_command('tinbucket < $4') }
  it { is_expected.to route_command('tinbucket <=$4') }
  it { is_expected.to route_command('tinbucket <= $4') }
  it { is_expected.to route_command('tinbucket >4%') }
  it { is_expected.to route_command('tinbucket > 4%') }
  it { is_expected.to route_command('tinbucket >=4%') }
  it { is_expected.to route_command('tinbucket >= 4%') }
  it { is_expected.to route_command('tinbucketabvhigh') }
  it { is_expected.to route_command('tinbucketabvlow') }

  before do
    mock = File.open('spec/fixtures/tinbucket.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the tinbucket taps' do
    send_command 'tinbucket'
    expect(replies.last).to eq("taps: 1) Block 15 Gloria!  2) Russian River Supplication  3) Prairie Artisan Ales Phantasmagoria  4) Block 15 Sticky Hands Hop Experience  5) Block 15 Alpha IPA  6) Goose Island Bourbon County Regal Rye Stout  7) Logsdon Farmhouse Peche 'n Brett  8) Bruery Gypsy Tart (PREMIUM)  9) Perennial Abraxas  10) Flat Tail Grape Drape  11) Prairie Artisan Ales BOMB!  12) Block 15 Hypnosis  13) pFriem Flanders Red  14) Flat Tail So Much Drama in the LBC  15) Block 15 Demon's Farm  16) AleSmith Hawaiian Speedway Stout  17) Russian River Temptation  18) Bend B-21  19) Prairie Artisan Ales Ales Vous Francais")
  end

  it 'displays details for tap 4' do
    send_command 'tinbucket 4'
    expect(replies.last).to eq('Tin Bucket tap 4) Sticky Hands Hop Experience 8.8%')
  end

  it 'doesn\'t explode on 1' do
    send_command 'tinbucket 1'
    expect(replies.count).to eq(1)
    expect(replies.last).to eq('Tin Bucket tap 1) Gloria! 5.0%')
  end

  it 'searches for ipa' do
    send_command 'tinbucket ipa'
    expect(replies.last).to eq('Tin Bucket tap 5) Alpha IPA 6.5%')
  end

  # it 'searches for brown' do
  #   send_command 'tinbucket brown'
  #   expect(replies.last).to eq("Bailey's tap 22) GoodLife 29er - India Brown Ale 6.0%, 10oz - $3 | 20oz - $5 | 32oz Crowler - $8, 37% remaining")
  # end

  it 'searches for abv >9%' do
    send_command 'tinbucket >9%'
    expect(replies.count).to eq(7)
    expect(replies[1]).to eq("Tin Bucket tap 7) Peche 'n Brett 10.0%")
  end

  it 'searches for abv > 9%' do
    send_command 'tinbucket > 9%'
    expect(replies.count).to eq(7)
    expect(replies[1]).to eq("Tin Bucket tap 7) Peche 'n Brett 10.0%")
  end

  it 'searches for abv >= 9%' do
    send_command 'tinbucket >= 9%'
    expect(replies.count).to eq(8)
    expect(replies.last).to eq('tinbucket tap 46) Sump - Imp Coffee Stout 10.5%, $5')
  end

  it 'searches for abv <4.1%' do
    send_command 'tinbucket <4.1%'
    expect(replies.count).to eq(2)
    expect(replies.last).to eq('tinbucket tap 38) Prairie-Vous Francais - Saison   Just Tapped 3.9%, $5')
  end

  it 'searches for abv <= 4%' do
    send_command 'tinbucket <= 4%'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq('tinbucket tap 15) Grapefruit Radler 2.5%, $5')
    expect(replies.last).to eq('tinbucket tap 38) Prairie-Vous Francais - Saison   Just Tapped 3.9%, $5')
  end

  it 'searches for prices >$5' do
    send_command 'tinbucket >$5'
    expect(replies.count).to eq(11)
    expect(replies[0]).to eq('tinbucket tap 4) Blind Pig - IPA 6.1%, $6')
    expect(replies[1]).to eq('tinbucket tap 21) Kristallweissbier 5.4%, $6')
  end

  it 'searches for prices >=$6' do
    send_command 'tinbucket >=$6'
    expect(replies.count).to eq(11)
    expect(replies[0]).to eq('tinbucket tap 4) Blind Pig - IPA 6.1%, $6')
  end

  it 'searches for prices > $6' do
    send_command 'tinbucket > $6'
    expect(replies.count).to eq(3)
    expect(replies[0]).to eq('tinbucket tap 29) Nitro- Shake - Choco Porter 5.9%, $8')
  end

  it 'searches for prices <$4.1' do
    send_command 'tinbucket <$4.1'
    expect(replies.count).to eq(4)
    expect(replies[0]).to eq('tinbucket tap 8) Cheap, cold 4.7%, $3')
  end

  it 'searches for prices < $4.01' do
    send_command 'tinbucket < $4.01'
    expect(replies.count).to eq(4)
    expect(replies[0]).to eq('tinbucket tap 8) Cheap, cold 4.7%, $3')
  end

  it 'searches for prices <= $4.00' do
    send_command 'tinbucket <= $4.00'
    expect(replies.count).to eq(4)
    expect(replies[0]).to eq('tinbucket tap 8) Cheap, cold 4.7%, $3')
  end

  it 'runs a random beer through' do
    send_command 'tinbucket roulette'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('tinbucket tap')
  end

  it 'runs a random beer through' do
    send_command 'tinbucket random'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('tinbucket tap')
  end

  it 'searches with a space' do
    send_command 'tinbucket cider riot'
    expect(replies.last).to eq('tinbucket tap 10) Cider- NeverGiveAnInch -Rosé  6.9%, $5')
  end

  it 'displays low abv' do
    send_command 'tinbucketabvhigh'
    expect(replies.last).to eq('tinbucket tap 31) Notorious - IIIPA 11.5%, $5')
  end

  it 'displays high abv' do
    send_command 'tinbucketabvlow'
    expect(replies.last).to eq('tinbucket tap 15) Grapefruit Radler 2.5%, $5')
  end
end
