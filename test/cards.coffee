should = require 'should'
models = require '../assets/js/models'

makeHand = (parts) ->
  cards = []
  for i in [0...parts.names.length]
    cards.push
      name: parts.names[i]
      suit: parts.suits[i]
  new models.Hand cards

describe 'Deck', ->
  deck = {}

  beforeEach ->
    deck = new models.Deck

  it 'should have 52 Cards', (done) ->
    deck.should.have.length 52
    done()

  it 'can be shuffled', (done) ->
    prev = deck.models.slice()
    deck.shuffle()
    prev.should.not.eql deck.models
    done()

  it 'can deal cards', (done) ->
    deck.draw()
    deck.should.have.length 51
    hand = deck.draw 5
    deck.should.have.length 46
    done()

  it 'deals a hand', (done) ->
    hand = deck.draw 5
    hand.should.have.length 5
    done()

  it 'shuffles in dealt cards', (done) ->
    deck.draw 5
    deck.shuffle()
    deck.should.have.length 52
    done()

  it 'can be initialized as an existing deck', (done) ->
    hand = deck.draw 5
    newDeck = new models.Deck deck.models

    newDeck.should.have.length 47

    for card in hand.models
      existing = newDeck.where
        name: card.get('name')
        suit: card.get('suit')

      existing.should.be.empty

    done()

describe 'Hand', ->
  deck = {}
  hand = {}
  prev = []

  beforeEach ->
    deck = new models.Deck
    hand = deck.draw 5
    prev = hand.models.slice()

  it 'can hold a card', (done) ->
    hand.hold 0
    hand.deal deck
    hand.models[0].should.eql prev[0]
    hand.models[1].should.not.eql prev[1]
    hand.models[2].should.not.eql prev[2]
    hand.models[3].should.not.eql prev[3]
    hand.models[4].should.not.eql prev[4]
    deck.should.have.length 43
    done()

  it 'can stop holding a card', (done) ->
    hand.hold 0
    hand.hold 0
    hand.deal deck
    hand.models[0].should.not.eql prev[0]
    hand.models[1].should.not.eql prev[1]
    hand.models[2].should.not.eql prev[2]
    hand.models[3].should.not.eql prev[3]
    hand.models[4].should.not.eql prev[4]
    deck.should.have.length 42
    done()

