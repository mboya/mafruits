class Messenger
  def self.parse_payload payload
    payload[:entry].collect do |entry|
      {
        page_id: entry[:id],
        receipts: _get_receipts(entry),
        posts: _get_posts(entry),
        messages: entry[:messaging].try(:collect) do |message|
          {
            sender_id: message[:sender][:id],
            timestamp: message[:timestamp],
            type: self._entry_type?(message),
            message_id: message[:message] ? message[:message][:mid] : nil,
            text: message[:message] ? message[:message][:text] : nil,
            url: self._image_url(message),
            message_ids: message.try(:[], :delivery).try(:[], :mids),
            postback: message.try(:[], :postback),
            payload: message.try(:[], :message).try(:[], :attachments).try(:first).try(:[], :payload)
          }
        end
      }
    end
  end
end