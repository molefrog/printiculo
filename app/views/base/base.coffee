jade.url = Chaplin.utils.reverse
 
# Base view.
module.exports = class View extends Chaplin.View
	# Precompiled templates function initializer.
	getTemplateFunction: ->
		@template