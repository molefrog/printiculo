View    = require "views/base/base"
Station = require "models/station"

module.exports = class StationView extends View
	model : Station

	initialize : ->
		@delegate "click", ".delete-confirm-button", @deleteStation
		@delegate "click", ".secret-button", @showSecret
	
	deleteStation : ->
		@$(".delete-modal").modal("hide")
		@model.destroy
			success : =>
				Chaplin.utils.redirectTo "stations#index"

	showSecret : ->
		@model.secret (secret) =>	
			@$(".secret-modal .secret-field").text(secret)
			@$(".secret-modal").modal("show")


	template : require "./stationView_"

	render : ->
		super

		if @model.get "streaming"
			canvas = @$(".video-canvas")[0]

			wsAddress = "ws://#{window.location.hostname}:3030/#{@model.attributes.name}"

			console.log wsAddress
			@client = new WebSocket( wsAddress )
			@player = new jsmpeg @client, 
				canvas : canvas

	getTemplateData : ->
		station : @model.attributes