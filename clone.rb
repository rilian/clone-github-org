require 'octokit'
require 'byebug'

client = Octokit::Client.new(access_token: ENV['TOKEN'])

# Most recently pushed code goes first
repos = client
  .org_repositories(ENV['ORG'], per_page: 1000)
  .sort{|a,b| b[:pushed_at] <=> a[:pushed_at]}
  .collect{|e| e[:full_name]}

puts "Found #{repos.size} repos: #{repos.join(' ')}"

timestamp = Time.now.to_i.to_s

repos.each do |repo|
  puts "\nRepo #{repo}"
  repo_name = repo.gsub("#{ENV['ORG']}/", '')
  repo_path = "#{ENV['ORG']}/#{timestamp}/#{repo_name}"
  system("mkdir -p #{repo_path}")
  system("git clone https://#{ENV['TOKEN']}:x-oauth-basic@github.com/#{repo}.git #{repo_path}")
  puts "Done\n"
end

system("tar -zcvf #{ENV['ORG']}/#{timestamp}.tar.gz #{ENV['ORG']}/#{timestamp}")
