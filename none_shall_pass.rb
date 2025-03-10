#!/usr/bin/env ruby
require 'io/console'

EMAIL = 'nate@example.com'
PASSWORD = 'goread'
PASSWORD_VAULT = { aws: { username: 'nathan', password: 'asdf' } }
OPTIONS = { create_new_credentials: '1', retreieve_requested_service_credentials: '2', exit: '3' }
MAX_LOGIN_ATTEMPTS = 5

current_user = { email: '', password: '' }
failed_login_attempts = 0
logged_in = false

def print_wizard
  puts '                                  ....'
  puts "                                .'' .'''"
  puts ".                             .'   :"
  puts '\\\\                          .:    :'
  puts ' \\\\                        _:    :       ..----.._'
  puts "  \\\\                    .:::.....:::.. .'         ''."
  puts "   \\\\                 .'  #-. .-######'     #        '."
  puts "    \\\\                 '.##'/ ' ################       :"
  puts '     \\\\                  #####################         :'
  puts "      \\\\               ..##.-.#### .''''###'.._        :"
  puts "       \\\\             :--:########:            '.    .' :"
  puts "        \\\\..__...--.. :--:#######.'   '.         '.     :"
  puts "        :     :  : : '':'-:'':'::        .         '.  .'"
  puts "        '---'''..: :    ':    '..'''.      '.        :'"
  puts "           \\\\  :: : :     '      ''''''.     '.      .:"
  puts "            \\\\ ::  : :     '            '.      '      :"
  puts "             \\\\::   : :           ....' ..:       '     '."
  puts '              \\\\::  : :    .....####\\ .~~.:.             :'
  puts "               \\\\':.:.:.:'#########.===. ~ |.'-.   . '''.. :"
  puts "                \\\\    .'  ########## \\ \\ _.' '. '-.       '''."
  puts "                :\\\\  :     ########   \\ \\      '.  '-.        :"
  puts "               :  \\'    '   #### :    \\ \\      :.    '-.      :"
  puts "              :  .'\\\\   :'  :     :     \\ \\       :      '-.    :"
  puts "             : .'  .\\\\  '  :      :     : \\ \\      :        '.   :"
  puts "             ::   :  \\'  :.      :     :  \\:\\     :          '. :"
  puts "             ::. :    \\\\  : :      :    ;  \\ \\     :           '.:"
  puts "              : ':    '\\\\ :  :     :     :  \\:\\     :        ..'"
  puts "                 :    ' \\\\ :        :     ;  \\|      :   .'''"
  puts "                 '.   '  \\\\:                         :.''"
  puts "                  .:..... \\\\ :       :            ..''"
  puts "                 '._____|'.\\\\......'''''''.:..'''"
end

def print_signin_greeting
  print_wizard
  puts 'Welcome to None Shall Pass (NSP): Credentials Manager'
  puts 'Please sign in to continue'
end

def prompt_user_for_email
  print 'Enter email: '
  user_email = gets.chomp
end

def prompt_user_for_password
  print 'Enter password: '
  user_password = $stdin.noecho(&:gets).chomp # Hides input while user types password
end

def prompt_user_for_username
  print 'Enter your username: '
  username = gets.chomp
end

def prompt_user_for_selection
  print 'Enter your selection: '
  user_selection = gets.chomp
end

def prompt_user_for_service_name
  print 'Enter the name of the service: '
  service = gets.chomp
end

def verify_user_email(email)
  email == EMAIL
end

def verify_user_password(password)
  password == PASSWORD
end

def verify_user_input
  print "\nIs this Correct? [Y/n]: "
  confirm = gets.chomp
  return false if %w[n N].include?(confirm)

  true
end

def verify_user_credentials(user)
  verify_user_email(user[:email]) && verify_user_password(user[:password]) ? true : false
end

def track_failed_logins(attempts)
  print "\nInvalid email/password\n"
  attempts += 1
  if attempts >= MAX_LOGIN_ATTEMPTS
    puts 'Too many failed login attempts.'
    exit_program
  end
  puts "#{MAX_LOGIN_ATTEMPTS - attempts} attempts remainging."
  puts 'Press ENTER to continue.'
  gets
  attempts
end

def print_credentials_menu
  puts '======== CREDENTIALS MANAGER MENU ========'
  OPTIONS.each do |key, val|
    puts "#{val}: #{key.to_s.gsub('_', ' ').capitalize}"
  end
  puts "\n"
end

def handle_user_selection(user_selection)
  case user_selection
  when OPTIONS[:create_new_credentials]
    verified = false

    while verified == false
      new_service_name = prompt_user_for_service_name
      create_new_credentials_for(new_service_name)
      retreieve_requested_service_credentials_for(new_service_name)
      verified = verify_user_input
    end

  when OPTIONS[:retreieve_requested_service_credentials]
    service = prompt_user_for_service_name
    retreieve_requested_service_credentials_for(service)
    puts 'Press ENTER to return to main menu'
    gets

  else
    exit_program
  end
end

def create_new_credentials_for(service)
  PASSWORD_VAULT[service.to_sym] = {}

  new_service_username = prompt_user_for_username
  PASSWORD_VAULT[service.to_sym][:username] = new_service_username

  new_service_password = prompt_user_for_password
  PASSWORD_VAULT[service.to_sym][:password] = new_service_password
end

def retreieve_requested_service_credentials_for(service_name)
  credentials = PASSWORD_VAULT[service_name.to_sym]
  if credentials.nil?
    puts "Could not find credentials for #{service_name}"
  else
    puts "Service name: #{service_name}"
    print_login_credentials_for(credentials)
  end
end

def print_login_credentials_for(service_name)
  service_name.each do |key, val|
    puts "#{key}: #{val}"
  end
  puts "\n"
end

def exit_program
  puts 'Now exiting the program...'
  exit
end

def get_user_credentials(user)
  user[:email] = prompt_user_for_email
  user[:password] = prompt_user_for_password
  user
end

# ============== MAIN CODE ==========================
system 'clear'
while logged_in == false
  print_signin_greeting
  current_user = get_user_credentials(current_user)
  logged_in = verify_user_credentials(current_user)
  failed_login_attempts = track_failed_logins(failed_login_attempts) unless logged_in
  system 'clear'
end

print "Hello, #{current_user[:email]}\n\n"
current_selection = '0'
while current_selection != OPTIONS[:exit]
  print_credentials_menu
  current_selection = prompt_user_for_selection
  handle_user_selection(current_selection)
  system 'clear'
end
