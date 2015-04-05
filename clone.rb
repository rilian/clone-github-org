require 'octokit'
require 'byebug'

client = Octokit::Client.new(access_token: ENV['TOKEN'])
timestamp = Time.now.to_i.to_s

ENV['ORG'].split(',').map(&:strip).each do |org|
  # Most recently pushed code goes first
  repos = client
    .org_repositories(org, per_page: 1000)
    .sort { |a, b| b[:pushed_at] <=> a[:pushed_at] }
    .map {|e| e[:full_name] }

  puts "Found #{repos.size} repos: #{repos.join(' ')}"

  repos.each do |repo|
    repo_path = "#{org}/#{timestamp}/#{repo.gsub("#{org}/", '')}"
    system("mkdir -p #{repo_path}")
    system("git clone https://#{ENV['TOKEN']}:x-oauth-basic@github.com/#{repo}.git #{repo_path}")
  end

  system("tar -zcvf #{org}/#{timestamp}.tar.gz #{org}/#{timestamp}")
end
