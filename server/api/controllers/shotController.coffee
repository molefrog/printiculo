queue = require "../../services/queue/server"
Shot = require "../../models/shot"

log = require "../../utils/log"

###
# Get all shots
###
exports.index = (req, res, next) ->
	Shot.find({})
	.exec (err, items) ->
		if err 
			return next err

		res.json items

###
# Get specified shot 
###
exports.show = (req, res, next) ->
	Shot.findById( req.params.id )
	.exec (err, item) ->
		if err 
			return next err

		if not item?
			return next new Error "Shot not found"

		res.json item

###
# Delete existing shot
###
exports.delete = (req, res, next) ->
	Shot.remove({ _id : req.params.id })
	.exec (err) ->
		if err 
			return next err

		res.json {}

##
# TODO: move enque method to a separate module
##
exports.queue = (req, res, next) ->
	Shot.findById( req.params.id )
	.exec (err, item) ->
		if err 
			return next err

		if not item?
			return next new Error "Shot not found"

		item.status = "queued"
		item.save (err, item) =>
			job = queue.create "print", 
				title : "Shot ##{item._id}"
				id : item._id
			.save ->
				res.json {}

			job.on "failed", =>
				item.status = "failed"
				item.save (err) =>
					log.warn "Shot ##{item._id} marked as failed"

			job.on "complete", =>
				item.status = "printed"
				item.save =>
					log.info "Shot ##{item._id} marked as complete"
		
