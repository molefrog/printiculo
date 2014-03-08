ShotGridItemView = require "./item/shotGridItemView"
CollectionView   = require "views/base/collectionView"


module.exports = class ShotGridView extends CollectionView
  animationDuration : 300
  initialize : ->
    super
    @delegate "click", ".load-button", =>
      # Disable this feature
      # do @collection.forceLoad

  className : "shot-grid-view"

  listSelector : ".shot-grid"

  itemView : ShotGridItemView

  template : require "./shotGridView_"