describe 'Winning Hands', ->
  hand = {}

  it 'should recognise a pair', (done) ->
    hand = makeHand
      names: ['J', 'J', '8', '9', '3']
      suits: ['S', 'D', 'S', 'H', 'S']

    hand.getPair().should.eql ['J']
    done()

  it 'should only count a pair as Jacks or better', (done) ->
    hand = makeHand
      names: ['4', '4', '8', '9', '3']
      suits: ['S', 'D', 'S', 'H', 'S']

    hand.getPair().should.eql ['4']
    done()

  it 'should not mark 2 pair as a pair', (done) ->
    hand = makeHand
      names: ['J', 'J', '8', '8', '3']
      suits: ['S', 'D', 'S', 'H', 'S']

    hand.getPair().should.be.empty
    done()

  it 'should not mark 3 of a kind as a pair', (done) ->
    hand = makeHand
      names: ['J', 'J', 'J', '8', '3']
      suits: ['S', 'D', 'C', 'H', 'S']

    hand.getPair().should.be.empty
    done()

  it 'should know 3 of a kind', (done) ->
    hand = makeHand
      names: ['J', 'J', 'J', '8', '3']
      suits: ['S', 'D', 'C', 'H', 'S']

    hand.getThreeOfAKind().should.eql ['J']
    done()

  it 'should know 2 pair', (done) ->
    hand = makeHand
      names: ['J', 'J', '8', '8', '3']
      suits: ['S', 'D', 'S', 'H', 'S']

    twoPair = hand.getTwoPair()
    twoPair.should.include 'J'
    twoPair.should.include '8'
    done()

  it 'should not mark a full house as 2 pair', (done) ->
    hand = makeHand
      names: ['J', 'J', '8', '8', '8']
      suits: ['S', 'D', 'S', 'H', 'D']

    hand.getTwoPair().should.be.empty
    done()

  it 'should know a full house', (done) ->
    hand = makeHand
      names: ['J', 'J', '8', '8', '8']
      suits: ['S', 'D', 'S', 'H', 'D']

    hand.getFullHouse().should.eql ['8', 'J']
    done()

  it 'should not mark 3 of a kind as a full house', (done) ->
    hand = makeHand
      names: ['J', 'J', 'J', '8', '3']
      suits: ['S', 'D', 'C', 'H', 'S']

    hand.getFullHouse().should.be.empty
    done()

  it 'should not mark full house as a pair', (done) ->
    hand = makeHand
      names: ['J', 'J', 'J', '8', '8']
      suits: ['S', 'D', 'C', 'H', 'S']

    hand.getPair().should.be.empty
    done()

  it 'should not mark full house as 3 of a kind', (done) ->
    hand = makeHand
      names: ['J', 'J', 'J', '8', '8']
      suits: ['S', 'D', 'C', 'H', 'S']

    hand.getThreeOfAKind().should.be.empty
    done()

  it 'should know a flush', (done) ->
    hand = makeHand
      names: ['2', '4', '6', '8', 'T']
      suits: ['S', 'S', 'S', 'S', 'S']

    hand.isFlush().should.be.true
    done()

  it 'should know a straight', (done) ->
    hand = makeHand
      names: ['5', '4', '6', '8', '7']
      suits: ['S', 'D', 'S', 'H', 'S']

    hand.getStraight().should.eql ['8']
    done()

  it 'should know straights with Aces', (done) ->
    hand1 = makeHand
      names: ['A', '5', '3', '4', '2']
      suits: ['S', 'D', 'S', 'H', 'S']
    hand2 = makeHand
      names: ['A', 'T', 'K', 'J', 'Q']
      suits: ['S', 'D', 'S', 'H', 'S']

    hand1.getStraight().should.eql ['5']
    hand2.getStraight().should.eql ['A']
    done()

  it 'should not mark a near straight as a straight', (done) ->
    hand = makeHand
      names: ['5', '4', '7', '8', '7']
      suits: ['S', 'D', 'C', 'H', 'S']

    hand.getStraight().should.eql []
    done()

  it 'should not mark a near straight as a straight  2', (done) ->
    hand = makeHand
      names: ['5', '4', 'T', '8', '7']
      suits: ['S', 'D', 'C', 'H', 'S']

    hand.getStraight().should.eql []
    done()

  it 'should know 4 of a kind, with kicker', (done) ->
    hand = makeHand
      names: ['4', '4', '4', '4', '5']
      suits: ['S', 'D', 'C', 'H', 'S']

    hand.getFourOfAKind().should.eql ['4', '5']
    done()

  it 'should not mark 3 of a kind as 4 of a kind', (done) ->
    hand = makeHand
      names: ['4', '4', '4', '3', '5']
      suits: ['S', 'D', 'C', 'H', 'S']

    hand.getFourOfAKind().should.be.empty
    done()

  it 'should know a straight flush', (done) ->
    hand = makeHand
      names: ['4', '7', '6', '3', '5']
      suits: ['S', 'S', 'S', 'S', 'S']

    hand.getStraightFlush().should.eql ['7']
    done()

  it 'will mark a straight flush as a flush and a straight', (done) ->
    hand = makeHand
      names: ['4', '7', '6', '3', '5']
      suits: ['S', 'S', 'S', 'S', 'S']

    hand.isFlush().should.be.true
    hand.getStraight().should.eql ['7']
    done()

