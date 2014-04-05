queue  = require "../services/queue/jobs"

# Utilities
{ config, log, sms } = require "../utils"

module.exports = (cb) ->
  @status = "queued"
  @save (err, item) =>
    job = queue.create "print",
      title : "Shot ##{@_id}"
      id : @_id
    .save ->
      cb "hello"

    job.on "failed", (err) =>
      sms
        to   : config.get 'sms:toNumber'
        body : "Леша, фото @#{@instagram.user.username} не напечаталось!"
      @status = "failed"
      @save (err) =>
        log.warn "Shot ##{@_id} marked as failed"

    job.on "complete", =>
      sms
        to   : config.get 'sms:toNumber'
        body : "Леша, я напечатал фото для @#{@instagram.user.username}."

      @status = "printed"
      @save =>
        log.info "Shot ##{@_id} marked as complete"
