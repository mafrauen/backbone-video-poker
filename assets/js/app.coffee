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

deck = new Deck

class AppView extends Backbone.View

  el: $('#game')

  initialize: ->
    @render()

  render: =>
    # paytable, game, hand, buttons
    deck.shuffle()
    hand = deck.draw 5
    view = new HandView(collection: hand)
    @$el.append view.render().el
    @


class HandView extends Backbone.View

  id: 'hand'

  events:
    'click #draw': 'draw'

  initialize: ->
    @collection.on 'reset', @render

  render: =>
    @$el.empty()
    for card, idx in @collection.models
      suit = card.get('suit')
      view = new CardView
        model: card
        index: idx
        className: "card #{suit}"
      @$el.append view.render().el
    @$el.append '
      <button id="draw">Draw</button>
      '
    @

  draw: =>
    @collection.deal deck

class CardView extends Backbone.View

  template: new Hogan.Template Templates.card

  events:
    'click': 'hold'

  render: =>
    @$el.html @template.render
      name: names[@model.get('name')]
      suit: suits[@model.get('suit')]
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


jQuery ->
  new AppView