describe 'Game', ->
  game = {}

  beforeEach ->
    game = new models.Game

  it 'must draw before it can deal again', (done) ->
    hand1 = game.deal()
    hand2 = game.deal()
    hand1.toJSON().should.eql hand2.toJSON()

    game.draw()

    hand3 = game.deal()
    hand3.toJSON().should.not.eql hand2.toJSON()

    done()

  it 'should not be allowed to bet more than 5', (done) ->
    game.set 'bet', 6
    game.get('bet').should.eql 1
    done()

  it 'should not be allowed to bet less than 1', (done) ->
    game.set 'bet', 0
    game.get('bet').should.eql 1
    done()

  it 'should not be allowed to change bet during a hand', (done) ->
    game.deal()
    game.set 'bet', 4
    game.get('bet').should.eql 1
    done()

  it 'should not be allowed to change number of hands during a hand', (done) ->
    game.deal()
    game.set 'numHands', 3
    game.get('numHands').should.eql 1
    done()

  it 'should be able to play a single hand', (done) ->
    hand = game.deal()

    prevHand = hand.models.slice()
    hand.hold 1
    hand.hold 2
    [hand1] = game.draw()

    hand1.at(0).should.not.eql prevHand[0]
    hand1.at(1).should.eql prevHand[1]
    hand1.at(2).should.eql prevHand[2]
    hand1.at(3).should.not.eql prevHand[3]
    hand1.at(4).should.not.eql prevHand[4]

    done()

  it 'should be able to play multiple hands at a time', (done) ->
    game.set 'numHands', 2
    hand = game.deal()

    prevHand = hand.models.slice()
    hand.hold 0
    [hand1, hand2] = game.draw()

    hand1.at(0).should.eql prevHand[0]
    hand1.at(1).should.not.eql prevHand[1]
    hand1.at(2).should.not.eql prevHand[2]
    hand1.at(3).should.not.eql prevHand[3]
    hand1.at(4).should.not.eql prevHand[4]
    hand2.at(0).should.eql prevHand[0]
    hand2.at(1).should.not.eql prevHand[1]
    hand2.at(2).should.not.eql prevHand[2]
    hand2.at(3).should.not.eql prevHand[3]
    hand2.at(4).should.not.eql prevHand[4]

    done()

  it 'should remove credits after betting', (done) ->
    game.deal()

    game.get('credit').should.eql 999
    done()

  it 'should remove credits based on number of hands', (done) ->
    game.set 'numHands', 10
    game.deal()

    game.get('credit').should.eql 990
    done()

  it 'should remove credits based on bet size', (done) ->
    game.set 'bet', 5
    game.deal()

    game.get('credit').should.eql 995
    done()

  it 'should give credits for a win', (done) ->
    fake = makeHand
      names: ['J', 'J', '8', '9', '3']
      suits: ['S', 'D', 'S', 'H', 'S']

    hand = game.deal()
    hand.reset fake.models
    hand.hold 0
    hand.hold 1
    hand.hold 2
    hand.hold 3
    hand.hold 4

    game.draw()
    game.get('credit').should.eql 1000

    done()

  it 'should give correct credits for multiple hands', (done) ->
    game.set 'numHands', 2
    fake = makeHand
      names: ['J', 'J', '8', '9', '3']
      suits: ['S', 'D', 'S', 'H', 'S']

    hand = game.deal()
    hand.reset fake.models
    hand.hold 0
    hand.hold 1
    hand.hold 2
    hand.hold 3
    hand.hold 4

    game.draw()
    game.get('credit').should.eql 1000

    done()

  it 'should give correct credits for a royal flush', (done) ->
    game.set 'bet', 5
    fake = makeHand
      names: ['A', 'T', 'K', 'J', 'Q']
      suits: ['D', 'D', 'D', 'D', 'D']

    hand = game.deal()
    hand.reset fake.models
    hand.hold 0
    hand.hold 1
    hand.hold 2
    hand.hold 3
    hand.hold 4

    game.draw()
    game.get('credit').should.eql 4995

    done()

  it 'should reset the wins after each deal', (done) ->
    fake = makeHand
      names: ['J', 'J', '8', '9', '3']
      suits: ['S', 'D', 'S', 'H', 'S']

    hand = game.deal()
    hand.reset fake.models
    hand.hold 0
    hand.hold 1
    hand.hold 2
    hand.hold 3
    hand.hold 4

    game.draw()

    hand = game.deal()
    hand.reset fake.models
    hand.hold 0
    hand.hold 1
    hand.hold 2
    hand.hold 3
    hand.hold 4

    game.draw()
    game.get('credit').should.eql 1000

    done()


