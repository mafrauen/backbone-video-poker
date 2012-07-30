#= require lib/jquery-1.7.1.min.js
#= require lib/underscore-min.js
#= require lib/backbone.js
#= require_tree templates
#= require models

names =
  2: '2'
  3: '3'
  4: '4'
  5: '5'
  6: '6'
  7: '7'
  8: '8'
  9: '9'
  T: '10'
  J: 'Jack'
  Q: 'Queen'
  K: 'King'
  A: 'Ace'

suits =
  H: 'Hearts&hearts;'
  C: 'Clubs'
  D: 'Diamonds'
  S: 'Spades'

game = new Game

class AppView extends Backbone.View

  initialize: =>
    game.on 'change:bet', @highlightBet
    @render()
    @highlightBet()

  render: =>
    payTableView = new PayTableView(model: game.payTable)
    $('#payTable').append payTableView.render().el
    gameView = new GameView model: game
    $('#game').append gameView.render().el
    @

  highlightBet: (bet)  =>
    bet = game.get 'bet'
    $(".bet1").toggleClass 'highlightBet', bet is 1
    $(".bet2").toggleClass 'highlightBet', bet is 2
    $(".bet3").toggleClass 'highlightBet', bet is 3
    $(".bet4").toggleClass 'highlightBet', bet is 4
    $(".bet5").toggleClass 'highlightBet', bet is 5

class HandView extends Backbone.View

  id: 'hand'

  initialize: ->
    @collection.on 'reset', @render
    $('body').keypress @handleKey

  render: =>
    @$el.empty()
    for card, idx in @collection.models
      suit = card.get('suit')
      view = new CardView
        model: card
        index: idx
        className: "card #{suit}"
      @$el.append view.render().el
    @

  handleKey: (e) =>
    if e.keyCode in [49..53]
      index = e.keyCode - 49
      card = @collection.at(e.keyCode - 49)
      card.trigger 'hold'

class CardView extends Backbone.View

  template: new Hogan.Template Templates.card

  events:
    'click': 'hold'

  initialize: (model) =>
    @model.on 'hold', @hold

  render: =>
    @$el.html @template.render
      name: names[@model.get('name')]
      suit: suits[@model.get('suit')]

    hand = @model.collection
    index = hand.models.indexOf @model
    isHeld = index in hand.held
    @$el.fadeIn 150 * index unless isHeld
    @renderHeld()
    @

  renderHeld: =>
    hand = @model.collection
    index = hand.models.indexOf @model

    isHeld = index in hand.held
    @$('.hold').toggleClass 'isHeld', isHeld

  hold: =>
    hand = @model.collection
    index = hand.models.indexOf @model
    hand.hold index

    @renderHeld()


class GameView extends Backbone.View

  template: new Hogan.Template Templates.game

  events:
    'click #lessBet': 'lessBet'
    'click #moreBet': 'moreBet'

  initialize: =>
    @model.on 'deal', @renderHand
    @model.on 'change', @render
    $('body').keypress @handleKey

  render: =>
    @$el.html @template.render
      bet: @model.get 'bet'
      credits: @model.get 'credit'
    @

  renderHand: (hand) =>
    handView = new HandView(collection: hand)
    $('#hand').html handView.render().el
    $('#instructions').html '<br>'

  handleSpace: =>
    if @hand
      @model.draw()
      $('#instructions').html 'Press Space to deal again'
      @$('#moreBet, #lessBet').removeAttr 'disabled'
      @hand = undefined
    else
      @hand = @model.deal()
      @$('#moreBet, #lessBet').attr 'disabled', 'disabled'

  lessBet: =>
    bet = @model.get 'bet'
    @model.set 'bet', --bet

  moreBet: =>
    bet = @model.get 'bet'
    @model.set 'bet', ++bet

  handleKey: (e) =>
    @handleSpace() if e.keyCode is 32


class PayTableView extends Backbone.View

  template: new Hogan.Template Templates.payTable

  initialize: =>
    @model.on 'change', @changes

    @info = hands: []
    for key, value of @model.getPayouts()
      hand = name: key
      for bet in [1..5]
        win = bet * value
        if key is 'royalFlush' and bet is 5
          win *= @model.multiplier
        hand["bet#{bet}"] = win
      @info.hands.push hand

  render: =>
    @$el.html @template.render @info
    @

  changes: (changes) =>
    for key,value of changes.changedAttributes()
      @$("##{key}").toggleClass 'highlightHand', value > 0

jQuery ->
  window.app = new AppView
