require '../notification.rb'

RSpec.describe Notification do
  let(:notif) {Notification.new}
  let(:notifications_text) { notif.get_notifications_for_user('./notificationNew.json', 'hackamorevisiting') } 

  let(:test_user_id) {'hackamorevisiting'}
  let(:data_json) { JSON.parse(File.read('./notificationNew.json')) }

  let(:single_name) { ['Jhon'] }
  let(:double_name) { ['Jhon', 'Gino'] }
  let(:multiple_name) { ['Jhon', 'Gino', 'Warren', 'Dan', 'Torro'] }

  it 'creates a notification class' do
    notification = Notification.new
    expect(notification).to be_kind_of(Notification)
  end

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

    it 'notif type 4 is devote (asumtion)' do
      expect( Notification::NOTIF_TYPE[4] ).to eq('devote')
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
      expect( notif.group_by_minutes(user_notif).map{|x| x[0].to_i % 60 }.uniq  ).to eq([0])
    end
  end

  context 'Notification by json file and user_id [notifications_text]' do
    let(:user_notif) {notif.find_by_user(data_json, test_user_id)}
    it 'return is string sentence' do
      expect( notifications_text.map{|x| x.class }.uniq  ).to eq([String])
    end

    it 'return false if file not exist' do
      expect( notif.get_notifications_for_user('./notExist.json', 'hackamorevisiting')  ).to eq([false, "File not exist"])
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
