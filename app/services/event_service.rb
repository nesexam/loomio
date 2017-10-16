class EventService
  def self.mark_as_read(event:, actor:)
    actor.ability.authorize! :mark_as_read, event.discussion

    DiscussionReader.for_model(event.discussion, actor).viewed_sequence_id! event.sequence_id

    EventBus.broadcast('event_mark_as_read', event, actor)
  end
end
