require 'json'
require 'pry'
require 'rspec/autorun'

class Notification
  # asumtion notif type 4 is devote
  NOTIF_TYPE = { 1 => "answer", 2 => "comment on", 3 => "upvote", 4 => "devote" }

  def get_notifications_for_user(notifications, user_id)
    notificationsText = []
    file = File.read(notifications)
    data_hash = JSON.parse(file)

    userNotification = find_by_user(data_hash, user_id)
    notifByMinute = group_by_minutes(userNotification)
    notifByMinute.map do |notif|
      notif[1].group_by{|currentNotif| currentNotif['notification_type_id']}.map{|currentNotif|
        notificationsText << notif_to_sentence(currentNotif)
      }
    end
    return notificationsText
  end

  def notif_to_sentence(currentNotif)
    created_at = Time.at(currentNotif[1][0]['created_at'].to_f / 1000).strftime("%Y-%m-%d %H:%M")  
    sender_users = to_sentence(currentNotif[1].map{|sender| sender['sender_id']})
    notif_text_type = NOTIF_TYPE[currentNotif[1][0]['notification_type_id']]
    "[#{created_at}] #{sender_users} #{notif_text_type} a question"
  end

  def find_by_user(data_hash, user_id)
    data_hash.select{|data| data['user_id'] == user_id}
  end

  def group_by_minutes(data_hash)
    data_hash.group_by{|notif| (notif['created_at'].to_f / 1000) - (notif['created_at'].to_f / 1000) % 60 }
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

file_name = ARGV.shift 
user_id = ARGV.shift
pp Notification.new.get_notifications_for_user(file_name, user_id)

describe 'Notification' do
  let(:notif) {Notification.new}
  let(:notifications_text) { notif.get_notifications_for_user('notificationNew.json', 'hackamorevisiting') } 

  let(:test_user_id) {'hackamorevisiting'}
  let(:data_json) { JSON.parse(File.read('notificationNew.json')) }

  let(:single_name) { ['Jhon'] }
  let(:double_name) { ['Jhon', 'Gino'] }
  let(:multiple_name) { ['Jhon', 'Gino', 'Warren', 'Dan', 'Torro'] }

  context 'Get current notification type [constant NOTIF_TYPE]' do    
    it 'notif type 1 is answer' do
      expect( Notification::NOTIF_TYPE[1] ).to eq('answer')
    end

    it 'notif type 2 is comment' do
      expect( Notification::NOTIF_TYPE[2] ).to eq('comment on')
    end

    it 'notif type 3 is upvote' do
      expect( Notification::NOTIF_TYPE[3] ).to eq('upvote')
    end
  end

  context 'Filter json by user_id [find_by_user]' do
    it 'find only current user data' do
      expect( notif.find_by_user(data_json, test_user_id).map{|n| n['user_id']}.uniq ).to eq([test_user_id])
    end

    it 'find only current user_id' do
      expect( notif.find_by_user(data_json, test_user_id).map{|n| n['user_id']}.uniq.count ).to eq(1)
    end
  end

  context 'Group notification by minute [group_by_minutes]' do
    let(:user_notif) {notif.find_by_user(data_json, test_user_id)}
    it 'time range is 1 minute' do
      expect( notif.group_by_minutes(user_notif).map{|x| x[0].to_i % 60  }.uniq  ).to eq([0])
    end
  end

  context 'Array to Text [to_sentence]' do
    it 'single name without word connector' do
      expect( notif.to_sentence(single_name).include?(',') ).to eq(false)
      expect( notif.to_sentence(single_name).include?('and') ).to eq(false)
    end
  
    it 'single name without word connector' do
      expect( notif.to_sentence(double_name).include?(',') ).to eq(false)
      expect( notif.to_sentence(double_name).include?('and') ).to eq(true)
    end
  
    it 'single name without word connector' do
      expect( notif.to_sentence(multiple_name).include?('and') ).to eq( true )
      expect( notif.to_sentence(multiple_name).include?(',') ).to eq( true )
      expect( notif.to_sentence(multiple_name).include?(', and') ).to eq( true )
    end
  end
end


