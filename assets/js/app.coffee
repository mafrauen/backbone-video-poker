#= require lib/jquery-1.7.1.min.js
#= require lib/underscore-min.js
#= require lib/backbone-min.js
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
  H: 'Hearts'
  C: 'Clubs'
  D: 'Diamonds'
  S: 'Spades'

class AppView extends Backbone.View

  el: $('#game')

  initialize: ->
    @deck = new Deck
    @render()

  render: =>
    # paytable, game, hand, buttons
    @deck.shuffle()
    hand = @deck.draw 5
    view = new HandView(collection: hand)
    @$el.append view.render().el
    @


class HandView extends Backbone.View

  id: 'hand'

  initialize: ->

  render: =>
    for card, idx in @collection.models
      suit = suits[card.get('suit')]
      view = new CardView
        model: card
        index: idx
        className: "card #{suit}"
      @$el.append view.render().el
    @

class CardView extends Backbone.View

  template: new Hogan.Template Templates.card

  render: =>
    @$el.html @template.render
      name: names[@model.get('name')]
      suit: suits[@model.get('suit')]
    @


class GameView extends Backbone.View

  initialize: ->


jQuery ->
  new AppView
