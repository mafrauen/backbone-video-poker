if typeof require isnt 'undefined'
  Backbone = require 'backbone' unless Backbone
  _ = require 'lodash'
if window?
  Backbone = window.Backbone
  _ = window._

cardSuits = ['S', 'H', 'C', 'D']
cardFaces = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']

class Card extends Backbone.Model
  defaults:
    name: ''
    suit: ''

  print: ->
    console.log "#{@get('name')} of #{@get('suit')}"


class Deck extends Backbone.Collection
  model: Card

  initialize: =>
    @cards = []
    for suit in cardSuits
      for face in cardFaces
        @cards.push name: face, suit: suit
    @shuffle()

  shuffle: =>
    @reset @cards
    @reset _.shuffle @models

  draw: (num = 1) =>
    cards = []
    for i in [1..num]
      cards.push @pop()
    return new Hand cards


class Hand extends Backbone.Collection
  model: Card

  initialize: =>
    @held = []

  hold: (index) =>
    if index in @held
      idx = @held.indexOf index
      @held.splice idx, 1
    else
      @held.push index

  deal: (deck) =>
    cards = @models.slice()
    for card in [0...@length]
      continue if card in @held
      cards.splice card, 1, deck.pop()
    @reset cards

  getPair: =>
    faces = @groupBy (card) -> card.get('name')
    sets = _.values faces
    pairs = _.filter(sets, (cards) -> cards.length is 2)
    trips = _.filter(sets, (cards) -> cards.length is 3)
    if pairs.length isnt 1 or trips.length is 1
      return []
    card = pairs[0][0]
    return [card.get 'name']

  getTwoPair: =>
    faces = @groupBy (card) -> card.get('name')
    sets = _.values faces
    pairs = _.filter(sets, (cards) -> cards.length is 2)
    if pairs.length isnt 2
      return []
    card1 = pairs[0][0]
    card2 = pairs[1][0]
    return [card1.get('name'), card2.get('name')]

  getThreeOfAKind: =>
    faces = @groupBy (card) -> card.get('name')
    sets = _.values faces
    trips = _.filter(sets, (cards) -> cards.length is 3)
    pairs = _.filter(sets, (cards) -> cards.length is 2)
    if trips.length isnt 1 or pairs.length is 1
      return []
    card = trips[0][0]
    return [card.get 'name']

  getFourOfAKind: =>
    faces = @groupBy (card) -> card.get('name')
    sets = _.values faces
    quads = _.filter(sets, (cards) -> cards.length is 4)
    single = _.filter(sets, (cards) -> cards.length is 1)
    unless quads.length
      return []
    card = quads[0][0]
    kicker = single[0][0]
    return [card.get('name'), kicker.get('name')]

  getFullHouse: =>
    faces = @groupBy (card) -> card.get('name')
    sets = _.values faces
    trips = _.filter(sets, (cards) -> cards.length is 3)
    pairs = _.filter(sets, (cards) -> cards.length is 2)
    if trips.length isnt 1 or pairs.length isnt 1
      return []

    trip = trips[0][0]
    pair = pairs[0][0]
    return [trip.get('name'), pair.get('name')]

  isFlush: =>
    suits = @groupBy (card) -> card.get('suit')
    return _.keys(suits).length is 1

  getStraight: =>
    names = @pluck 'name'
    indexes = names.map (name) -> cardFaces.indexOf name
    indexes.sort (a,b) -> a - b
    uniques = _.uniq indexes, true
    return [] if uniques.length isnt 5

    # Low straight
    if uniques[4] is 12 and uniques[3] is 3
      return ['5']

    if uniques[4] - uniques[0] is 4
      return [cardFaces[uniques[4]]]
    else
      return []

  getStraightFlush: =>
    return [] unless @isFlush()
    @getStraight()


class Game extends Backbone.Model
  defaults:
    credit: 1000
    bet: 1
    numHands: 1

  payTable: {}

  initialize: =>
    @payTable = new JacksBetter96

  validate: (attr) ->
    if attr.bet < 1 or attr.bet > 5
      return 'can only be between 1 and 5'
    if @hand
      if attr.bet isnt @get('bet')
        return 'cannot change bet during a hand'
      if attr.numHands isnt @get('numHands')
        return 'cannot change number of hands during a hand'

  deal: =>
    @payTable.clearWins()
    return @hand if @hand
    num = @get 'numHands'
    bet = @get 'bet'
    credit = @get 'credit'

    @set credit: credit - (num * bet)

    @decks = []
    deck = new Deck
    @hand = deck.draw 5
    @payTable.check @hand

    @decks.push deck
    for i in [1...num]
      @decks.push new Deck(deck.models)

    @trigger 'deal', @hand
    @hand

  draw: =>
    @payTable.clearWins()
    hands = []
    for deck in @decks
      hands.push @hand.deal(deck)

    getMultipier = (type) =>
      if type is 'royalFlush' and bet is 5
        return @payTable.multiplier
      return 1

    bet = @get 'bet'
    credit = @get 'credit'
    for hand in hands
      @payTable.check hand, (win, type) ->
        credit += bet * win * getMultipier(type)

    @set credit: credit
    @hand = undefined

    @trigger 'draw', hands
    hands


class PayTable extends Backbone.Model
  clearWins: =>
    for key of @toJSON()
      @set key, 0

  incr: (type) =>
    curr = @get type
    @set type, 1 + curr

class JacksBetter96 extends PayTable
  defaults:
    pair: 0
    twoPair: 0
    threeOfAKind: 0
    straight: 0
    flush: 0
    fullHouse: 0
    fourOfAKind: 0
    straightFlush: 0
    royalFlush: 0

  getPayouts: ->
    pair: 1
    twoPair: 2
    threeOfAKind: 3
    straight: 4
    flush: 6
    fullHouse: 9
    fourOfAKind: 25
    straightFlush: 50
    royalFlush: 250

  multiplier: 3.2

  check: (hand, win = ->) ->
    if _.intersection(hand.getPair(), ['J', 'Q', 'K', 'A']).length
      @incr 'pair'
      win 1, 'pair'
    if hand.getTwoPair().length
      @incr 'twoPair'
      win 2, 'twoPair'
    if hand.getThreeOfAKind().length
      @incr 'threeOfAKind'
      win 3, 'threeOfAKind'

    straightFlush = hand.getStraightFlush()
    if straightFlush.length
      if straightFlush[0] isnt 'A'
        @incr 'straightFlush'
        win 50, 'straightFlush'
      else
        @incr 'royalFlush'
        win 250, 'royalFlush'
      return

    if hand.getStraight().length
      @incr 'straight'
      win 4, 'straight'
    if hand.isFlush()
      @incr 'flush'
      win 6, 'flush'
    if hand.getFullHouse().length
      @incr 'fullHouse'
      win 9, 'fullHouse'
    if hand.getFourOfAKind().length
      @incr 'fourOfAKind'
      win 25, 'fourOfAKind'


if typeof exports isnt 'undefined'
  module.exports =
    Card: Card
    Deck: Deck
    Hand: Hand
    Game: Game
    JacksBetter96: JacksBetter96
if window?
  window.Card = Card
  window.Deck = Deck
  window.Hand = Hand
  window.Game = Game
  window.JacksBetter96 = JacksBetter96