describe 'Jacks or Better 9/6', ->
  game = {}
  payTable = {}

  beforeEach ->
    game = new models.Game
    payTable = new models.JacksBetter96

  it 'should pay 1 for a pair', (done) ->
    fake = makeHand
      names: ['J', 'J', '8', '9', '3']
      suits: ['S', 'D', 'S', 'H', 'S']

    payTable.check fake, (win, type) ->
      win.should.eql 1
      type.should.eql 'pair'

    payTable.get('pair').should.eql 1

    done()

  it 'should pay 2 for 2 pair', (done) ->
    fake = makeHand
      names: ['J', 'J', '8', '8', '3']
      suits: ['S', 'D', 'S', 'H', 'S']

    payTable.check fake, (win, type) ->
      win.should.eql 2
      type.should.eql 'twoPair'

    payTable.get('twoPair').should.eql 1

    done()

  it 'should pay 3 for 3 of a kind', (done) ->
    fake = makeHand
      names: ['J', 'J', 'J', '8', '3']
      suits: ['S', 'D', 'C', 'H', 'S']

    payTable.check fake, (win, type) ->
      win.should.eql 3
      type.should.eql 'threeOfAKind'

    payTable.get('threeOfAKind').should.eql 1

    done()

  it 'should pay 4 for a straight', (done) ->
    fake = makeHand
      names: ['4', '7', '6', '3', '5']
      suits: ['S', 'D', 'C', 'H', 'S']

    payTable.check fake, (win, type) ->
      win.should.eql 4
      type.should.eql 'straight'

    payTable.get('straight').should.eql 1

    done()

  it 'should pay 6 for a flush', (done) ->
    fake = makeHand
      names: ['4', '7', '9', '3', '5']
      suits: ['D', 'D', 'D', 'D', 'D']

    payTable.check fake, (win, type) ->
      win.should.eql 6
      type.should.eql 'flush'

    payTable.get('flush').should.eql 1

    done()

  it 'should pay 9 for a full house', (done) ->
    fake = makeHand
      names: ['J', 'J', '8', '8', '8']
      suits: ['S', 'D', 'C', 'H', 'S']

    payTable.check fake, (win, type) ->
      win.should.eql 9
      type.should.eql 'fullHouse'

    payTable.get('fullHouse').should.eql 1

    done()

  it 'should pay 25 for 4 of a kind', (done) ->
    fake = makeHand
      names: ['4', '4', '4', '4', '5']
      suits: ['S', 'D', 'C', 'H', 'S']

    payTable.check fake, (win, type) ->
      win.should.eql 25
      type.should.eql 'fourOfAKind'

    payTable.get('fourOfAKind').should.eql 1

    done()


  it 'should pay 50 for a straight flush', (done) ->
    fake = makeHand
      names: ['5', '4', '6', '8', '7']
      suits: ['D', 'D', 'D', 'D', 'D']

    payTable.check fake, (win, type) ->
      win.should.eql 50
      type.should.eql 'straightFlush'

    payTable.get('straightFlush').should.eql 1

    done()

  it 'should pay 250 for a royal flush', (done) ->
    fake = makeHand
      names: ['A', 'K', 'Q', 'J', 'T']
      suits: ['D', 'D', 'D', 'D', 'D']

    payTable.check fake, (win, type) ->
      win.should.eql 250
      type.should.eql 'royalFlush'

    payTable.get('royalFlush').should.eql 1

    done()

  it 'should not pay for a non-winning hand', (done) ->
    fake = makeHand
      names: ['A', 'K', 'Q', '9', 'T']
      suits: ['D', 'D', 'D', 'H', 'D']

    payTable.check fake, (win, type) ->
      win.should.eql 0
      type.should eql ''

    done()

  it 'should hold multiple winning hands', (done) ->
    fake1 = makeHand
      names: ['J', 'J', '8', '9', '3']
      suits: ['D', 'D', 'D', 'H', 'D']
    fake2 = makeHand
      names: ['5', '4', 'Q', '8', 'Q']
      suits: ['D', 'D', 'H', 'D', 'D']

    payTable.check fake1, (win, type) ->
      win.should.eql 1
      type.should.eql 'pair'

    payTable.check fake2, (win, type) ->
      win.should.eql 1
      type.should.eql 'pair'

    payTable.get('pair').should.eql 2

    done()

  it 'should have the ability to reset the wins', (done) ->
    fake = makeHand
      names: ['A', 'K', 'Q', 'J', 'T']
      suits: ['D', 'D', 'D', 'D', 'D']

    payTable.check fake, (win, type) ->

    payTable.clearWins()
    payTable.get('royalFlush').should.eql 0

    done()
