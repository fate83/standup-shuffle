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

  members.map.with_index do |member, idx|
    time = human_readable_time(elapsed_time(times[idx]))

    return_value = ''
    return_value = [" #{done} ", member, time] if idx <  index
    return_value = [" #{onit} ", member, time] if idx == index
    return_value = [" #{nuxt} ", member, time] if idx == index + 1
    return_value = [" #{wait} ", member, time] if idx >  index + 1
    return_value
  end
end

def make_table(members, headlines, index, times)
  TTY::Table.new headlines, make_table_values(members, headlines, index, times)
end
def clear_screen
  print "\e[2J\e[f"
end

def print_table(members, headlines, index, start_time, times)
  clear_screen
  puts "Standup Shuffle Version #{Version::VERSION}"
  puts "Start time: #{start_time&.strftime("%H:%M:%S")}"
  puts "Current time: #{Time.now.strftime("%H:%M:%S")}"

  puts make_table(members, headlines, index, times).render(:ascii)
end

def progress_bar
  TTY::ProgressBar.new("1 Minute [:bar]", total: 60)
end

def write_logs(members, headlines, index, start_time, times)
  today = Time.now.strftime("%Y-%m-%d")
  headlines[0] = "Day"

  values = members.zip(times.map { |t| elapsed_time(t) }).map do |row|
    row.unshift today
    row.join(";")
  end.sort

  File.open("log-#{ today }.csv", "w") do |file|
    file.write("#{headlines.join(";")}\n")
    file.write("#{values.join("\n")}\n")
  end
end

choices = [
  { key: 'n', name: '(N)ext Member', value: :next },
  { key: 'a', name: '(A)way Member', value: :away },
  { key: 'e', name: '(E)nd Member', value: :end },
  { key: 'b', name: '(B)ack', value: :back },
  { key: 'q', name: '(Q)uit', value: :quit }
]

prompt = TTY::Prompt.new
choice = ''
index = 0

clear_screen
members.shuffle!

print_table(members, headlines, index, nil, times)


prompt.ask("Press a key to start?")
start_time = Time.now
end_time = nil

until choice == :quit
  member = members[index]
  times[index] = { start_time: Time.now, end_time: nil }

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

  when :end
    members.delete(member)
    members.push member

  when :away
    members.delete_at(index)
    times.delete_at(index)

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
write_logs(members, headlines, index, start_time, times)
time = human_readable_time(elapsed_time({start_time: start_time, end_time: end_time}))
puts "Time total: #{time}"
puts '🎉🎉🎉'

