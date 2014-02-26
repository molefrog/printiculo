ShotGridItemView = require "./item/shotGridItemView"
CollectionView   = require "views/base/collectionView"


module.exports = class ShotGridView extends CollectionView
	initialize : ->
		super
		@delegate "click", ".load-button", =>
			do @collection.forceLoad

	className : "shot-grid-view"

	listSelector : ".shot-grid"

	useCssAnimation : true

	animationStartClass : "animated fadeInDown"

	itemView : ShotGridItemView

	template : require "./shotGridView_"
