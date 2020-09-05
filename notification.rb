require "json"
require "pry"

class Notification
  # asumtion notif type 4 is devote
  NOTIF_TYPE = { 1 => "answer", 2 => "comment on", 3 => "upvote", 4 => "devote" }

  def get_notifications_for_user(notifications, user_id)
    notificationsText = []
    file = if File.exist?(notifications)
      File.read(notifications)
    else
      return false, "File not exist"
    end
    data_hash = JSON.parse(file)

    userNotification = find_by_user(data_hash, user_id)
    notifByMinute = group_by_minutes(userNotification)
    notifByMinute.map do |notif|
      notif[1].group_by{|currentNotif| currentNotif["notification_type_id"]}.map{|currentNotif|
        notificationsText << notif_to_sentence(currentNotif)
      }
    end
    return notificationsText
  end

  def notif_to_sentence(currentNotif)
    created_at = Time.at(currentNotif[1][0]["created_at"].to_f / 1000).strftime("%Y-%m-%d %H:%M")  
    sender_users = to_sentence(currentNotif[1].map{|sender| sender["sender_id"]})
    notif_text_type = NOTIF_TYPE[currentNotif[1][0]["notification_type_id"]]
    "[#{created_at}] #{sender_users} #{notif_text_type} a question"
  end

  def find_by_user(data_hash, user_id)
    data_hash.select{|data| data["user_id"] == user_id}
  end

  def group_by_minutes(data_hash)
    data_hash.group_by{|notif| (notif["created_at"].to_f / 1000) - (notif["created_at"].to_f / 1000) % 60 }
  end

  def to_sentence(users)
    default_connectors = {
      words_connector: ", ",
      two_words_connector: " and ",
      last_word_connector: ", and "
    }
    case users.length
    when 0
      ""
    when 1
      "#{users[0]}"
    when 2
      "#{users[0]}#{default_connectors[:two_words_connector]}#{users[1]}"
    else
      "#{users[0...-1].join(default_connectors[:words_connector])}#{default_connectors[:last_word_connector]}#{users[-1]}"
    end
  end
end

# shortcut to get values when you want to run it on terminal
# comment this line if you run spec test
pp Notification.new.get_notifications_for_user(ARGV[0], ARGV[1])
