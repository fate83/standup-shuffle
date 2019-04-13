#!/usr/bin/env ruby

require 'active_support/all'
require 'tty-prompt'
require 'tty-table'
require 'tty-progressbar'

require_relative 'version'

headlines = ['','Member', 'Time']
members =  File.read('members.txt').split("\n")
times = []
extra_times = []

def human_readable_time(time)
  return time unless time.is_a?(Numeric)

  ActiveSupport::Duration.build(time.round(1)).inspect
end

def elapsed_time(times)
  return ' -' if times.nil?

  start_time = times[:start_time]
  end_time = times[:end_time]

  return ' -' if start_time.nil?
  return ' -' if end_time.nil?

  end_time - start_time
end

def make_table_values(members, headlines, index, times)
  done = ' ✅ '
  onit = ' 🎤 '
  nuxt = ' 😱️ '
  wait = ' 🔜 '

  table_values = members.map.with_index do |member, idx|
    time = human_readable_time(elapsed_time(times[idx]))

    return_value = ''
    return_value = [" #{done} ", member, time] if idx <  index
    return_value = [" #{onit} ", member, time] if idx == index
    return_value = [" #{nuxt} ", member, time] if idx == index + 1
    return_value = [" #{wait} ", member, time] if idx >  index + 1
    return_value
  end
  TTY::Table.new headlines, table_values
end

def clear_screen
  print "\e[2J\e[f"
end

def print_table(members, headlines, index, start_time, times)
  clear_screen
  puts "Standup Shuffle Version #{Version::VERSION}"
  puts "Start time: #{start_time&.strftime("%H:%M:%S")}"
  puts "Current time: #{Time.now.strftime("%H:%M:%S")}"

  puts make_table_values(members, headlines, index, times).render(:ascii)
end

def progress_bar
  TTY::ProgressBar.new("1 Minute [:bar]", total: 60)
end

choices = [
  { key: 'n', name: 'Next Member', value: :next },
  { key: 'b', name: 'Back', value: :back },
  { key: 'q', name: 'Quit', value: :quit }
]

prompt = TTY::Prompt.new
choice = ''
index = 0

clear_screen
disabled = prompt.multi_select("Anyone missing?",members, filter: true)

members -= disabled
members.shuffle!

print_table(members, headlines, index, nil, times)


prompt.ask("Press a key to start?")
start_time = Time.now
end_time = nil

until choice == :quit
  loop do
    member = members[index]

    unless disabled.include?(member)
      times[index] = { start_time: Time.now, end_time: nil }
      break
    end

    index += 1
  end

  print_table(members, headlines, index, start_time, times)

  puts

  bar = progress_bar
  thr = Thread.new do
    60.times do
      sleep(1)
      bar.advance(1)
    end
  end

  choice = prompt.expand("Action?", choices)

  case choice
  when :next
    times[index][:end_time] = Time.now

    extra_time = extra_times.pop
    unless extra_time.nil?
      extra_time_elapsed = elapsed_time(extra_time)
      times[index][:end_time] += extra_time_elapsed
    end

    index += 1
  when :back
    if index.positive?
      index -= 1
      extra_times.push(times[index])
    end
  else
    index = index
  end

  thr.exit

  print_table(members, headlines, index, start_time, times)
  if index >= members.size || choice == :quit
    end_time = Time.now
    break
  end
end
clear_screen
print_table(members, headlines, index, start_time, times)

time = human_readable_time(elapsed_time({start_time: start_time, end_time: end_time}))
puts "Time total: #{time}"
puts '🎉🎉🎉'

