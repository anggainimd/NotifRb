require_relative '../notification.rb'

file_name = ARGV.shift
user_id = ARGV.shift
pp  Notification.new.get_notifications_for_user(file_name, user_id) 
